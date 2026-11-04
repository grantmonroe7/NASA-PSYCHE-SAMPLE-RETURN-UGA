#!/usr/bin/env python3
"""
Surface / multivariable plots:
  1. Axial force vs motor torque vs pulley advantage (K_F relation)
  2. Temperature rise vs power & time
  3. Thermal deflection vs ΔT & member length
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from pathlib import Path

OUT = Path(__file__).parent.parent / "output"
OUT.mkdir(parents=True, exist_ok=True)

def plot_force_surface():
    tau = np.linspace(0.02, 0.20, 40)          # N·m
    n_p = np.linspace(1.0, 4.0, 40)            # pulley MA
    TAU, NP = np.meshgrid(tau, n_p)
    n_g, eta_g, eta_p, r_w = 113, 0.80, 0.92, 0.030
    KF = n_g * NP * eta_g * eta_p / r_w
    F = KF * TAU

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection='3d')
    surf = ax.plot_surface(TAU, NP, F, cmap='viridis', edgecolor='none', alpha=0.9)
    ax.set_xlabel('Motor torque τ (N·m)')
    ax.set_ylabel('Pulley MA n_p')
    ax.set_zlabel('Axial force F (N)')
    ax.set_title('Drill Axial Force vs Torque & Pulley Advantage')
    fig.colorbar(surf, shrink=0.6, label='F (N)')
    fig.savefig(OUT / "surface_force_vs_tau_np.png", dpi=150)
    print(f"Saved surface_force_vs_tau_np.png")
    plt.close()

def plot_temp_surface():
    P = np.linspace(2, 40, 40)                 # W
    t = np.linspace(10, 300, 40)               # s
    PP, TT = np.meshgrid(P, t)
    Cth, Rth, T0 = 80.0, 15.0, 150.0
    # Steady-state approach: ΔT_ss = P*Rth; T(t) = T0 + ΔT_ss*(1-exp(-t/(Rth*Cth)))
    tau_th = Rth * Cth
    dT = (PP * Rth) * (1 - np.exp(-TT / tau_th))
    T = T0 + dT

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection='3d')
    surf = ax.plot_surface(PP, TT, T, cmap='hot', edgecolor='none', alpha=0.9)
    ax.set_xlabel('Power (W)')
    ax.set_ylabel('Time (s)')
    ax.set_zlabel('Temperature (K)')
    ax.set_title('Motor/Bit Temperature vs Power & Time')
    fig.colorbar(surf, shrink=0.6, label='T (K)')
    fig.savefig(OUT / "surface_temp_vs_power_time.png", dpi=150)
    print(f"Saved surface_temp_vs_power_time.png")
    plt.close()

def plot_deflection_surface():
    dT = np.linspace(0, 120, 40)               # K
    L = np.linspace(0.2, 1.2, 40)              # m
    DT, LL = np.meshgrid(dT, L)
    alpha = 8.6e-6                             # Ti-6Al-4V
    delta_um = alpha * LL * DT * 1e6

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection='3d')
    surf = ax.plot_surface(DT, LL, delta_um, cmap='coolwarm', edgecolor='none', alpha=0.9)
    ax.set_xlabel('ΔT (K)')
    ax.set_ylabel('Length (m)')
    ax.set_zlabel('Expansion (µm)')
    ax.set_title('Thermal Expansion of Ti-6Al-4V Member')
    fig.colorbar(surf, shrink=0.6, label='ΔL (µm)')
    fig.savefig(OUT / "surface_deflection_vs_dT_L.png", dpi=150)
    print(f"Saved surface_deflection_vs_dT_L.png")
    plt.close()

if __name__ == "__main__":
    plot_force_surface()
    plot_temp_surface()
    plot_deflection_surface()
    print("All surface plots generated.")