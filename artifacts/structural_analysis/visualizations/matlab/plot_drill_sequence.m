%% plot_drill_sequence.m
% MATLAB counterpart to the Python time-domain visualization.
% Plots force, velocity, temperature, and thermal deflection for a
% simplified LVHT master sequence.

clear; clc; close all;

dt = 0.05;
t  = 0:dt:180;

t_cold = 40; t_clamp = 50; t_drill = 120; t_extract = 160;

F = zeros(size(t));
V = zeros(size(t));
for i = 1:numel(t)
    ti = t(i);
    if ti < t_cold
        F(i) = 5 * sin(2*pi*0.5*ti).^2;
        V(i) = 0.001 * sign(sin(2*pi*0.5*ti));
    elseif ti < t_clamp
        F(i) = 0; V(i) = 0;
    elseif ti < t_drill
        F(i) = 70 + 10*sin(2*pi*0.1*(ti-t_clamp));
        V(i) = 0.0008;
    elseif ti < t_extract
        F(i) = -30; V(i) = -0.0015;
    end
end

% Thermal
T0 = 150; Cth = 80; Rth = 15; Pbase = 8;
T = zeros(size(t)); T(1) = T0;
for i = 2:numel(t)
    Pin = Pbase * (abs(F(i)) > 20) + 0.02*abs(F(i)*V(i))*1000;
    T(i) = T(i-1) + (Pin - (T(i-1)-T0)/Rth)/Cth * dt;
end
alpha = 8.6e-6; L0 = 0.6;
delta = alpha * L0 * (T - T0) * 1e6;   % µm

figure('Name','Drill Sequence','Color','w');
subplot(4,1,1); plot(t,F,'b'); ylabel('F (N)'); grid on; title('Master Sequence');
subplot(4,1,2); plot(t,V*1000,'g'); ylabel('V (mm/s)'); grid on;
subplot(4,1,3); plot(t,T,'r'); ylabel('T (K)'); grid on;
subplot(4,1,4); plot(t,delta,'m'); ylabel('\DeltaL (\mum)'); xlabel('Time (s)'); grid on;

% Optional: save
% saveas(gcf, '../output/matlab_drill_sequence.png');