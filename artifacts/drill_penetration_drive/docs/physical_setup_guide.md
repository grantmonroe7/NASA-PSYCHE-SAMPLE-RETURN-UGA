# Physical Setup Guide – Penetration Drive Hardware

This guide describes how to assemble a laboratory / breadboard version of the cable-reel + movable-pulley penetration drive that matches the model and Arduino firmware.

## 1. Bill of Materials (typical)

| Item | Example / Notes | Qty |
|------|------------------|-----|
| Motor | Maxon EC-60 flat or equivalent BLDC / brushed DC with encoder | 1 |
| Gearbox | Planetary, ~100:1 (GP-52C class or similar) | 1 |
| Motor driver | ESCON, ODrive, or simple BTS7960 / L298N for low-power tests | 1 |
| Cable reel / winch drum | 50–60 mm diameter aluminium or 3-D printed, dual-groove for antagonistic cables | 1 |
| Steel cable or high-strength Dyneema | 1–1.5 mm diameter | ~4 m |
| Fixed pulleys | Ball-bearing, matching cable diameter | 2 |
| Movable pulleys | Same as above, mounted on moving platform | 2 |
| Linear guides / rails | 2× MGN12 or equivalent, length ≥ stroke | 1 set |
| Moving platform | Aluminium plate or 3-D printed carriage that carries the drill head / rotation unit | 1 |
| Clamp mechanism | 3-jaw or simple parallel gripper driven by a second small motor / servo | 1 |
| Arduino (Uno / Mega / Nano) | Runs `penetration_drive.ino` | 1 |
| Power supply | 24 V (or motor rated voltage), adequate current | 1 |
| Optional | Temperature sensor (NTC / RTD) near motor for cold-start logic | 1 |

## 2. Mechanical Assembly Steps

1. Mount the motor + gearbox so the output shaft is parallel to the desired cable-reel axis.
2. Attach the cable reel firmly to the gearbox output (set-screw or keyed hub).
3. Route the two antagonistic cables:
   - Cable A winds onto the reel when the motor turns “forward”.
   - Cable B winds when the motor turns “reverse”.
4. Pass each cable over a fixed pulley (direction change) then under/over a movable pulley on the carriage.
5. Terminate the free ends of the cables on the frame (or on a tensioning adjustment).
6. Mount the carriage on the linear guides; verify smooth travel over the full stroke.
7. Attach the clamp assembly to the carriage (or to a fixed location that can grip the drill pipe).
8. Verify that a positive motor rotation produces the expected direction of carriage motion and that the movable-pulley arrangement multiplies force as designed.

## 3. Electrical Wiring

```
Arduino                Motor Driver              Motor / Sensors
---------              ------------              ---------------
PWM pin 9      ----->  PWM / Speed input
DIR  pin 8      ----->  Direction input
GND             ----->  GND
5 V / 3.3 V     ----->  Logic supply (if needed)

Encoder A (pin 2) <---  Encoder A
Encoder B (pin 3) <---  Encoder B

(Optional) Analog pin <--- Temperature sensor
```

Power the motor driver from the main 24 V supply; keep Arduino logic ground common with the driver.

## 4. Firmware & First Motion

1. Flash `arduino/penetration_drive.ino`.
2. Open serial monitor at 115200 baud.
3. Send `T 0.2` (20 % torque) – carriage should move slowly in the forward direction.
4. Send `T 0` to stop.
5. Send a negative value or implement a direction command to reverse.
6. Confirm encoder telemetry (`X <meters>`) changes with motion.

## 5. Integration with MATLAB Autonomy

- Keep the same serial protocol.
- From MATLAB, open a serialport object and call the same command strings that the master sequence would issue.
- For closed-loop force or position, stream the Arduino telemetry back into a Simulink “From Serial” or MATLAB script.

## 6. Safety Notes

- Always start with very low torque commands.
- Provide a physical emergency-stop that cuts motor power.
- Ensure cables cannot jump the pulley grooves under load.
- In a vacuum / thermal-vacuum chamber, verify lubrication and out-gassing compatibility before long runs.

## 7. Next Hardware Steps

- Add a second motor + driver for the clamp.
- Add limit switches or soft-stops at both ends of travel.
- Mount a load cell in the cable path for direct force feedback.
- Replace the Arduino with a more capable real-time target (or keep Arduino as a low-level driver under a higher-level computer).