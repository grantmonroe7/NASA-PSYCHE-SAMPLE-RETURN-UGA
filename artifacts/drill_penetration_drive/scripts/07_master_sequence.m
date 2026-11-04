%% 07_master_sequence.m
% High-level orchestrator that calls cold-start, clamp, mode, and extraction
% sequences in a robust, mission-like order.
%
% Typical autonomous cycle (inspired by MWDR motion planning papers):
%   1. Cold-start jog (if temperature low)
%   2. Clamp top
%   3. Selected drilling mode (LVHT / PERC / HSPD)
%   4. Stop
%   5. Extraction (reverse of selected mode)
%   6. Unclamp

function master_sequence(mode, do_cold_start)
    if nargin < 1, mode = 'LVHT'; end
    if nargin < 2, do_cold_start = true; end

    fprintf('\n========================================\n');
    fprintf('  MASTER SEQUENCE – mode = %s\n', upper(mode));
    fprintf('========================================\n\n');

    % 1. Optional cold-start
    if do_cold_start
        run('04_cold_start_jog.m');   % or call cold_start_jog(120, 0.3)
        cold_start_jog(90, 0.3);
    end

    % 2. Clamp
    run('06_clamp_sequence.m');
    clamp_sequence('close', 'top');

    % 3. Drilling mode
    run('05_mode_sequences.m');
    switch upper(mode)
        case 'LVHT'
            s = seq_LVHT();
        case 'PERC'
            s = seq_PERC();
        case 'HSPD'
            s = seq_HSPD();
        otherwise
            error('Unknown mode');
    end
    fprintf('Executing %s: %s\n', s.name, s.desc);
    % (In real system: stream torque/speed profile for s.duration seconds)

    % 4. Stop
    fprintf('Stopping motors...\n');
    pause(0.5);

    % 5. Extraction (reverse)
    s_ext = seq_EXTRACT(mode);
    fprintf('Executing %s: %s\n', s_ext.name, s_ext.desc);
    % (stream reverse profile)

    % 6. Unclamp
    clamp_sequence('open', 'top');

    fprintf('\nMaster sequence complete.\n');
end