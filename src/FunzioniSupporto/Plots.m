close all 

Time = 0:dT:T_final; %%%riga aggiunta da me (serve se vuoi avere i plot, in teoria)

figure(2), grid on, hold on
plot(Time, vehicle_north);
plot(Time, vehicle_down);
plot(Time, rad2deg(vehicle_pitch));
legend('vehicle north','vehicle down','vehicle pitch');
xlabel('Time [s])');
ylabel('[m]');

figure(3), grid on, hold on
plot(Time, vehicle_surge);
plot(Time, vehicle_heave);
legend('vehicle surge','vehicle heave');
xlabel('Time [s]');
ylabel('[m]');

figure(4), grid on, hold on
plot(Time, rad2deg(vehicle_pitch));
plot(Time, rad2deg(link_angle));
plot(Time, rad2deg(wing_angle));
legend('vehicle pitch','link angle','wing angle');
xlabel('Time [s]');
ylabel('°');

%%% Da qui in poi puoi proprio cancellare il codice!!!
% ref_fig = openfig('Test10.fig');
% plot(ref_fig.Children(1), Time+84, rad2deg(vehicle_pitch));
% plot(ref_fig.Children(2), Time+84, -rad2deg(link_angle));
% 
% ref_fig = openfig('Coefficient.fig');
% plot(ref_fig.Children, mean(Results(:,9).^2), 1e3*power_el, 'k*', ...
%     'LineWidth', 2, 'MarkerSize', 10);
% text(mean(Results(:,9).^2), 1e3*power_el, '6', ...
%     'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')


%%% Comunque Davide Fenucci NON usa mai questi plot... modificali pure (o non usarli proprio)!!!!

%%% NB: alla fine della simulazione viene automaticamente generato un
%%% video-animazione