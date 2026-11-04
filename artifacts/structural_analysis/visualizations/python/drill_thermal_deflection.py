#!/usr/bin/env python3
"""
Time-domain visualization of:
  - Drill axial force & velocity during a master sequence (LVHT example)
  - Bit / motor temperature rise
  - Simple thermal deflection of a representative structural member

Saves multi-panel figures to visualizations/output/.
"""

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

OUT = Path(__file__).parent.parent / "output"
OUT.mkdir(parents=True, exist_ok=True)

# --- Parameters (aligned with 00_parameters.m / engineering_data) ---
dt = 0.05
t_end = 180.0
t = np.arange(0, t_end, dt)

# Sequence timeline (seconds)
t_cold = 40.0
t_clamp = 50.0
t_drill = 120.0
t_extract = 160.0

# Force / velocity profiles (simplified)
F = np.zeros_like(t)
V = np.zeros_like(t)
for i, ti in enumerate(t):
    if ti < t_cold:
        F[i] = 5 * np.sin(2*np.pi*0.5*ti)**2          # low-duty jog
        V[i] = 0.001 * np.sign(np.sin(2*np.pi*0.5*ti))
    elif ti < t_clamp:
        F[i] = 0
        V[i] = 0
    elif ti < t_drill:
        # LVHT-like
        F[i] = 70 + 10*np.sin(2*np.pi*0.1*(ti-t_clamp))
        V[i] = 0.0008
    elif ti < t_extract:
        F[i] = -30
        V[i] = -0.0015
    else:
        F[i] = 0
        V[i] = 0

# Simple thermal model: heat input proportional to |F|*|V| + motor losses
# T' = (P_in - (T-T0)/Rth) / Cth
T0 = 150.0          # K  cold start
Cth = 80.0          # J/K  effective
Rth = 15.0          # K/W
P_motor_base = 8.0  # W during drilling
T = np.zeros_like(t)
T[0] = T0
for i in range(1, len(t)):
    Pin = P_motor_base * (abs(F[i]) > 20) + 0.02 * abs(F[i]*V[i])*1000
    dT = (Pin - (T[i-1]-T0)/Rth) / Cth * dt
    T[i] = T[i-1] + dT

# Simple thermal deflection of a Ti-6Al-4V beam (ΔL = α L ΔT)
alpha = 8.6e-6
L0 = 0.6            # m  representative member length
delta = alpha * L0 * (T - T0) * 1e6   # µm

# --- Plots ---
fig, axes = plt.subplots(4, 1, figsize=(11, 10), sharex=True)

axes[0].plot(t, F, 'b')
axes[0].set_ylabel('Axial Force (N)')
axes[0].set_title('Drill Master Sequence – Force, Velocity, Temperature, Deflection')
axes[0].axvline(t_cold, color='k', ls='--', alpha=0.4)
axes[0].axvline(t_clamp, color='k', ls='--', alpha=0.4)
axes[0].axvline(t_drill, color='k', ls='--', alpha=0.4)
axes[0].axvline(t_extract, color='k', ls='--', alpha=0.4)
axes[0].text(10, 60, 'Cold-start', fontsize=8)
axes[0].text(55, 60, 'Clamp', fontsize=8)
axes[0].text(80, 60, 'LVHT Drill', fontsize=8)
axes[0].text(130, 60, 'Extract', fontsize=8)
axes[0].grid(True, alpha=0.3)

axes[1].plot(t, V*1000, 'g')
axes[1].set_ylabel('Velocity (mm/s)')
axes[1].grid(True, alpha=0.3)

axes[2].plot(t, T, 'r')
axes[2].set_ylabel('Temp (K)')
axes[2].grid(True, alpha=0.3)

axes[3].plot(t, delta, 'm')
axes[3].set_ylabel('Thermal ΔL (µm)')
axes[3].set_xlabel('Time (s)')
axes[3].grid(True, alpha=0.3)

plt.tight_layout()
fig.savefig(OUT / "drill_thermal_deflection_time.png", dpi=150)
print(f"Saved {OUT / 'drill_thermal_deflection_time.png'}")
plt.close()