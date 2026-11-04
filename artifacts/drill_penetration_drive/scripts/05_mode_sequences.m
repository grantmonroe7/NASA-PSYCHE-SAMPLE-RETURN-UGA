%% 05_mode_sequences.m
% Motor sequencing for three primary drilling regimes + extraction reverses.
% Inspired by planetary rotary / rotary-percussive / high-speed practices
% (USDC, Auto-Gopher, ExoMars, MWDR control papers, Honeybee Trident, etc.)

function mode_sequences()
    load('../data/parameters.mat');

    fprintf('=== Available Drilling Modes ===\n');
    fprintf('1. LVHT  – Low Velocity High Torque  (hard / metal-rich / compacted)\n');
    fprintf('2. PERC  – Percussive-assist         (brittle / icy / fractured)\n');
    fprintf('3. HSPD  – High Speed                (loose regolith / chip clearing)\n');
    fprintf('4. EXTRACT_LVHT / EXTRACT_PERC / EXTRACT_HSPD  (reverse sequences)\n\n');
end

%% ------------------------------------------------------------------
%% 1. Low-Velocity High-Torque (LVHT)
%% ------------------------------------------------------------------
function seq = seq_LVHT()
    % High gearbox torque, low linear speed – maximises force via K_force
    seq.name        = 'LVHT';
    seq.tau_m       = 0.16;          % N·m  near continuous rating
    seq.omega_m     = 800 * 2*pi/60; % rad/s  (~800 rpm motor)
    seq.n_p_eff     = 2;             % keep full pulley advantage
    seq.duration    = 30;            % s per segment
    seq.desc        = 'Low velocity, high axial force for dense / metallic targets';
end

%% ------------------------------------------------------------------
%% 2. Percussive-assist (simulated by rapid torque pulsing)
%% ------------------------------------------------------------------
function seq = seq_PERC()
    % Rapid on/off or low-amplitude oscillation of penetration force
    % mimics the effect of a mechanical percussive mechanism
    seq.name        = 'PERC';
    seq.tau_m_base  = 0.08;
    seq.tau_m_pulse = 0.18;          % peak during “impact”
    seq.pulse_freq  = 15;            % Hz  (typical planetary percussive range 10-40 Hz)
    seq.omega_m     = 1200 * 2*pi/60;
    seq.duration    = 20;
    seq.desc        = 'Pulsed force for brittle / icy / fractured media';
end

%% ------------------------------------------------------------------
%% 3. High-Speed (HSPD)
%% ------------------------------------------------------------------
function seq = seq_HSPD()
    % Higher motor speed, reduced effective torque demand
    seq.name        = 'HSPD';
    seq.tau_m       = 0.06;
    seq.omega_m     = 3500 * 2*pi/60; % higher rpm
    seq.n_p_eff     = 1;             % optional: reduce MA for speed (if reconfigurable)
    seq.duration    = 15;
    seq.desc        = 'High linear speed for loose regolith and chip evacuation';
end

%% ------------------------------------------------------------------
%% Extraction sequences (motor reverse + coordinated retract)
%% ------------------------------------------------------------------
function seq = seq_EXTRACT(mode)
    % Common extraction pattern observed in MWDR & multi-string literature:
    % 1. Stop penetration / rotation
    % 2. Reverse rotation (unthread if needed)
    % 3. Retract (reverse cable reel) at controlled speed
    % 4. Optionally pulse for stuck-pipe recovery
    base = feval(['seq_' upper(mode)]);
    seq = base;
    seq.name      = ['EXTRACT_' upper(mode)];
    seq.tau_m     = -abs(base.tau_m) * 0.7;   % reverse, reduced magnitude
    seq.omega_m   = -abs(base.omega_m) * 0.5;
    seq.desc      = ['Reverse of ' upper(mode) ' – unthread + retract'];
end

%% Example caller
function run_example()
    mode_sequences();
    s1 = seq_LVHT();
    s2 = seq_PERC();
    s3 = seq_HSPD();
    s4 = seq_EXTRACT('LVHT');
    disp(s1); disp(s2); disp(s3); disp(s4);
end