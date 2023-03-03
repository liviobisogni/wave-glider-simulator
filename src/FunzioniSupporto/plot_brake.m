%
% La funzione provvede a graficare displacement e vehicle pitch delle
% simulazioni aventi condizione di mare e COG analoghi e azione di freno
% differente.
% (Si vogliono confrontare le diverse azioni dei freni a parità di mare e
% COG)
% 
% Definizione variabili:
%  * brake : è una matrice 6001x5 (60 sec di simulazione), le cui colonne sono in ordine
%            vehicle_north con B0, B1, B2, B3, B4 attivi.
%  * pitch : è una matrice 6001x5 (60 sec di simulazione), le cui colonne sono in ordine
%            vehicle_pitch con B0, B1, B2, B3, B4 attivi.
%
% N.B.: brake, pitch devono devono essere state create a priori.

function plot_brake( brake, pitch, link, dT, T_final )


 Time=[0:dT:T_final];  
 
 
 Trajectory = brake;
 Angle= pitch;
 Link= link;

 f = figure;
 p = uipanel('Parent',f,'BorderType','none'); 
 p.Title = 'Amplitude: 0.45 [m]   Frequency: 0.33 [Hz]   COG: 1.2585 [m]'; 
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
 legend('B0','B1','B2','B3','B4')

 
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
 legend('B0','B1','B2','B3','B4')
 
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
 legend('B0','B1','B2','B3','B4')

end



