% This file implements a simulator of the dynamics of the prototypal
% vehicle with energy harvesting capabilities developed within the Italian 
% WAVE project. The vehicle dynamics used in this simulator is adapted from
% the Langrangian modelling described in [1], [2].
%
% References:
% [1] Calabrò, Vincenzo (2012). Veicolo Autonomo Ibrido con Capacità di 
%     Wave-Gliding (VAI): Progetto del Sistema e Verifica delle 
%     Funzionalità e dei Requisiti. ISME - CSSN.
% [2] Caiti, Andrea et al. (2012). Lagrangian Modelling of an Underwater 
%     Wave Glider. Ship Technology Research. 59 (1), pp. 6-12.
% [3] Salmon, Rick (2008). Introduction to ocean waves. Scripps Institution
%     of Oceanography, University of California, San Diego. p. 8.
clear; clear classes; clc; close all;
addpath('geometry');

% #########################################################################
% #                         Simulation parameters                         #
% #########################################################################

% Physical constants
rho_water     = 1025;               % Water density     [kg/m^3]
mu_water      = 0.0105*rho_water;   % Water viscosity   [PI (Pa*s)]
rho_aluminium = 2700;               % Aluminium density [kg/m^3]

% Simulation time
dT      = 0.01;                     % Time step [s]
T_final = 1;                       % Duration  [s]

%%
% #########################################################################
% #                         Wave characteristics                          #
% #########################################################################
wave_amplitude = 0.45;  % [m]
wave_frequency = 0.33;  % [Hz]
seabed_depth   = 3.5;   % [m]

% Wave Object
wave = SeaWave(wave_amplitude, wave_frequency, ...
    'Direction', 'left');

%%
% #########################################################################
% #                       WAVE prototype modelling                        #
% #########################################################################
vehicle.length     = 2.682;                                         % [m]
vehicle.diameter   = 0.155;                                         % [m]
vehicle.cog        = 1.1585;                                        % [m]                   IDENTIFIED
vehicle.mass       = 38.3;                                          % [kg]
vehicle.buoyancy   = 45.279;                                        % [kg]                  IDENTIFIED
vehicle.friction   = [31.247 15.833 22.157];                        % [kg/s kg/s kg*m/s]    IDENTIFIED
vehicle.drag_coeff = [0.2, 1.05, 2.3487];                           % []                    IDENTIFIED
vehicle.link_joint = 1.706;                                         % [m]

link.length     = 0.70;                                             % [m]
link.width      = 0.03;                                             % [m]
link.height     = 0.05;                                             % [m]
link.mass       = 1.32;                                             % [kg]
link.wing_joint = link.length;                                      % [m]
link.friction   = 19.468;                                           % [kg*m/s]              IDENTIFIED

% min_length, max_length, min_width, max_width, alpha
% wing_1 = GraalTechWing(0.10, 0.40, 0.10, 0.40);
% wing_2 = GraalTechWing(0.15, 0.80, 0.0975, 0.40);
% wing_3 = GraalTechWing(0.15, 0.40, 0.0975, 0.80);
% wing_4 = ExponentialWing(0.15, 0.80, 0.0975, 0.40, 5);

wing.min_length   = 0.15;                                           % [m]
wing.max_length   = 0.80;                                           % [m]
wing.min_width    = 0.0975;                                         % [m]
wing.max_width    = 0.40;                                           % [m]
wing.alpha        = 1.15;                                           % []
wing.height       = 0.002;                                          % [m]
wing.mounting     = wing.max_length/2;                              % [m]
wing.drag_coeff   = [49.935 49.935 0];                              % []                    IDENTIFIED

%%
% Variabile Controllo Punto Montaggio
mounting_point= 1;

% Mounting Point
switch mounting_point
    case 0
        wing.mounting = 0;
    case 1
        wing.mounting = wing.max_length/2;
    case 2
        wing.mounting = wing.max_length;
end
    
%%
% Variabile Controllo Profilo Pala
wing.profiloPala  = 1; 

% Profilo Pala
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
% Wing Object
wing_ = RightPrism(myWing, wing.height, 'Drag', wing.drag_coeff, ...
    'Mounting', wing.mounting, 'MaterialDensity', rho_aluminium, 'WaterDensity', rho_water);

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

% Brake Conditions
B1 = @(q,dq,v) v(1) > 0;
B2 = @(q,dq,v) v(1) > 0 && q(4) > pi/2 && abs(dq(4)) <= 1e-2;
B3 = @(q,dq,v) v(1) > 0 && v(2) > 0;
B4 = @(q,dq,v) v(1) > 0 && q(4) > pi/2;

% Variabile Controllo Brake Action
brake_fcn = B2;

% Variabile Controllo Modalità Recharge/Propulsion
freno = 1;

% Modality Recharge/Propulsion
switch freno
    case 0
       % Creo Wave_Vehicle Object
       wave_vehicle = PrototypeWAVE( hull, link_, wing_, 'WingSamples', 10,'quiet', true);
    case 1
       % Creo Wave_Vehicle Object
       wave_vehicle = PrototypeWAVE( hull, link_, wing_, 'WingSamples', 10, 'quiet', true, 'BrakeFcn', brake_fcn);
end

%%
% Initial conditions
% Generalized Positions
q1_0 = 0;       % [m]                            
q2_0 = 0;       % [m]                                
q3_0 = 0;       % [rad]                          
q4_0 = pi/2;    % [rad]                          
q5_0 = -pi/6;   % [rad]

% Velocity
dq1_0 = 0;       % [m/s]
dq2_0 = 0;       % [m/s]
dq3_0 = 0;       % [rad/s]
dq4_0 = 0;       % [rad/s]
dq5_0 = 0;       % [rad/s]

%%
% Varibiabile Controllo Montaggio Pala
mounting_direction = 0; 

% Verso Montaggio Pala
switch mounting_direction
    case 0
        q5_0 = q5_0;
    case 1
        q5_0 = -pi + q5_0 ; % ribalto la pala      
end

%%
% Vettore dei giunti iniziale
q_0  = [ q1_0+vehicle.cog*(1-cos(q3_0)), q2_0+vehicle.cog*sin(q3_0), q3_0, q4_0, q5_0 ]';
% Vettore velocità giunti iniziale
dq_0 = [ dq1_0, dq2_0, dq3_0, dq4_0, dq5_0 ]';

% Run simulation
tic;
ode_num = 45;
q_t = Run(wave_vehicle, wave, ode_num, [q_0; dq_0], dT, T_final);
toc;

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

% Analisys

% Plots;
% Animation(wave_vehicle, wave, q_t, 'ViewPoint', [45 10]);

% Velocità Arretramento 
T_cut=30;
DisplacementVelocity;