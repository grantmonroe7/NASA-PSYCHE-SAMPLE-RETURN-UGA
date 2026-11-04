%% 04_cold_start_jog.m
% Low-speed, low-duty-cycle motor jogging to generate internal heat
% before full-power operation in cold environments (asteroid / lunar night / PSR).
%
% Rationale (NASA MDECE / lunar drill thermal literature):
% - Grease-lubricated actuators typically require > ~213 K (-60 °C)
% - Pure heater power is expensive on power-constrained landers
% - Low-speed jogging dissipates I²R and friction losses inside the motor/gearbox
%   and can raise temperature without producing significant external torque/force
%
% References:
% - NASA "Impacts of Heating Actuators in Extremely Cold Space Environments"
% - Tang et al., "Thermal Analysis of the Driving Component ... Lunar Drilling System"
% - MDECE Project (Motors for Dusty & Extremely Cold Environments)

function cold_start_jog(duration_s, duty_cycle)
    if nargin < 1, duration_s = 180; end   % default 3 min
    if nargin < 2, duty_cycle = 0.25; end  % 25 % on-time

    load('../data/parameters.mat');

    fprintf('=== Cold-Start Jog Sequence ===\n');
    fprintf('Duration: %.0f s | Duty: %.0f %%\n', duration_s, duty_cycle*100);
    fprintf('Goal: raise motor/gearbox temperature via internal losses\n\n');

    % Very low torque / speed – enough to overcome static friction but
    % produce negligible net force at the drill (K_force still applies)
    tau_jog   = 0.02;          % N·m  (~10 % of nominal)
    omega_jog = 50 * 2*pi/60;  % rad/s  (~50 rpm motor side)

    t_on  = 2.0;               % seconds on
    t_off = t_on * (1-duty_cycle)/duty_cycle;

    t = 0;
    while t < duration_s
        % ON phase – forward micro-jog
        cmd_torque(tau_jog);
        pause(t_on);
        t = t + t_on;

        % OFF phase – allow thermal diffusion, reduce peak current
        cmd_torque(0);
        pause(t_off);
        t = t + t_off;

        % Optional reverse micro-jog to distribute heat & avoid cable set
        cmd_torque(-tau_jog * 0.5);
        pause(t_on * 0.5);
        t = t + t_on * 0.5;
        cmd_torque(0);
    end

    fprintf('Cold-start jog complete. Ready for mode sequencing.\n');
end

function cmd_torque(tau)
    % Placeholder – replace with serial write to Arduino or Simulink set_param
    % Example: fprintf(s, 'T %.3f\n', tau / p.tau_m_nom);
    fprintf('  CMD torque = %+.3f N·m\n', tau);
end