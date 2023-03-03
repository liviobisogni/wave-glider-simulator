function q_t = Run(model, wave, ode, q_0, dT, T_f)
%RUN Summary of this function goes here
%   Detailed explanation goes here

    WaveDynamics = @(t, x) Dynamics(model, wave, t, x);
    Time = 0:dT:T_f;

    if ~model.quiet
        tic;
    end
    switch ode
        case 5
            Results = ode5(WaveDynamics, Time, q_0);
        case 45
            t = [];
            y = [];
            t0 = 0;
            y0 = q_0;
            while t0 < T_f
                [t1, y1] = ode45(WaveDynamics, [t0 T_f], y0, ...
                    odeset('RelTol', 1e-6, 'AbsTol', 1e-6, ...
                    'Events', @(t,y) StopEvent(model, wave, t, y)));
                t = [t; t1];
                y = [y; y1];
                t0 = t(end);
                if isempty(model.brakeFcn)
                    y0 = y(end,:)'.*[1 1 1 1 1 1 1 1 1 1]';
                else
                    y0 = y(end,:)'.*[1 1 1 1 1 1 1 1 0 1]';
                end
            end
            [t, idx, ~ ] = unique(t);
            y = y(idx,:);
            Results = interp1(t, y, Time);
    end
    if ~model.quiet
        toc;
    end

    q_t = timeseries(Results,Time);
end

function [value, isterminal, direction] = StopEvent(model, wave, t, y)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if isempty(model.brakeFcn)  % Recharging modality
    value = 1;
else                        % Propulsion modality
    N = length(y)/2;
    q  = y(1:N);
    dq = y(N+1:end);

    % Split the wing in N samples to evaluate the interaction with the
    % sea-wave
    base_T_wing = RotoTranslation(model, q, 'wing');
    wing_b = base_T_wing*[ model.samples.wing; ...
        zeros(2, model.n_samples.wing); ...
        ones(1, model.n_samples.wing) ];
    x_wing = wing_b(1,:);
    z_wing = wing_b(3,:);

    % Velocity of the wave particles corresponding to the positions of the
    % samples of the wing, both expressed in the base frame coordinates.
    % The non-submerged samples are marked with NaNs.
    is_submerged = z_wing >= height(wave, x_wing, t);
    v_wave = [ velocity(wave, x_wing, z_wing, t); ...
        zeros(1, model.n_samples.wing) ];
    v_wave(:, ~is_submerged) = NaN;

    % Weighted average of the wave velocity on the wing
    v_wave_wing_avg = sum( v_wave(1:2, is_submerged).*...
            repmat(model.width.wing(model.samples.wing(is_submerged)), 2, 1), 2 )/ ...
            sum(model.width.wing(model.samples.wing(is_submerged)));
    value = double( ~model.brakeFcn(q, dq, v_wave_wing_avg) );
end

isterminal = 1;
direction = 0;
end