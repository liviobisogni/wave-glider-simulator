%
% La funzione provvede a graficare displacement e vehicle pitch delle
% simulazioni aventi condizione di mare, freno e COG analoghe ma effettuate
% con i diversi simulatori 'simulator' e 'simultor_new'.
% ( Si vuol confrontare il diverso comportamento dei simulatori pre e post
% aggiornamento)
% 
% Definizione variabili:
%  * brake : è una matrice 6001x5 (60 sec di simulazione), le cui colonne sono in ordine
%            vehicle_north con B0, B1, B2, B3, B4 attivi.
%  * pitch : è una matrice 6001x5 (60 sec di simulazione), le cui colonne sono in ordine
%            vehicle_pitch con B0, B1, B2, B3, B4 attivi.
%
% N.B.: brake, pitch devono essere state create a priori.


function plot_simulator( brake, pitch, link, dT, T_final )

 Time=[0:dT:T_final];  
 
 Trajectory = brake;
 Angle= pitch;
 Link= link;

 f = figure;
 p = uipanel('Parent',f,'BorderType','none'); 
 p.Title = 'Confronto Simulatori - cog11585a045f033B2'; 
 p.TitlePosition = 'centertop'; 
 p.FontSize = 15;
 p.FontWeight = 'bold';

% Displacement
 subplot(2,2,[3,4],'Parent',p);
 hold on
 
 for i=1:length(Trajectory(1,:))
    
    plot(Time, Trajectory(:,i))
    
 end
 
%  i=2;
%  plot(Time, Trajectory(:,i),'LineWidth',2)
 title('Vehicle COG Dispacement')
 xlabel('time [sec]');
 ylabel('[m]')
 legend('simulator','simulator new')
 
 % simulator : simulatore con cui sono state effetuate le 120
 %             simulazioni. Contiene le modifiche apportate
 %             dall'Ing.Fenucci riguardante brake_fnc e wing_velocity
 %             velocità media pesata.
 % simulator new : ultimo simulatore fornito dall'Ing. Fenucci
 %                 senza nessuna rielaborazione. Calcolo COG, superficie
 %                 automatico data WingWidth caratteristica della geometria
 %                 della pala.
 % Simulator_GUI_Version : simulatore che sfrutta la GUI implementata.
 % Simulator_Code_Version : simulatore post update con l'aggiunta dei flag
 %                           per render più agevole l'impostazione di simulazione.
 %                              NON usa la GUI.
 %                              

 
 % vehicle Pitch
 subplot(2,2,1,'Parent',p);
 hold on
 
 for i=1:length(Angle(1,:))
    
    plot(Time, rad2deg(Angle(:,i)))
    
 end
 
%  plot(Time, rad2deg(Angle(:,i)),'LineWidth',2)
 title('Vehicle Pitch')
 xlabel('time [sec]');
 ylabel('[deg]')
 legend('simulator','simulator new')
 
 % Link angle
 subplot(2,2,2,'Parent',p);
 hold on
 
 for i=1:length(Link(1,:))
    
    plot(Time, rad2deg(Link(:,i)))
    
 end
 
%  plot(Time, rad2deg(Link(:,i)),'LineWidth',2)
 title('Link Angle')
 xlabel('time [sec]');
 ylabel('[deg]')
 legend('simulator','simulator new')
 
end



