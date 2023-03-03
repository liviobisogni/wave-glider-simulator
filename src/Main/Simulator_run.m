% Start Simulatore
tic;
disp('Start Simulator_run.m')   %DEBUG

%%
% Read base workspace variables

% Time
dT=evalin('base','dT');
T_final=evalin('base','T_final');
T_cut=evalin('base','T_cut'); % T taglio transitorio

% Sea
wave_amplitude=evalin('base','wave_amplitude');
wave_frequency=evalin('base','wave_frequency');
rho_water=evalin('base','rho_water');

% Initial Conditions
% Angle
q1_0=evalin('base','q1_0');
q2_0=evalin('base','q2_0');
q3_0=evalin('base','q3_0');
q4_0=evalin('base','q4_0');
q5_0=evalin('base','q5_0');
% Velocity
dq1_0=evalin('base','dq1_0');
dq2_0=evalin('base','dq2_0');
dq3_0=evalin('base','dq3_0');
dq4_0=evalin('base','dq4_0');
dq5_0=evalin('base','dq5_0');

% General
rho_aluminium=evalin('base','rho_aluminium');

% Wing, Link, Vehicle Structure
vehicle=evalin('base','vehicle');
link=evalin('base','link');
wing=evalin('base','wing');

% Flag
freno=evalin('base','freno');
mounting_direction=evalin('base','mounting_direction');
mounting_point=evalin('base','mounting_point');
brake_fcn=evalin('base','brake_fcn');


%%
% Selection Mounting Point
switch mounting_point
    case 0
        wing.mounting = 0;
    case 1
        wing.mounting = wing.max_length/2;
    case 2
        wing.mounting = wing.max_length;
end

% Selection Wing Profile
switch wing.profiloPala
    case 1
        myWing = GraalTechWing(wing.min_length, wing.max_length, wing.min_width, wing.max_width);
    case 2
        if (wing.alpha == 0)
            myWing = GraalTechWing(wing.min_length, wing.max_length, wing.min_width, wing.max_width);
        else
            myWing = ExponentialWing(wing.min_length, wing.max_length, wing.min_width, wing.max_width, wing.alpha);
        end
end

%%
% Creo Wing Object
wing_ = RightPrism(myWing, wing.height, 'Drag', wing.drag_coeff, ...
    'Mounting', wing.mounting, 'MaterialDensity', rho_aluminium, 'WaterDensity', rho_water);

% Creo Wave Object
wave = SeaWave(wave_amplitude, wave_frequency, ...
    'Direction', 'left');

% Hull Object
hull = ProlateEllipsoid(vehicle.length, vehicle.diameter, vehicle.cog, ...
    'Mass', vehicle.mass, 'Buoyancy', vehicle.buoyancy, 'Damping', vehicle.friction, ...
    'Drag', vehicle.drag_coeff, 'JointPosition', vehicle.link_joint, 'WaterDensity', rho_water);

% Link Object
link_ = RightPrism(Shape(link.length, link.width), link.height, ...
    'Mass', link.mass, 'JointPosition', link.wing_joint, ...
    'Damping', link.friction, 'WaterDensity', rho_water);


%%
% Dynamics of the WAVE prototype for the longitudinal model (surge, heave 
% and pitch plane).

% min_length, max_length, min_width, max_width, alpha
% wing_1 = GraalTechWing(0.10, 0.40, 0.10, 0.40);
% wing_2 = GraalTechWing(0.15, 0.80, 0.0975, 0.40);
% wing_3 = GraalTechWing(0.15, 0.40, 0.0975, 0.80);
% wing_4 = ExponentialWing(0.15, 0.80, 0.0975, 0.40, 5);

% Selection Modality Recharge/Propulsion
switch freno
    case 0
       % Creo Wave_Vehicle Object
       wave_vehicle = PrototypeWAVE( hull, link_, wing_, 'WingSamples', 10,'quiet', true);
    case 1
       % Creo Wave_Vehicle Object
       wave_vehicle = PrototypeWAVE( hull, link_, wing_, 'WingSamples', 10, 'quiet', true, 'BrakeFcn', brake_fcn);
end

%%
% Selection Wing Mounting Type
switch mounting_direction
    case 0
        q5_0 = q5_0;
    case 1
        q5_0 = -pi + q5_0 ; % ribalto la pala      
end

% Vettore dei giunti iniziale
q_0  = [ q1_0+vehicle.cog*(1-cos(q3_0)), q2_0+vehicle.cog*sin(q3_0), q3_0, q4_0, q5_0 ]';
% Vettore velocità giunti iniziale
dq_0 = [ dq1_0, dq2_0, dq3_0, dq4_0, dq5_0 ]';

%%
% Run simulation
ode_num = 45;
q_t = Run(wave_vehicle, wave, ode_num, [q_0; dq_0], dT, T_final);
    
% Get q_t.Data
vehicle_stern_x = q_t.Data(:,1);
vehicle_stern_z = q_t.Data(:,2);
vehicle_pitch   = q_t.Data(:,3);
vehicle_north   = vehicle_stern_x + vehicle.cog*cos(vehicle_pitch);
vehicle_down    = vehicle_stern_z - vehicle.cog*sin(vehicle_pitch);

link_angle    = q_t.Data(:,4);
wing_angle    = q_t.Data(:,5);
vehicle_surge = q_t.Data(:,6);
vehicle_heave = q_t.Data(:,7);

power_el   = 18.7713*1e-3;
power_mech = mean(2*link.friction*q_t.Data(:,9).^2);
efficiency = power_el/power_mech;

% Analysis

% Plots;
% Animation(wave_vehicle, wave, q_t, 'ViewPoint', [45 10]);
% DisplacementVelocity               E' uno script che fa la media del coefficiente delle
%                                    rette di regressione max/min. Ho
%                                    dovuto staccarlo da Simulator perchè
%                                    non funziona in determinate
%                                    circostanze (i.e. T_cut >= T_final, o
%                                    T_final troppo piccolo (non ci sono
%                                    massimi o minimi in quel lasso di
%                                    tempo)

disp('End Simulator_run.m')
toc;