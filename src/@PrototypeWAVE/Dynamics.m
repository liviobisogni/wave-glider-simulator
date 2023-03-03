function x_dot = Dynamics( model, wave, t, x )
%DYNAMICS Evaluates the dynamics of the WAVE prototype.
%
%   X_DOT = DYNAMICS( MODEL, WAVE, T, X )
%       returns the state dynamics of the WAVE prototype. The state vector
%       X is defined as:
%           X = [ q', dq' ]'
%       where q = [ pn, pd, q3, q4, q5 ]' is the joint variables vector,
%       composed of:
%         * pn: the vehicle position along the x (North) axis;
%         * pd: the vehicle position along the z (Down) axis;
%         * q3: the pitch angle of the vehicle;
%         * q4: the hull-to-link joint angle;
%         * q5: the link-to-wing joint angle;
%       and dq is the vector of the associated velocities. The velocity
%       dynamics is evaluated on the basis of the dynamic equation:
%           B(q)ddq + C(q,dq)dq + D(q,dq)dq + G(q) = tau
%       described in [1].
%
% References:
% [1] Fossen, Thor I. (1994).  Guidance and Control of Ocean Vehicles.
%     John Wiley & Sons.

    N = length(x)/2;
    q  = x(1:N);
    dq = x(N+1:end);

    % Split the hull and the wing in N samples to evaluate the interaction
    % with the sea-wave
    base_T_vehicle = RotoTranslation(model, q, 'vehicle');
    vehicle_b = base_T_vehicle*[ model.samples.vehicle; ...
        zeros(2, model.n_samples.vehicle); ...
        ones(1, model.n_samples.vehicle) ];
    x_vehicle = vehicle_b(1,:);
    z_vehicle = vehicle_b(3,:);

    base_T_wing = RotoTranslation(model, q, 'wing');
    wing_b = base_T_wing*[ model.samples.wing; ...
        zeros(2, model.n_samples.wing); ...
        ones(1, model.n_samples.wing) ];
    x_wing = wing_b(1,:);
    z_wing = wing_b(3,:);

    % Wave elevation from the sea surface expressed in the base frame {b}
    z_wave_v = height(wave, x_vehicle, t);
    z_wave_w = height(wave, x_wing, t);

    % Submerged samples of the vehicle and the wing
    model.is_submerged.vehicle = z_vehicle >= z_wave_v;
    model.is_submerged.wing    = z_wing >= z_wave_w;

    % Velocity of the wave particles corresponding to the positions of the
    % samples of the hull and of the wing, both expressed in the base frame
    % coordinates. The non-submerged samples are marked with NaNs.
    v_wave.vehicle = [ velocity(wave, x_vehicle, z_vehicle, t); ...
        zeros(1, model.n_samples.vehicle) ];
    v_wave.vehicle(:, ~model.is_submerged.vehicle) = NaN;
    v_wave.wing = [ velocity(wave, x_wing, z_wing, t); ...
        zeros(1, model.n_samples.wing) ];
    v_wave.wing(:, ~model.is_submerged.wing) = NaN;

    % Centre Of Buoyancy (COB) evaluated as the mean of the coordinates of
    % the submerged parts of the vehicle and of the wing
    model.submerged_perc.vehicle = sum(model.is_submerged.vehicle)/model.n_samples.vehicle;
    if any(model.is_submerged.vehicle)
        model.cob.vehicle = mean(model.samples.vehicle(model.is_submerged.vehicle));
    else    % The vehicle is completely outside the water
        model.cob.vehicle = 0;
    end

    if all(model.is_submerged.wing)     % The wing is entirely submerged
        model.submerged_perc.wing = 1;
        model.cob.wing            = model.cog.wing;
    elseif any(model.is_submerged.wing) % Part of the wing is submerged
        submerged_wing = model.samples.wing(model.is_submerged.wing);
        model.submerged_perc.wing = (model.length.wing/model.n_samples.wing*sum(model.width.wing(submerged_wing)))/model.surface.wing;
        model.cob.wing            = sum(submerged_wing.*model.width.wing(submerged_wing)) / ...
            sum(model.width.wing(submerged_wing));
    else                                % The wing is entirely outside the water
        model.submerged_perc.wing = 0;
        model.cob.wing            = 0;
    end

    % Dynamics selection
    free_dofs = 1:4;
    if ~isempty(model.brakeFcn)
        % Weighted average of the wave velocity on the wing
        v_wave_wing_avg = sum( v_wave.wing(1:2, model.is_submerged.wing).*...
            repmat(model.width.wing(model.samples.wing(model.is_submerged.wing)), 2, 1), 2 )/ ...
            sum(model.width.wing(model.samples.wing(model.is_submerged.wing)));
        if model.brakeFcn(q, dq, v_wave_wing_avg)
            free_dofs = 1:3;
        end
    end
    M_sel = eye(N);
    M_sel = M_sel(free_dofs, :);

    % Dynamic equation
    B     = M_sel*B_q(model, q)*M_sel';
    C     = M_sel*C_q_dq(model, q, dq)*M_sel';
    D     = M_sel*D_q_dq(model, q, dq, v_wave);
    G     = M_sel*G_q(model, q);

    ddq = M_sel'*(B\( -C*M_sel*dq - D - G ));

    if ~model.quiet && floor(t) > floor(t-0.02)
        fprintf('t=%.2f, %%v=%.2f, %%w=%.2f, x_cog=%.2f, z_cog=%.2f, x_cob=%.2f, pitch=(%.2f,%.2f)\n', t, ...
            model.submerged_perc.vehicle, model.submerged_perc.wing, q(1) + model.cog.vehicle*cos(q(3)), ...
            q(2) - model.cog.vehicle*sin(q(3)), model.cob.vehicle, rad2deg(q(3)), rad2deg(q(4)))
    end

    x_dot = [ dq; ddq ];

end

