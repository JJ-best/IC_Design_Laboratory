"""
Masked Autoencoder (MAE) pretraining + optional linear probe on local images.
Dataset: PNG files in Final_Project/input_image, filenames with label_X for probe.

Run:
    py -3 mask_auto_encoder.py            # MAE pretrain only (no probe if labels missing)
    py -3 mask_auto_encoder.py --probe    # MAE pretrain + linear probe
"""

from __future__ import annotations

import argparse
import random
import re
from pathlib import Path
from typing import List, Tuple

import torch
from PIL import Image
from torch import nn
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms
from vit_pytorch.mae import MAE


CLASSES = ["airplane", "automobile", "bird", "cat", "deer", "dog", "frog", "horse", "ship", "truck"]
LABEL_RE = re.compile(r"label_(\d+)")
IMG_SIZE = 32


def find_data_root(name: str = "input_image", max_levels: int = 5) -> Path:
    cwd = Path.cwd().resolve()
    search_roots = [cwd] + list(cwd.parents)[:max_levels]
    for root in search_roots:
        for cand in (root / name, root / "Final_Project" / name):
            if cand.exists():
                return cand.resolve()
    raise FileNotFoundError(f"{name} not found near {cwd}")


class ImageOnly(Dataset):
    def __init__(self, paths: List[Path], transform):
        self.paths = paths
        self.transform = transform

    def __len__(self) -> int:
        return len(self.paths)

    def __getitem__(self, idx: int):
        img = Image.open(self.paths[idx]).convert("RGB")
        return self.transform(img)


class ImageWithLabel(Dataset):
    def __init__(self, items: List[Tuple[Path, int]], transform):
        self.items = items
        self.transform = transform

    def __len__(self) -> int:
        return len(self.items)

    def __getitem__(self, idx: int):
        path, label = self.items[idx]
        img = Image.open(path).convert("RGB")
        return self.transform(img), label


def load_all_images(root: Path) -> List[Path]:
    paths = sorted(root.glob("*.png"))
    if not paths:
        raise RuntimeError(f"No png files in {root}")
    return [p.resolve() for p in paths]


def load_labeled(root: Path) -> List[Tuple[Path, int]]:
    items = []
    for p in sorted(root.glob("*.png")):
        m = LABEL_RE.search(p.name)
        if m:
            items.append((p.resolve(), int(m.group(1))))
    return items


def make_transforms(img_size: int = IMG_SIZE):
    tf_mae = transforms.Compose(
        [
            transforms.Resize((img_size, img_size)),
            transforms.ToTensor(),
        ]
    )
    tf_probe = transforms.Compose(
        [
            transforms.Resize((img_size, img_size)),
            transforms.ToTensor(),
        ]
    )
    return tf_mae, tf_probe


def build_mae():
    return MAE(
        encoder_dim=128,
        encoder_depth=6,
        encoder_heads=4,
        encoder_dim_head=64,
        decoder_dim=64,
        decoder_depth=4,
        decoder_heads=4,
        decoder_dim_head=32,
        mask_ratio=0.75,
        image_size=IMG_SIZE,
        patch_size=4,
    )


def pretrain(mae, loader, device, epochs=10, lr=3e-4):
    opt = torch.optim.Adam(mae.parameters(), lr=lr)
    for epoch in range(epochs):
        mae.train()
        total = 0.0
        for imgs in loader:
            imgs = imgs.to(device)
            loss = mae(imgs)
            opt.zero_grad()
            loss.backward()
            opt.step()
            total += loss.item()
        print(f"mae epoch {epoch+1}/{epochs} loss {total/len(loader):.4f}")


def linear_probe(mae, loader, device, epochs=5, lr=1e-3):
    # freeze encoder
    for p in mae.encoder.parameters():
        p.requires_grad = False
    head = nn.Linear(128, len(CLASSES)).to(device)
    opt = torch.optim.Adam(head.parameters(), lr=lr)
    crit = nn.CrossEntropyLoss()

    def encode(imgs):
        tokens = mae.encoder(imgs)  # (B, tokens, dim)
        return tokens.mean(dim=1)

    for epoch in range(epochs):
        head.train()
        total_loss = total_correct = total = 0
        for imgs, labels in loader:
            imgs, labels = imgs.to(device), labels.to(device)
            feats = encode(imgs)
            logits = head(feats)
            loss = crit(logits, labels)
            opt.zero_grad()
            loss.backward()
            opt.step()
            total_loss += loss.item()
            total_correct += (logits.argmax(1) == labels).sum().item()
            total += labels.size(0)
        print(f"probe epoch {epoch+1}/{epochs} loss {total_loss/len(loader):.4f} acc {total_correct/total:.3f}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--probe", action="store_true", help="run linear probe after MAE pretrain")
    parser.add_argument("--epochs", type=int, default=10, help="MAE pretrain epochs")
    parser.add_argument("--probe-epochs", type=int, default=5, help="linear probe epochs")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    torch.manual_seed(args.seed)
    random.seed(args.seed)

    data_root = find_data_root()
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print("data root:", data_root)
    print("device:", device)

    tf_mae, tf_probe = make_transforms()
    all_paths = load_all_images(data_root)
    mae_ds = ImageOnly(all_paths, tf_mae)
    mae_loader = DataLoader(mae_ds, batch_size=64, shuffle=True, num_workers=0)

    mae = build_mae().to(device)
    pretrain(mae, mae_loader, device, epochs=args.epochs)

    if args.probe:
        labeled_items = load_labeled(data_root)
        if not labeled_items:
            print("No labels found in filenames; skip probe.")
            return
        probe_ds = ImageWithLabel(labeled_items, tf_probe)
        probe_loader = DataLoader(probe_ds, batch_size=64, shuffle=True, num_workers=0)
        linear_probe(mae, probe_loader, device, epochs=args.probe_epochs)


if __name__ == "__main__":
    main()
