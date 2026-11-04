#!/usr/bin/env python3
"""
Thermal skin-depth and simple 1-D temperature profile estimator
for (16) Psyche surface layers.

Analytical method:
  Thermal diffusivity κ = k / (ρ c)
  Diurnal skin depth δ = sqrt(κ P / π)   where P = rotation period
  Temperature amplitude decays as exp(-z/δ)
"""

import math

# Approximate material properties (order-of-magnitude)
# Fine silicate regolith (low TI)
props_silicate = dict(k=0.01, rho=1500, c=700)   # W/mK, kg/m3, J/kgK
# Metal-rich porous (higher conductivity)
props_metalish = dict(k=1.0, rho=3500, c=500)

P_rot = 4.2 * 3600  # s  (~4.2 h rotation)

def skin_depth(k, rho, c, P):
    kappa = k / (rho * c)
    return math.sqrt(kappa * P / math.pi)

def amplitude_ratio(z, delta):
    return math.exp(-z / delta)

if __name__ == "__main__":
    print("=== Psyche Thermal Skin Depth Estimates ===\n")
    for name, p in [("Fine silicate regolith", props_silicate),
                    ("Metal-rich porous", props_metalish)]:
        delta = skin_depth(p["k"], p["rho"], p["c"], P_rot)
        print(f"{name}:")
        print(f"  Diffusivity κ ≈ {p['k']/(p['rho']*p['c']):.2e} m²/s")
        print(f"  Diurnal skin depth δ ≈ {delta*100:.1f} cm")
        for z_cm in [1, 5, 10, 50]:
            r = amplitude_ratio(z_cm/100, delta)
            print(f"    Amplitude at {z_cm:2d} cm: {r*100:.1f} % of surface")
        print()