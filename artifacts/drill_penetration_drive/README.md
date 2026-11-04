# Drill Penetration Drive – Robust Cable/Pulley System

NASA-grade Model-Based Design package for the linear penetration subsystem of a planetary multi-string wireline-coring drilling robot (inspired by MWDR, Advances in Space Research 2025).

## Table of Contents & File Descriptions

| Path | Brief Description |
|------|-------------------|
| **docs/** | |
| `docs/requirements.md` | High-level functional & interface requirements with traceability IDs. |
| `docs/design_description.md` | Kinematic equations, mechanism description, cold-start & mode rationale. |
| `docs/block_diagram.txt` | Text block diagram of the motor → gearbox → pulley → plant chain. |
| `docs/physical_setup_guide.md` | Step-by-step guide to build and wire the physical hardware. |
| **scripts/** | |
| `scripts/00_parameters.m` | Single source of truth for all numeric parameters and derived gains. |
| `scripts/01_build_model.m` | Programmatically builds the Simulink plant model. |
| `scripts/02_run_simulation.m` | Runs the model and plots force / velocity / position. |
| `scripts/03_verify_kinematics.m` | Pure algebraic check of the force/velocity map (no Simulink needed). |
| `scripts/04_cold_start_jog.m` | Low-duty jog sequence to warm grease-lubricated actuators in cold. |
| `scripts/05_mode_sequences.m` | LVHT, PERC, HSPD mode definitions + their reverse (extraction) versions. |
| `scripts/06_clamp_sequence.m` | Torque-limited close / hold / open sequence for the drill-pipe clamp. |
| `scripts/07_master_sequence.m` | Top-level orchestrator: cold-start → clamp → mode → extract → unclamp. |
| **arduino/** | |
| `arduino/penetration_drive.ino` | Firmware: accepts serial torque commands, streams encoder-based position. |
| **models/** | Generated Simulink `.slx` files (created by `01_build_model.m`). |
| **data/** | `parameters.mat` and simulation logs. |
| **tests/** | Placeholder for unit / integration tests. |

## How the System Runs Autonomously

The autonomy stack is deliberately simple and hierarchical so it can run on a radiation-tolerant microcontroller or a small companion computer:

1. **Boot / Health Check**  
   Arduino (or higher-level computer) powers up, reads temperature (if sensor present) and encoder, reports “ready” over serial.

2. **Optional Cold-Start** (`04_cold_start_jog`)  
   If temperature is below a threshold (or always on first power-up in a cold environment), a low-torque, low-duty jog is executed for 1–3 minutes to raise internal motor/gearbox temperature via copper and friction losses.

3. **Clamp** (`06_clamp_sequence`)  
   Top clamp closes under current/torque limit, then switches to hold mode. Rotation and penetration are interlocked until clamp is confirmed closed.

4. **Selected Drilling Mode** (`05_mode_sequences`)  
   Master script calls one of:
   - **LVHT** – high torque, low speed (dense / metallic targets)
   - **PERC** – pulsed force (brittle / icy)
   - **HSPD** – higher speed (loose regolith)
   
   Torque / speed profiles are streamed to the Arduino (or motor driver) for the commanded duration.

5. **Extraction**  
   The reverse of the chosen mode is executed: reverse rotation (unthread) + controlled cable-reel retract.

6. **Unclamp & Idle**  
   Clamp opens, system returns to idle and waits for the next high-level command (or continues the multi-string sequence if more pipes are required).

All of the above is coordinated by `07_master_sequence.m` (or its future compiled / C++ equivalent). The same command set can be issued from a ground station, a higher-level mission planner, or a local state machine on the lander computer. Because every numeric constant lives in `00_parameters.m`, the identical logic can be regenerated for flight software.

## Quick Start (Simulation)
```matlab
cd scripts
run('00_parameters.m');
run('07_master_sequence.m');          # full autonomous cycle, LVHT + cold-start
```

## Related Drive
A parallel Isaac Sim package for full-system robotic simulation lives at:  
`/home/workdir/artifacts/isaac_drill_sim/`

## References (selected)
- Liu et al., “A multi-string and wireline-coring drilling robot…”, Adv. Space Res. 2025.
- NASA MDECE / heating-actuator papers.
- Tang et al., lunar-drill thermal analysis, Energies 2017.
- Planetary rotary-percussive literature (USDC, Auto-Gopher, ExoMars, Mars 2020).
