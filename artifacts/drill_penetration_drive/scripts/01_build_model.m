%% 01_build_model.m
% Programmatically constructs a clean Simulink model of the
% motor → gearbox → cable-reel → movable-pulley → linear plant chain.
% Compatible with MATLAB R2020b+ / MATLAB Online.

function build_penetration_model()
    load('../data/parameters.mat');   % must run 00_parameters.m first

    modelName = 'penetration_drive';
    modelPath = fullfile('..','models',[modelName '.slx']);

    if bdIsLoaded(modelName)
        close_system(modelName,0);
    end
    if exist(modelPath,'file')
        delete(modelPath);
    end

    new_system(modelName);
    open_system(modelName);

    % ------------------------------------------------------------------
    % Top-level architecture (NASA-style hierarchical blocks)
    % ------------------------------------------------------------------
    add_block('simulink/Sources/Constant',[modelName '/tau_m_cmd'],...
        'Value','0.12','Position',[30 50 80 80]);
    add_block('simulink/Sources/Constant',[modelName '/F_load'],...
        'Value',num2str(p.F_load_nom),'Position',[30 150 80 180]);

    % Gearbox
    add_block('simulink/Math Operations/Gain',[modelName '/Gearbox_Torque'],...
        'Gain',num2str(p.n_g * p.eta_g),'Position',[150 45 220 85]);
    add_block('simulink/Math Operations/Gain',[modelName '/Gearbox_Speed'],...
        'Gain',num2str(1/p.n_g),'Position',[150 220 220 260]);

    % Winch / reel
    add_block('simulink/Math Operations/Gain',[modelName '/Winch_Force'],...
        'Gain',num2str(1/p.r_w),'Position',[280 45 350 85]);
    add_block('simulink/Math Operations/Gain',[modelName '/Winch_Vel'],...
        'Gain',num2str(p.r_w),'Position',[280 220 350 260]);

    % Movable-pulley MA
    add_block('simulink/Math Operations/Gain',[modelName '/Pulley_Force'],...
        'Gain',num2str(p.n_p * p.eta_p),'Position',[410 45 480 85]);
    add_block('simulink/Math Operations/Gain',[modelName '/Pulley_Vel'],...
        'Gain',num2str(1/p.n_p),'Position',[410 220 480 260]);

    % Combined gains (for verification)
    add_block('simulink/Math Operations/Gain',[modelName '/K_force'],...
        'Gain',num2str(p.K_force),'Position',[150 320 250 360]);
    add_block('simulink/Math Operations/Gain',[modelName '/K_vel'],...
        'Gain',num2str(p.K_vel),'Position',[150 380 250 420]);

    % Linear plant: 1/(m s + b)
    add_block('simulink/Continuous/Transfer Fcn',[modelName '/Linear_Plant'],...
        'Numerator','1',...
        'Denominator',[p.m_carriage p.b_viscous],...
        'Position',[550 40 650 100]);

    % Integrator for position
    add_block('simulink/Continuous/Integrator',[modelName '/Position'],...
        'Position',[700 50 740 90]);

    % Scopes / logging
    add_block('simulink/Sinks/Scope',[modelName '/Scope_Force'],...
        'Position',[700 150 750 200]);
    add_block('simulink/Sinks/To Workspace',[modelName '/log_F'],...
        'VariableName','F_drill','Position',[700 220 780 250]);
    add_block('simulink/Sinks/To Workspace',[modelName '/log_v'],...
        'VariableName','v_drill','Position',[700 280 780 310]);
    add_block('simulink/Sinks/To Workspace',[modelName '/log_x'],...
        'VariableName','x_drill','Position',[800 50 880 80]);

    % Wiring (force path)
    add_line(modelName,'tau_m_cmd/1','Gearbox_Torque/1');
    add_line(modelName,'Gearbox_Torque/1','Winch_Force/1');
    add_line(modelName,'Winch_Force/1','Pulley_Force/1');
    add_line(modelName,'Pulley_Force/1','Linear_Plant/1');
    add_line(modelName,'F_load/1','Linear_Plant/1');   % will need a Sum later – simplified
    add_line(modelName,'Linear_Plant/1','Position/1');
    add_line(modelName,'Pulley_Force/1','Scope_Force/1');
    add_line(modelName,'Pulley_Force/1','log_F/1');
    add_line(modelName,'Linear_Plant/1','log_v/1');
    add_line(modelName,'Position/1','log_x/1');

    % Speed path (open for now – can be closed later)
    add_line(modelName,'tau_m_cmd/1','K_force/1');   % parallel verification path
    add_line(modelName,'tau_m_cmd/1','K_vel/1');

    % Solver settings
    set_param(modelName,'Solver','ode4','FixedStep',num2str(p.Ts),...
        'StopTime',num2str(p.T_end),'SaveFormat','StructureWithTime');

    save_system(modelName,modelPath);
    close_system(modelName);
    fprintf('Model built → %s\n',modelPath);
end

% Auto-run when script is executed
build_penetration_model();