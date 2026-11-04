#!/usr/bin/env python3
"""
Simple (16) Psyche shape-model visualizer.
Builds an elongated, irregular ellipsoid-like mesh approximating
published radar/shape models and renders a 3-D view + topography-style map.
Saves figures to visualizations/output/.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from pathlib import Path

OUT = Path(__file__).parent.parent / "output"
OUT.mkdir(parents=True, exist_ok=True)

# Approximate semi-axes (km) from published shape models (~280 x 230 x 190 km class)
A, B, C = 140.0, 115.0, 95.0   # km (semi-axes)

def make_psyche_mesh(n_u=80, n_v=40, noise=0.04):
    """Parametric ellipsoid with mild irregularity to look asteroid-like."""
    u = np.linspace(0, 2*np.pi, n_u)
    v = np.linspace(0, np.pi, n_v)
    U, V = np.meshgrid(u, v)

    # Base ellipsoid
    X = A * np.cos(U) * np.sin(V)
    Y = B * np.sin(U) * np.sin(V)
    Z = C * np.cos(V)

    # Add low-order irregularity (craters / ridges approximation)
    r = np.sqrt(X**2 + Y**2 + Z**2)
    perturbation = 1.0 + noise * (
        np.sin(3*U) * np.cos(2*V) +
        0.6 * np.sin(5*U + 1.2) * np.sin(3*V) +
        0.4 * np.cos(2*U) * np.cos(4*V)
    )
    X *= perturbation
    Y *= perturbation
    Z *= perturbation
    return X, Y, Z

def main():
    X, Y, Z = make_psyche_mesh()

    # --- 3-D shape ---
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')
    ax.plot_surface(X, Y, Z, cmap='copper', linewidth=0, antialiased=True, alpha=0.92)
    ax.set_xlabel('X (km)')
    ax.set_ylabel('Y (km)')
    ax.set_zlabel('Z (km)')
    ax.set_title('(16) Psyche – Approximate Shape Model\n(elongated ellipsoid + low-order irregularity)')
    # Equal aspect
    max_range = np.array([X.max()-X.min(), Y.max()-Y.min(), Z.max()-Z.min()]).max() / 2.0
    mid_x = (X.max()+X.min()) * 0.5
    mid_y = (Y.max()+Y.min()) * 0.5
    mid_z = (Z.max()+Z.min()) * 0.5
    ax.set_xlim(mid_x - max_range, mid_x + max_range)
    ax.set_ylim(mid_y - max_range, mid_y + max_range)
    ax.set_zlim(mid_z - max_range, mid_z + max_range)
    plt.tight_layout()
    fig.savefig(OUT / "psyche_shape_3d.png", dpi=150)
    print(f"Saved {OUT / 'psyche_shape_3d.png'}")

    # --- Simple "topographic" radius map (longitude–latitude) ---
    R = np.sqrt(X**2 + Y**2 + Z**2)
    lon = np.linspace(-180, 180, R.shape[1])
    lat = np.linspace(-90, 90, R.shape[0])
    Lon, Lat = np.meshgrid(lon, lat)

    fig2, ax2 = plt.subplots(figsize=(11, 5))
    pcm = ax2.pcolormesh(Lon, Lat, R, cmap='terrain', shading='auto')
    fig2.colorbar(pcm, ax=ax2, label='Radius (km)')
    ax2.set_xlabel('Longitude (deg)')
    ax2.set_ylabel('Latitude (deg)')
    ax2.set_title('(16) Psyche – Radius Map (proxy topography)')
    ax2.set_aspect('equal')
    plt.tight_layout()
    fig2.savefig(OUT / "psyche_radius_map.png", dpi=150)
    print(f"Saved {OUT / 'psyche_radius_map.png'}")

    plt.close('all')

if __name__ == "__main__":
    main()