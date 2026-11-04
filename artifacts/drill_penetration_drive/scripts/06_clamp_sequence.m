%% 06_clamp_sequence.m
% Scripted call sequence for the top (and optionally bottom) clamping unit
% that grips the drill pipe.
%
% From MWDR paper (Liu et al.):
% - Three-jaw parallel mechanism driven by clamping motor + hollow gear
% - Top clamp transmits cutting torque; bottom clamp holds lower pipe for (dis)connection
% - Must be sequenced with penetration and rotation
%
% Control practice (literature + Antarctic clamper, multi-rod robots):
% - Torque / current limited to avoid crushing the pipe
% - Confirm clamp via current rise or position encoder before enabling rotation

function clamp_sequence(action, which_clamp)
    % action      : 'close' | 'open' | 'hold'
    % which_clamp : 'top' | 'bottom' | 'both'  (default 'top')
    if nargin < 2, which_clamp = 'top'; end

    load('../data/parameters.mat');

    fprintf('=== Clamp Sequence: %s on %s ===\n', upper(action), upper(which_clamp));

    switch lower(action)
        case 'close'
            % 1. Move jaws to contact (position mode, low current)
            cmd_clamp(which_clamp, 'position', 0.85);  % 85 % closed
            pause(0.4);
            % 2. Switch to torque mode and ramp to target grip force
            cmd_clamp(which_clamp, 'torque', 0.6);     % normalised torque
            pause(0.8);
            % 3. Verify (placeholder – read current or encoder)
            fprintf('  Clamp closed and holding. Ready for rotation/penetration.\n');

        case 'open'
            cmd_clamp(which_clamp, 'torque', 0);
            pause(0.2);
            cmd_clamp(which_clamp, 'position', 0.0);   % fully open
            fprintf('  Clamp fully open.\n');

        case 'hold'
            % Maintain current torque without further motion
            cmd_clamp(which_clamp, 'torque', 0.55);
            fprintf('  Holding clamp torque.\n');

        otherwise
            error('Unknown action. Use close | open | hold');
    end
end

function cmd_clamp(which, mode, value)
    % Placeholder for real driver command (Elmo / Maxon / Arduino)
    fprintf('  [%s] mode=%s  value=%.2f\n', upper(which), mode, value);
end

%% Full coordinated example (clamp → drill → unclamp)
function demo_coordinated()
    fprintf('\n--- Coordinated Clamp + Penetration Demo ---\n');
    clamp_sequence('close', 'top');
    % ... call penetration mode here ...
    pause(1);
    clamp_sequence('open', 'top');
end