# Isaac Drill Sim – Full-System Robotic Simulation

Parallel simulation drive for the complete multi-string wireline-coring drilling robot (MWDR-inspired) using NVIDIA Isaac Sim / Omniverse.

This package is intended to host:
- USD assets of the full mechanical structure (frame, penetration unit, rotation unit, clamps, manipulator, rotary magazine, wireline catcher).
- Physics-enabled joints and articulations that mirror the real cable-reel + movable-pulley kinematics.
- Action graphs / Python scripts that replay the same autonomous sequences developed in the MATLAB/Arduino drive (`cold-start → clamp → LVHT/PERC/HSPD → extract → unclamp`).
- Sensor simulation (encoders, force, optional camera) and domain-randomised environments (regolith, low-g, thermal).

## Directory Layout

| Path | Purpose |
|------|---------|
| `assets/` | Meshes, materials, textures |
| `usd/` | Assembled USD / USDA scenes and robot description |
| `configs/` | YAML / JSON configuration (gravity, friction, mode parameters) |
| `scripts/` | Python (Isaac) launchers, action-graph helpers, sequence players |
| `docs/` | Simulation-specific notes and mapping to the physical/MATLAB drive |
| `logs/` | Runtime logs and recorded trajectories |

## Relationship to the MATLAB / Arduino Drive

The MATLAB package (`../drill_penetration_drive/`) remains the authoritative source for:
- Numeric parameters (`00_parameters.m`)
- Mode definitions and sequencing logic
- Arduino firmware behaviour

This Isaac package consumes those same numbers (exported or hard-coded from the parameter file) so that a sequence exercised in MATLAB produces visually and physically consistent behaviour in the 3-D simulation.

## Next Steps (to be populated)

1. Import or model the frame + penetration unit as a USD articulation.
2. Implement a cable / tendon or approximate prismatic joint that realises the pulley mechanical advantage.
3. Create an Action Graph or Python controller that accepts the same high-level commands (`cold_start`, `clamp_close`, `mode_LVHT`, `extract`, …).
4. Add a simple regolith particle or deformable body for basic interaction tests.
5. Record and compare force / position trajectories against the Simulink plant.