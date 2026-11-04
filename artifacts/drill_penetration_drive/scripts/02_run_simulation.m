%% 02_run_simulation.m
% Loads parameters, builds (if needed), simulates, and plots key signals.

clear; clc; close all;

% Ensure parameters exist
if ~exist('../data/parameters.mat','file')
    run('00_parameters.m');
end
load('../data/parameters.mat');

% Build model if missing
modelPath = fullfile('..','models','penetration_drive.slx');
if ~exist(modelPath,'file')
    run('01_build_model.m');
end

% Simulate
simOut = sim(modelPath);

% Extract logs (StructureWithTime)
t   = simOut.F_drill.time;
F   = simOut.F_drill.signals.values;
v   = simOut.v_drill.signals.values;
x   = simOut.x_drill.signals.values;

% Analytic prediction
F_analytic = 0.12 * p.K_force;   % same command used in model
v_analytic = 0;                  % steady-state under constant force vs load

fprintf('Simulation complete.\n');
fprintf('  Peak axial force   : %.1f N  (analytic %.1f N)\n', max(F), F_analytic);
fprintf('  Final position     : %.3f m\n', x(end));

figure('Name','Penetration Drive Results','Color','w');
subplot(3,1,1);
plot(t,F,'b','LineWidth',1.5); grid on;
ylabel('F_{drill} [N]'); title('Axial Force (pulley-amplified)');
subplot(3,1,2);
plot(t,v,'r','LineWidth',1.5); grid on;
ylabel('v [m/s]');
subplot(3,1,3);
plot(t,x,'k','LineWidth',1.5); grid on;
ylabel('x [m]'); xlabel('Time [s]');
sgtitle('Cable + Movable-Pulley Penetration Drive');