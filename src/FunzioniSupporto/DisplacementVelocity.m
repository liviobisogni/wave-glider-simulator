%
% Lo script retituisce la velocità media di spostamento del cog del
% veicolo.
%
% 
% coeff_max = vel_displ_with_max(vehicle_north, T_cut, dT, T_final);
% coeff_min = vel_displ_with_min(vehicle_north, T_cut, dT, T_final);
% 

vel_displacement = (vel_displ_with_max(vehicle_north, T_cut, dT, T_final) + vel_displ_with_min(vehicle_north, T_cut, dT, T_final))/2 ;