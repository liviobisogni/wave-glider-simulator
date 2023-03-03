function T = RotoTranslation(model, q, varargin)
%ROTOTRANSLATION Evaluates the roto-translation matrix from the base reference
% frame {b} to a body-fixed reference frame {v} directed as {4} in the WAVE
% prototype modelling.
%
%   T = ROTOTRANSLATION( MODEL, Q, A1 )
%       returns the transformation matrix that performs either the
%       roto-translation from the base reference frame {b} to a body-fixed
%       reference system {v} having the origin in a point lying on the
%       midline of the vehicle at distance A1 with respect to the stern and
%       directed as the frame {4} of the WAVE prototype modelling described
%       in [1], or, equivalently, the coordinates transformation from the
%       frame {v} to the frame {b}.
%
% References:
% [1] Caiti, Andrea et al. (2012). Lagrangian Modelling of an Underwater 
%     Wave Glider. Ship Technology Research. 59 (1), pp. 6-12.

    % Parse optional arguments
    p = inputParser;
    addOptional(p, 'body', 'end', @(x) any(validatestring(x,{'vehicle', 'link', 'wing', 'end'})));
    parse(p,varargin{:});

    a1  = model.joint.vehicle;
    a2  = model.joint.link;
    a3m = model.mounting.wing;
    a3  = model.joint.wing;
    T_vehicle = [ cos(q(3)), -sin(q(3)), 0, q(1); ...
                          0,          0, 1,    0; ...
                 -sin(q(3)), -cos(q(3)), 0, q(2); ...
                          0,          0, 0,    1  ];

    T_link    = T_vehicle * [ cos(-pi+q(4)), -sin(-pi+q(4)), 0, a1; ...
                              sin(-pi+q(4)),  cos(-pi+q(4)), 0,  0; ...
                                          0,              0, 1,  0; ...
                                          0,              0, 0,  1  ];

    T_wing    = T_link * [ cos(q(5)), -sin(q(5)), 0, a2; ...
                           sin(q(5)),  cos(q(5)), 0,  0; ...
                                   0,          0, 1,  0; ...
                                   0,          0, 0,  1  ] * [ eye(3), [-a3m; 0; 0]; 0 0 0 1];

    switch lower(p.Results.body)
        case 'vehicle'
            T = T_vehicle;
        case 'link'
            T = T_link;
        case 'wing'
            T = T_wing;
        case 'end'
            T = T_wing * [ 1, 0, 0, a3; ...
                           0, 1, 0,  0; ...
                           0, 0, 1,  0; ...
                           0, 0, 0,  1  ];
    end
end
