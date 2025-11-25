"""
Minimal Vision Transformer training/inference on the local CIFAR-10 samples in
Final_Project/input_image using lucidrains/vit-pytorch.

Usage (CPU default, change device if you have CUDA):
    python final_proj.py
"""

from __future__ import annotations

import random
import re
from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple

import torch
from PIL import Image
from torch import nn
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms
from vit_pytorch import ViT


# CIFAR-10 normalization
CIFAR10_MEAN = [0.4914, 0.4822, 0.4465]
CIFAR10_STD = [0.2023, 0.1994, 0.2010]
CLASSES = ["airplane", "automobile", "bird", "cat", "deer", "dog", "frog", "horse", "ship", "truck"]
LABEL_RE = re.compile(r"label_(\d+)")


def find_data_root(name: str = "input_image", max_levels: int = 5) -> Path:
    """
    Search for the image folder and return an absolute path.
    Looks at: cwd, parents (up to max_levels), and each of those joined with Final_Project/name.
    """
    cwd = Path.cwd().resolve()
    search_roots = [cwd] + list(cwd.parents)[:max_levels]
    for root in search_roots:
        for cand in (root / name, root / "Final_Project" / name):
            if cand.exists():
                return cand.resolve()
    raise FileNotFoundError(f"{name} not found near {cwd}")


def load_items(root: Path) -> List[Tuple[Path, int]]:
    items: List[Tuple[Path, int]] = []
    for path in sorted(root.glob("*.png")):
        m = LABEL_RE.search(path.name)
        if m:
            items.append((path.resolve(), int(m.group(1))))
    if not items:
        raise RuntimeError(f"No labeled png files found in {root}")
    return items


class ImageWithLabel(Dataset):
    def __init__(self, items: List[Tuple[Path, int]], transform):
        self.items = items
        self.transform = transform

    def __len__(self) -> int:
        return len(self.items)

    def __getitem__(self, idx: int):
        path, label = self.items[idx]
        img = Image.open(path).convert("RGB")
        if self.transform:
            img = self.transform(img)
        return img, label


def make_transforms(img_size: int = 32):
    norm = transforms.Normalize(CIFAR10_MEAN, CIFAR10_STD)
    train_tf = transforms.Compose(
        [
            transforms.Resize((img_size, img_size)),
            transforms.RandomHorizontalFlip(),
            transforms.ToTensor(),
            norm,
        ]
    )
    test_tf = transforms.Compose(
        [
            transforms.Resize((img_size, img_size)),
            transforms.ToTensor(),
            norm,
        ]
    )
    return train_tf, test_tf


@dataclass
class Config:
    img_size: int = 32
    patch_size: int = 4
    embed_dim: int = 128
    depth: int = 6
    heads: int = 2
    mlp_dim: int = 512
    dropout: float = 0.1
    emb_dropout: float = 0.1
    batch_size: int = 64
    epochs: int = 100
    lr: float = 3e-4
    weight_decay: float = 0.05
    val_ratio: float = 0.2
    seed: int = 42


def build_loaders(cfg: Config, data_root: Path):
    train_tf, test_tf = make_transforms(cfg.img_size)
    items = load_items(data_root)
    random.Random(cfg.seed).shuffle(items)
    n_val = max(1, int(len(items) * cfg.val_ratio))
    val_items = items[:n_val]
    train_items = items[n_val:]
    train_ds = ImageWithLabel(train_items, train_tf)
    val_ds = ImageWithLabel(val_items, test_tf)
    train_loader = DataLoader(train_ds, batch_size=cfg.batch_size, shuffle=True, num_workers=0)
    val_loader = DataLoader(val_ds, batch_size=cfg.batch_size, shuffle=False, num_workers=0)
    return train_loader, val_loader, val_items, test_tf


def build_model(cfg: Config) -> ViT:
    return ViT(
        image_size=cfg.img_size,
        patch_size=cfg.patch_size,
        num_classes=len(CLASSES),
        dim=cfg.embed_dim,
        depth=cfg.depth,
        heads=cfg.heads,
        mlp_dim=cfg.mlp_dim,
        dropout=cfg.dropout,
        emb_dropout=cfg.emb_dropout,
    )


def train_one_epoch(model, loader, criterion, optimizer, device):
    model.train()
    total_loss, total_correct, total = 0.0, 0, 0
    for imgs, labels in loader:
        imgs, labels = imgs.to(device), labels.to(device)
        optimizer.zero_grad()
        logits = model(imgs)
        loss = criterion(logits, labels)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()
        total_correct += (logits.argmax(1) == labels).sum().item()
        total += labels.size(0)
    return total_loss / len(loader), total_correct / total


@torch.no_grad()
def evaluate(model, loader, criterion, device):
    model.eval()
    total_loss, total_correct, total = 0.0, 0, 0
    for imgs, labels in loader:
        imgs, labels = imgs.to(device), labels.to(device)
        logits = model(imgs)
        loss = criterion(logits, labels)
        total_loss += loss.item()
        total_correct += (logits.argmax(1) == labels).sum().item()
        total += labels.size(0)
    return total_loss / len(loader), total_correct / total


@torch.no_grad()
def predict_one(model, path: Path, transform, device):
    model.eval()
    img = Image.open(path).convert("RGB")
    tensor = transform(img).unsqueeze(0).to(device)
    logits = model(tensor)
    probs = logits.softmax(-1)[0]
    pred = probs.argmax().item()
    return pred, float(probs[pred])


@torch.no_grad()
def predict_loader(model, loader, device):
    """Run inference over an entire loader and return (pred, label) lists."""
    model.eval()
    preds, labels = [], []
    for imgs, labs in loader:
        imgs = imgs.to(device)
        logits = model(imgs)
        pred = logits.argmax(1).cpu().tolist()
        preds.extend(pred)
        labels.extend(labs.tolist())
    return preds, labels


def main():
    cfg = Config()
    torch.manual_seed(cfg.seed)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    data_root = find_data_root()
    print(f"Data root: {data_root}")

    train_loader, val_loader, val_items, test_tf = build_loaders(cfg, data_root)
    model = build_model(cfg).to(device)
    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.AdamW(model.parameters(), lr=cfg.lr, weight_decay=cfg.weight_decay)

    for epoch in range(cfg.epochs):
        tr_loss, tr_acc = train_one_epoch(model, train_loader, criterion, optimizer, device)
        val_loss, val_acc = evaluate(model, val_loader, criterion, device)
        print(f"epoch {epoch + 1}/{cfg.epochs} | train {tr_loss:.4f}/{tr_acc:.3f} | val {val_loss:.4f}/{val_acc:.3f}")

    # Run prediction on full validation set (not just one sample)
    preds, labs = predict_loader(model, val_loader, device)
    correct = sum(int(p == l) for p, l in zip(preds, labs))
    print(f"Full val set prediction: {correct}/{len(labs)} correct")

    # List each validation prediction
    for (path, label), pred in zip(val_items, preds):
        print(f"{path.name} | label={label} | pred={pred} ({CLASSES[pred]})")

    # Also show one sample detail for quick check
    sample_path = val_items[0][0] if val_items else train_loader.dataset.items[0][0]
    pred, prob = predict_one(model, sample_path, test_tf, device)
    print(f"Example sample: {sample_path}")
    print(f"Predicted class: {pred} ({CLASSES[pred]}) with prob {prob:.2f}")


if __name__ == "__main__":
    main()
