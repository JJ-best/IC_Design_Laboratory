from pathlib import Path

from PIL import Image
import numpy as np
import time

# ----- import python function ----- #
from init_map import initial_map
from alm import lime_trial
from gamma_corr import gamma_corr

# file paths (project root based)
root = Path(__file__).resolve().parents[1]
img_path = root / "imgs" / "building.bmp"
illum_out = root / "imgs" / "building_illum.bmp"
illum_refined_out = root / "imgs" / "building_illum_refined.bmp"
illum_gamma_out = root / "imgs" / "building_illum_gamma.bmp"
enhanced_out = root / "imgs" / "building_enhanced.bmp"
rgb_out = root / "imgs" / "building_out.bmp"

t0 = time.perf_counter()
# normalize to [0,1]
img = Image.open(img_path).convert("RGB")
arr = np.asarray(img, dtype=np.float64) / 255.0
print("image size: ", arr.shape)
# ----- initialize illumination map ----- #
illum = initial_map(arr)
print("initial illu map size: ", illum.shape)
illum_img = Image.fromarray((illum * 255).astype(np.uint8), mode="L")
illum_img.save(illum_out)

# ----- Augmented Lagrange Multiplier (lime_trial) ----- #
alpha = 0.08
mu0 = 0.01
rho = 1.2
gamma = 0.8
Tout = lime_trial(illum, alpha=alpha, mu0=mu0, rho=rho, k0=1)

# refine to [0,1], save
Tout_clipped = np.clip(np.abs(Tout), 0, 1)
Tout_img = Image.fromarray((Tout_clipped * 255).astype(np.uint8), mode="L")
Tout_img.save(illum_refined_out)

# ----- Gamma Correction ----- #
Tout_gamma = gamma_corr(Tout_clipped, gamma)
Tout_gamma_img = Image.fromarray((np.clip(Tout_gamma, 0, 1) * 255).astype(np.uint8), mode="L")
Tout_gamma_img.save(illum_gamma_out)

# ----- Enhance image by dividing input with gamma-corrected illumination ----- #
T3 = np.stack([np.clip(Tout_gamma, 1e-6, 1.0)] * 3, axis=2)
img_enhanced = np.clip(arr / T3, 0, 1) # dot division RGB channel image
enhanced_img = Image.fromarray((img_enhanced * 255).astype(np.uint8), mode="RGB")
enhanced_img.save(enhanced_out)

# also save the normalized input back (for reference)
out = Image.fromarray((np.clip(arr, 0, 1) * 255).astype(np.uint8), mode="RGB")
out.save(rgb_out)

t1 = time.perf_counter()
print("execution time: {:.6f} s".format(t1 - t0))
