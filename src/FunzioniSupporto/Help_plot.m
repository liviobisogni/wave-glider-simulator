%%
% Script si supporto per la generazione delle matrici BRAKE, PITCH, LINK
% utilizzate dalle funzioni plot_*
%

% Confronto azione freni

plot_brake(BRAKE,PITCH, LINK, dT,T_final)

BRAKE(:,1)=vehicle_north; PITCH(:,1)=vehicle_pitch; LINK(:,1)=link_angle; % B0
BRAKE(:,2)=vehicle_north; PITCH(:,2)=vehicle_pitch; LINK(:,2)=link_angle; % B1
BRAKE(:,3)=vehicle_north; PITCH(:,3)=vehicle_pitch; LINK(:,3)=link_angle; % B2
BRAKE(:,4)=vehicle_north; PITCH(:,4)=vehicle_pitch; LINK(:,4)=link_angle; % B3
BRAKE(:,5)=vehicle_north; PITCH(:,5)=vehicle_pitch; LINK(:,5)=link_angle; % B4

%% 
% Confronto COG con B3 fisso

plot_cog(BRAKE,PITCH, LINK, dT,T_final)

BRAKE(:,1)=vehicle_north-1.1585; PITCH(:,1)=vehicle_pitch; LINK(:,1)=link_angle; % cog identified
BRAKE(:,2)=vehicle_north-1.2085; PITCH(:,2)=vehicle_pitch; LINK(:,2)=link_angle; % cog id + 0.05 m
BRAKE(:,3)=vehicle_north-1.2585; PITCH(:,3)=vehicle_pitch; LINK(:,3)=link_angle; % cog id + 0.10 m
BRAKE(:,4)=vehicle_north-1.3085; PITCH(:,4)=vehicle_pitch; LINK(:,4)=link_angle; % cog id + 0.15 m

%%
% Confronto Simulatori

plot_simulator(BRAKE,PITCH, LINK, dT,T_final)

BRAKE(:,1)=vehicle_north; PITCH(:,1)=vehicle_pitch; LINK(:,1)=link_angle; % simulator
BRAKE(:,2)=vehicle_north; PITCH(:,2)=vehicle_pitch; LINK(:,2)=link_angle; % simulator_new
% BRAKE(:,3)=vehicle_north; PITCH(:,3)=vehicle_pitch; LINK(:,3)=link_angle;
% BRAKE(:,4)=vehicle_north; PITCH(:,4)=vehicle_pitch; LINK(:,4)=link_angle;



