# Design Description – Penetration Drive

## 1. Reference Mechanism (MWDR paper, Sec. 3.1.1)
The penetration unit is **cable-driven**:
- Penetration motor + gearbox drives a **cable reel**.
- Two steel cables are wound antagonistically on the reel.
- Two **fixed pulleys** change cable direction.
- Two **movable pulleys** ride on the moving platform and provide **mechanical advantage** (force amplification).
- Moving platform is guided by linear rails and carries the rotation unit + top clamping unit.

When the reel rotates one direction, one cable is paid-in and the other paid-out → platform translates. Reverse rotation reverses the motion.

## 2. Motor & Gearbox (paper data)
- Motor: Maxon EC-60 flat
- Gearbox: GP-52C, reduction ratio \( n_g = 113 \)
- Encoder: 4096 CPT (flat version)

## 3. Kinematic / Force Amplification Equations

### Motor
\[
\tau_m,\quad \omega_m
\]

### Gearbox (efficiency \(\eta_g\))
\[
\tau_g = n_g\,\tau_m\,\eta_g,\qquad
\omega_g = \frac{\omega_m}{n_g}
\]

### Cable reel (radius \( r_w \))
\[
F_\text{cable} = \frac{\tau_g}{r_w},\qquad
v_\text{cable} = \omega_g\,r_w
\]

### Movable-pulley system (mechanical advantage \( n_p \), efficiency \(\eta_p\))
For a classic movable-pulley pair the ideal advantage is 2.  
With two movable pulleys and proper reeving the effective advantage is typically 2–4.
\[
F_\text{drill} = n_p\,F_\text{cable}\,\eta_p = \left(n_g n_p\frac{\eta_g\eta_p}{r_w}\right)\tau_m
\]
\[
v_\text{drill} = \frac{v_\text{cable}}{n_p} = \left(\frac{r_w}{n_g n_p}\right)\omega_m
\]

### Combined gain constants used in the model
\[
K_F = n_g n_p\frac{\eta_g\eta_p}{r_w}\quad\text{(N per N·m)}
\]
\[
K_v = \frac{r_w}{n_g n_p}\quad\text{(m/s per rad/s)}
\]

These two scalars completely map motor torque/speed into drill axial force/velocity under the quasi-static assumption.

## 4. Low-Gravity Considerations
On an asteroid the “weight-on-bit” is an **active force command**, not gravity. The plant therefore treats \( F_\text{drill} \) as a controlled output that must overcome cutting resistance + friction. The linear plant is simply
\[
m\ddot{x} + b\dot{x} = F_\text{drill} - F_\text{load}
\]
where \( m \) is the moving mass (platform + partial drill string) and \( b \) is equivalent viscous damping.

## 5. Arduino Role
Arduino (or Arduino-compatible) generates PWM + DIR signals to a motor driver that powers the Maxon (or equivalent) motor. Encoder A/B (and optional index) are read for closed-loop position or velocity control. Serial (or CAN) telemetry streams measured position/velocity back to the Simulink plant for HIL.

## 6. Robust Operational Sequencing

### 6.1 Cold-Start Jog (script 04)
In permanently shadowed regions or lunar night the actuator may sit below the grease pour-point (~213 K). Literature (NASA MDECE project, Tang et al. lunar-drill thermal network) shows that pure resistive heaters consume precious power. A low-duty-cycle, low-torque jog dissipates motor copper and gearbox friction losses internally, raising temperature with almost zero net external force (the pulley gain still applies but commanded torque is kept tiny). Typical parameters: 20–50 mN·m, 25–40 % duty, 1–3 minutes.

### 6.2 Drilling Modes (script 05)
Three canonical regimes used across planetary drills:

| Mode | Intent | Motor side | Notes |
|------|--------|------------|-------|
| LVHT | Dense / metallic / compacted | High τ, low ω | Maximises axial force via \(K_F\) |
| PERC | Brittle / icy / fractured | Pulsed τ at 10–40 Hz | Software emulation of mechanical percussion |
| HSPD | Loose regolith / chip clearing | Lower τ, high ω | Optionally reduced pulley MA for speed |

### 6.3 Extraction (reverse of each mode)
Follows MWDR and multi-string practice:
1. Halt forward motion
2. Reverse rotation (unthread if threaded joints)
3. Retract cable reel at controlled (usually lower) speed
4. Optional low-amplitude pulses for stuck-pipe recovery

### 6.4 Clamping Sequence (script 06)
Top clamp (and optionally bottom) must be closed before rotation is enabled and opened only after extraction. Sequence:
- Position approach (low current)
- Torque ramp to grip force (current-limited to protect pipe)
- Hold
- Reverse for open

Coordinated with penetration via the master orchestrator (script 07).