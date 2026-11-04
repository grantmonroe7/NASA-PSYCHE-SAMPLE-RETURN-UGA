# Requirements – Penetration Drive Subsystem

## REQ-PEN-001  Functional
The system shall convert motor torque into amplified axial force at the drill string via a cable-reel and movable-pulley transmission.

## REQ-PEN-002  Kinematic
The force and velocity mapping shall obey:
  F_drill = (n_g * n_p * η_g * η_p / r_w) * τ_m
  v_drill = (r_w / (n_g * n_p)) * ω_m

## REQ-PEN-003  Stroke
The linear stroke shall be sufficient for at least one full drill-pipe length (typical 0.5–1.0 m) without reconfiguration.

## REQ-PEN-004  Low-g Operation
The force command shall be active (not gravity-dependent) so that the same hardware can operate on bodies with surface gravity from ~0.0001 g to 0.16 g.

## REQ-PEN-005  Interface
An Arduino-class microcontroller shall be able to command the motor driver via PWM + direction and optionally close a position/velocity loop using the motor encoder.

## REQ-PEN-006  Traceability
All numeric parameters shall reside in a single MATLAB script (00_parameters.m) that is the sole source of truth for both simulation and firmware constants.