%% 00_parameters.m
% Single source of truth for the penetration-drive kinematic chain.
% Units: SI (N, m, rad/s, kg) unless noted.
% Inspired by MWDR (Liu et al., Adv. Space Res. 2025) cable + movable-pulley design.

clear; clc;

%% --- Motor (Maxon EC-60 class) ---
p.tau_m_nom   = 0.18;                 % N·m continuous (example)
p.omega_m_nom = 5000 * 2*pi/60;       % rad/s  (~5000 rpm no-load class)
p.I_m_nom     = 3.5;                  % A

%% --- Gearbox (GP-52C) ---
p.n_g         = 113;                  % reduction ratio (paper)
p.eta_g       = 0.80;                 % realistic efficiency at this ratio

%% --- Cable reel / winch ---
p.r_w         = 0.030;                % m  (30 mm radius example)

%% --- Movable-pulley mechanical advantage ---
% Paper: "a pair of movable pulleys ... to amplify the drag force"
p.n_p         = 2;                    % ideal advantage of the movable pair
p.eta_p       = 0.92;                 % pulley efficiency (cable friction + bending)

%% --- Derived kinematic gains (exact algebraic map) ---
p.K_force     = p.n_g * p.n_p * p.eta_g * p.eta_p / p.r_w;   % N / (N·m)
p.K_vel       = p.r_w / (p.n_g * p.n_p);                     % (m/s) / (rad/s)

%% --- Linear plant (moving platform + partial string) ---
p.m_carriage  = 3.5;                  % kg
p.b_viscous   = 25;                   % N·s/m
p.F_load_nom  = 30;                   % N  typical cutting resistance (asteroid regolith)

%% --- Simulation ---
p.Ts          = 1e-3;                 % s
p.T_end       = 15;                   % s

%% --- Arduino interface (PWM scale) ---
p.PWM_max     = 255;
p.V_bus       = 24;                   % V

save('../data/parameters.mat','p');
fprintf('Parameters saved.\n');
fprintf('  K_force = %.1f N per N·m\n', p.K_force);
fprintf('  K_vel   = %.6f (m/s) per (rad/s)\n', p.K_vel);
fprintf('  Example: 0.1 N·m motor torque → %.1f N axial force\n',...
        0.1 * p.K_force);