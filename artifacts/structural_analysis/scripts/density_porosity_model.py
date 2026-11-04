#!/usr/bin/env python3
"""
Simple three-component mixing model for Psyche bulk density.

ρ_bulk = (1 - φ) * (f_m * ρ_m + (1 - f_m) * ρ_s)

Solves for metal volume fraction f_m or porosity φ given the other.
"""

def bulk_density(f_metal, porosity, rho_metal=7870, rho_silicate=3200):
    """f_metal = volume fraction of metal in the solid part; porosity φ."""
    rho_solid = f_metal * rho_metal + (1 - f_metal) * rho_silicate
    return (1 - porosity) * rho_solid

def required_porosity(rho_bulk, f_metal, rho_metal=7870, rho_silicate=3200):
    rho_solid = f_metal * rho_metal + (1 - f_metal) * rho_silicate
    return 1 - rho_bulk / rho_solid

if __name__ == "__main__":
    print("=== Psyche Density–Porosity Model ===\n")
    targets = [3400, 3780, 4170]  # kg/m³
    for rho in targets:
        print(f"Target bulk density {rho} kg/m³:")
        for fm in [0.3, 0.5, 0.7, 1.0]:
            phi = required_porosity(rho, fm)
            print(f"  Metal vol.frac (solid) {fm:.0%} → porosity {phi*100:.1f} %")
        print()