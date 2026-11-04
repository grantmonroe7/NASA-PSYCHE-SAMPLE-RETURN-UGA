# Simulation Overview – Isaac Drill Sim

## Goal
Provide a high-fidelity, interactive 3-D digital twin of the entire drilling robot so that the autonomous sequences developed in the MATLAB/Arduino package can be visualised, debugged, and extended before hardware is available.

## Mapping from Physical / MATLAB Domain

| MATLAB / Physical Concept | Isaac Sim Representation |
|---------------------------|--------------------------|
| Penetration motor + gearbox + cable reel | Articulation root or revolute joint with effort/velocity control |
| Movable-pulley force amplification | Either (a) tendon/cable system or (b) scaled prismatic joint whose force/velocity ratio matches \(K_F\) / \(K_v\) |
| Linear guides + carriage | Prismatic joint with realistic mass and damping |
| Top / bottom clamps | Parallel-gripper or three-jaw articulation with effort limits |
| Rotation unit | Revolute joint on the carriage |
| Autonomous sequence (cold-start → clamp → mode → extract) | Python script or Omnigraph Action Graph that issues the same command stream |
| Encoder / force feedback | Isaac sensors or joint-state publishers |

## Gravity & Environment
- Default: lunar or asteroid-scale gravity (configurable in `configs/`).
- Optional regolith bed (particle system or static mesh with friction).
- Thermal effects are not simulated in the first version; cold-start is treated as a timed low-effort motion only.

## Autonomy Playback
A thin Python layer will:
1. Load the same mode parameters used by `05_mode_sequences.m`.
2. Step through the master sequence, commanding joint efforts or velocities.
3. Log joint states and any contact forces for later comparison with Simulink.

This keeps the two drives synchronised: any change to the MATLAB sequencing logic can be mirrored here with minimal effort.