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

% Variabili globali
global wave;  global hull; global link_; global q_0; global dq_0; global wing_; global wave_vehicle; 
global q_t; global vehicle_stern_x; global vehicle_stern_z; global vehicle_pitch; global vehicle_north;
global vehicle_down; global link_angle; global wing_angle; global vehicle_surge; global vehicle_heave;
global power_el; global power_mech; global efficiency;  global dT; global T_final; global T_cut; 
global vel_displacement;

% #########################################################################
% #                         Simulation parameters                         #
% #########################################################################

% Physical constants
rho_water     = 1025;               % Water density     [kg/m^3]
mu_water      = 0.0105*rho_water;   % Water viscosity   [PI (Pa*s)]
rho_aluminium = 2700;               % Aluminium density [kg/m^3]

% Simulation time
dT      = 0.01;                     % Time step [s]
T_final = 60;                       % Duration  [s]
T_cut = 30;                         % Tempo di fine transitorio [s]

% #########################################################################
% #                         Wave characteristics                          #
% #########################################################################
wave_amplitude = 0.45; % [m]
wave_frequency = 0.33;  % [Hz]
seabed_depth   = 3.5;   % [m]

% #########################################################################
% #                       WAVE prototype modelling                        #
% #########################################################################
vehicle.length     = 2.682;                                         % [m]
vehicle.diameter   = 0.155;                                         % [m]
vehicle.cog        = 1.1585; % Default                              % [m]                   IDENTIFIED
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

wing.min_length   = 0.15;                                           % [m]
wing.max_length   = 0.80;                                           % [m]
wing.min_width    = 0.0975;                                         % [m]
wing.max_width    = 0.40;                                           % [m]
wing.alpha        = 5;                                              % []
wing.height       = 0.002;                                          % [m]
wing.mounting     = wing.max_length/2; % Default                    % [m]
wing.drag_coeff   = [49.935 49.935 0];                              % []                    IDENTIFIED


% Brake functions
B1 = @(q,dq,v) v(1) > 0;
B2 = @(q,dq,v) v(1) > 0 && q(4) > pi/2 && abs(dq(4)) <= 1e-2;
B3 = @(q,dq,v) v(1) > 0 && v(2) > 0;
B4 = @(q,dq,v) v(1) > 0 && q(4) > pi/2;


% Initial conditions
% Angle
q1_0 = 0;       % [m]
q2_0 = 0;       % [m]
q3_0 = 0;       % [rad]
q4_0 = pi/2;    % [rad]
q5_0 = -pi/6;   % [rad]

% Velocity
dq1_0=0; 
dq2_0=0;
dq3_0=0;
dq4_0=0;
dq5_0=0;


%%
% Inizializzo la velocità di arretramento; 
vel_displacement = 0;
 
% Flag Controllo Profilo Pala
wing.profiloPala  = 1;

% Flag scelta Brake Action
brake_fcn = B2; % B1,B2,B3,B3

% Flag scelta Modality Recharge/Propulsion
freno = 1;     % se 0 --> recharge, se 1 ---> freno

% Flag Controllo Montaggio Pala
mounting_direction = 0; % se 0 --> straight, se 1 --> reverse

% Flag Controllo Punto Montaggio Pala
mounting_point = 1; % se 0 --> Top , se 1 --> Center , se 2 --> Bottom
 
%%
% Launch GUI
GUI_Simulator