function J = Jacobian(model, q, varargin)
%JACOBIAN Geometric Jacobian of the WAVE prototype.
%
%   J = JACOBIAN( MODEL, Q )
%       returns the geometric Jacobian of the end-effector of the WAVE
%       prototype according to the modelling described in [1]. The Jacobian
%       matrix maps the joint velocities into the velocity (expressed in
%       the base frame {b}) of the end effector.
%
%   J = JACOBIAN( MODEL, Q, BODY )
%       returns the geometric Jacobian associated to the Centre Of Gravity
%       (COG) of the specified BODY composing the WAVE prototype. BODY is a
%       string which values can be 'vehicle', 'link' or 'wing'.
%
%   J = JACOBIAN( MODEL, Q, BODY, POSITION )
%       returns the geometric Jacobian associated to the point located in
%       POSITION with respect to the BODY stern. POSITION is a two-element
%       vector expressed in the BODY-fixed reference frame.
%
% References:
% [1] Caiti, Andrea et al. (2012). Lagrangian Modelling of an Underwater 
%     Wave Glider. Ship Technology Research. 59 (1), pp. 6-12.

    % Parse optional arguments
    p = inputParser;
    addOptional(p, 'body', 'wing', @(x) any(validatestring(x,{'vehicle', 'link', 'wing'})));
    addOptional(p, 'position', [model.joint.wing 0], @(x) (isnumeric(x) && isvector(x) && length(x) == 2));
    parse(p,varargin{:});
    
    params = p.Results;
    if ~isempty(p.UsingDefaults) && ismember(p.UsingDefaults, 'position') && ~ismember(p.UsingDefaults, 'body')
        ai = [ model.cog.(lower(p.Results.body)) 0 ];
    else
        ai = params.position;
    end
    
    switch lower(params.body)
        case 'vehicle'
            J = [ 1, 0, -ai(1)*sin(q(3)) - ai(2)*cos(q(3)); ...
                  0, 1, -ai(1)*cos(q(3)) + ai(2)*sin(q(3)); ...
                  0, 0, 1                                   ];
        case 'link'
            a1 = model.joint.vehicle;
            J = [ 1, 0, -a1*sin(q(3))-ai(1)*sin(q(3)-pi+q(4)) -ai(1)*sin(q(3)-pi+q(4)); ...
                  0, 1, -a1*cos(q(3))-ai(1)*cos(q(3)-pi+q(4)) -ai(1)*cos(q(3)-pi+q(4)); ...
                  0, 0, 1                                     1                         ];
        case 'wing'
            a1 = model.joint.vehicle;
            a2 = model.joint.link;
            a3 = ai(1) - model.mounting.wing;
            J = [ 1, 0, -a1*sin(q(3))-a2*sin(q(3)-pi+q(4))-a3*sin(q(3)-pi+q(4)+q(5)) -a2*sin(q(3)-pi+q(4))-a3*sin(q(3)-pi+q(4)+q(5)) -a3*sin(q(3)-pi+q(4)+q(5)); ...
                  0, 1, -a1*cos(q(3))-a2*cos(q(3)-pi+q(4))-a3*cos(q(3)-pi+q(4)+q(5)) -a2*cos(q(3)-pi+q(4))-a3*cos(q(3)-pi+q(4)+q(5)) -a3*cos(q(3)-pi+q(4)+q(5)); ...
                  0, 0, 1                                                            1                                               1                           ];
    end
end

