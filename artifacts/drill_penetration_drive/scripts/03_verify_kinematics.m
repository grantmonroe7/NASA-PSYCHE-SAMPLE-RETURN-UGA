%% 03_verify_kinematics.m
% Pure algebraic check – no Simulink required.
% Confirms that the gain constants match the engineering equations.

clear; clc;
run('00_parameters.m');   % loads p

% Test vector of motor torques
tau_test = [0.05 0.10 0.15 0.18];   % N·m

fprintf('\n=== Kinematic Verification ===\n');
fprintf('n_g = %g,  n_p = %g,  r_w = %.3f m\n', p.n_g, p.n_p, p.r_w);
fprintf('η_g = %.2f, η_p = %.2f\n\n', p.eta_g, p.eta_p);

fprintf('  tau_m [N·m] |  F_drill [N] |  v_scale [(m/s)/(rad/s)]\n');
fprintf('-----------------------------------------------------\n');
for i = 1:numel(tau_test)
    F = p.K_force * tau_test(i);
    fprintf('    %6.3f    |   %8.1f   |      %.6f\n',...
            tau_test(i), F, p.K_vel);
end

fprintf('\nAnalytic example (paper-like numbers):\n');
fprintf('  Motor 0.12 N·m  →  %.0f N axial force\n', 0.12 * p.K_force);
fprintf('  Motor 1000 rpm  →  %.1f mm/s linear speed\n',...
        (1000*2*pi/60) * p.K_vel * 1000);
fprintf('=====================================\n');