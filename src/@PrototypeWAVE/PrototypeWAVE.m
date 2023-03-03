function model = PrototypeWAVE(hull, link, wing, varargin)
%PROTOTYPEWAVE Implementation of the dynamic model of the WAVE prototype.
%
%   MODEL = PROTOTYPEWAVE( HULL, LINK, WING, Property, Value, ... )
%       returns the model for the longitudinal dynamics of the bodies
%       constituting the WAVE prototype (the main vehicle body, the links
%       and the wings). The hull of the vehicle is assumed as a prolate
%       spheroid. The WAVE prototype is modelled as a bi-dimensional serial
%       manipulator (in the surge-heave-pitch plane); its kinematics can
%       thus be conveniently modelled according to the Denavit-Hartenberg
%       parametrisation [1]. Exploiting this framework, the dynamics of the
%       prototype can be obtained following a Lagrangian approach, see for
%       further details [2], [3]. The dynamic parameters of both the link
%       and the wing are doubled to account for two link-wing systems.
%       The returning object MODEL contains the following fields, each one
%       giving information about all the bodies:
%       * cog: position of the Center Of Gravity with respect to the origin
%              of the joint reference frame;
%       * joint: position of the next joint in the serial kinematic chain;
%       * bouyancy: buoyancy;
%       * mass: mass;
%       * added_mass: added mass, see AddedMass function documentation;
%       * inertia: moment of inertia, see MomentOfInertia function
%                  documentation;
%       * linear_drag: linear hydrodynamic damping coefficients;
%       * nonlinear_drag: quadratic hydrodynamic damping coefficients.
%
% References:
% [1] Denavit, Jacques et al. (1955). A kinematic notation for lower-pair
%     mechanisms based on matrices. Transanctions of the ASME Journal of 
%     Applied Mechanics. 22, pp. 215-221.
% [2] Calabrò, Vincenzo (2012). Veicolo Autonomo Ibrido con Capacità di 
%     Wave-Gliding (VAI): Progetto del Sistema e Verifica delle 
%     Funzionalità e dei Requisiti. ISME - CSSN.
% [3] Caiti, Andrea et al. (2012). Lagrangian Modelling of an Underwater 
%     Wave Glider. Ship Technology Research. 59 (1), pp. 6-12.

    % Support the zero input argument case for use within parfor loops
    if nargin == 0
        hull = ProlateEllipsoid(2.682, 0.155, 2.682/2-0.04, 'Mass', 38.3, ...
            'Buoyancy', 1.1*38.3, 'Damping', [2, 10.5, 20], 'Drag', [0.2, 1.05, 2], ...
            'JointPosition', 1.706, 'WaterDensity', 1025);

        link = RightPrism(Shape(0.70, 0.03), 0.05, 'Mass', 1.32, 'Damping', 25, ...
            'JointPosition', 0.7, 'WaterDensity', 1025);

        wing = RightPrism(GraalTechWing(0.15, 0.80, 0.0975, 0.4), 0.002, ...
            'Drag', [1.5 2.5 0], 'Mounting', 0.4, 'MaterialDensity', 2700, 'WaterDensity', 1025);
    end

    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'gravity', 9.81, @(x) isscalar(x) && isnumeric(x));
    addParameter(p, 'vehiclesamples', 10, @(x) isscalar(x) && isnumeric(x));
    addParameter(p, 'wingsamples', 100, @(x) isscalar(x) && isnumeric(x));
    addParameter(p, 'quiet', false, @(x) isscalar(x) && islogical(x));
    addParameter(p, 'brakefcn', {}, @(x) isa(x, 'function_handle') && ...
        nargin(x) == 3 && islogical(x(zeros(5,1),zeros(5,1),zeros(2,1))));
    parse(p,varargin{:});
    params = p.Results;

    % Dimensions of the bodies
    tmp = get(hull, 'Dimensions');
    model.length.vehicle   = tmp.major_axis;
    model.diameter.vehicle = tmp.minor_axis;

    tmp = get(link, 'Dimensions');
    model.length.link = tmp.length;
    model.width.link  = tmp.width;
    model.height.link = tmp.height;

    tmp = get(wing, 'Dimensions');
    model.length.wing  = tmp.length;
    model.width.wing   = tmp.width;
    model.height.wing  = tmp.height;
    model.surface.wing = get(wing, 'Surface');

    % Position of the Centre Of Gravity (COG) and of the Centre Of Buoyancy
    % (COB) of the bodies
    model.cog.vehicle = get(hull, 'COG');
    model.cog.link    = get(link, 'COG');
    model.cog.wing    = get(wing, 'COG');
    model.cob         = model.cog;
    
    % Position of the next joint in the modelling of the prototype as a
    % serial manipulator
    model.joint.vehicle = get(hull, 'JointPosition');
    model.joint.link    = get(link,'JointPosition');
    model.joint.wing    = get(wing,'JointPosition');

    % Mounting point of the wing
    model.mounting.wing = get(wing, 'Mounting');

    % Buoyancy of the bodies
    model.buoyancy.vehicle = get(hull, 'Buoyancy');
    model.buoyancy.link    = 2*get(link, 'Buoyancy');
    model.buoyancy.wing    = 2*get(wing, 'Buoyancy');

    % Mass of the bodies
    model.mass.vehicle = get(hull, 'Mass');
    model.mass.link    = 2*get(link, 'Mass');
    model.mass.wing    = 2*get(wing, 'Mass');

    % Added mass of the bodies
    tmpMa = get(hull, 'AddedMass');
    model.added_mass.vehicle = tmpMa([1 3 5],[1 3 5]);
    tmpMa = get(link, 'AddedMass');
    model.added_mass.link = 2*tmpMa([1 3 5],[1 3 5]);
    tmpMa = get(wing, 'AddedMass');
    model.added_mass.wing = 2*tmpMa([1 3 5],[1 3 5]);

    % Moment of inertia of the bodies, each one about the z-axis of the local 
    % frame in the Denavit-Hartemberg modelling of the prototype
    tmpI = get(hull, 'MomentOfInertia');
    model.inertia.vehicle = tmpI(2,2);

    tmpI = get(link, 'MomentOfInertia');
    model.inertia.link = 2*tmpI(2,2);

    tmpI = get(wing, 'MomentOfInertia');
    model.inertia.wing = 2*tmpI(2,2);

    % Linear and nonlinear drag coefficients of the bodies
    tmp = get(hull, 'Drag');
    model.linear_drag.vehicle = tmp.damping;
    model.nonlinear_drag.vehicle = tmp.drag;

    tmp = get(link, 'Drag');
    model.linear_drag.link = tmp.damping;

    tmp = get(wing, 'Drag');
    model.linear_drag.wing = tmp.damping;
    model.nonlinear_drag.wing = tmp.drag;

    % Submerged percentage of the bodies
    model.is_submerged.vehicle   = NaN(1, params.vehiclesamples);
    model.is_submerged.wing      = NaN(1, params.wingsamples);
    model.submerged_perc.vehicle = 1;
    model.submerged_perc.link    = 1;
    model.submerged_perc.wing    = 1;

    % Gravity value
    model.gravity = params.gravity;

    % Number of body samples, considering the COG of each sample in the
    % middle point of each one.
    model.n_samples.vehicle = params.vehiclesamples;
    model.samples.vehicle = linspace(0, model.length.vehicle*(1-1/model.n_samples.vehicle), model.n_samples.vehicle) + ...
        (model.length.vehicle/model.n_samples.vehicle)/2;
    model.n_samples.wing = params.wingsamples;
    model.samples.wing    = linspace(0, model.length.wing*(1-1/model.n_samples.wing), model.n_samples.wing) + ...
        (model.length.wing/model.n_samples.wing)/2;

    % Brake functionality
    model.brakeFcn = params.brakefcn;

    % Flags
    model.quiet    = params.quiet;

    model = class(model, 'PrototypeWAVE');
end
