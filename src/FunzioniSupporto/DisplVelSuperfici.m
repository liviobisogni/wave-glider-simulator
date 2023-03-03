% Plot Displacement Velocity due to Surface Variation

close all

% Profilo esponenziale 1
x1 = [0.8, 0.9, 1, 1.1, 1.2, 1.3];
y1 = abs([-0.00359, -0.00379, -0.00377, -0.00401, -0.00424, -0.00435]);
% Profilo esponenziale 2
x2 = [0.8, 0.9, 1, 1.1, 1.2, 1.3];
y2 = abs([ -0.00374, -0.00389, -0.00403, -0.00415, -0.00425, -0.00435]);


% Plot
figure
plot(x1,y1,'-o');
axis([0.7 1.4 0.003 0.005 ])
hold on; grid on
plot(x2,y2,'-o');
legend('Profilo esponenziale 1', 'Profilo esponenziale 2');
xlabel('Surface % (refferred to S=0.2217 m^2)')
ylabel('Displacement Velocity [m/s]')
title('Relation between Wing Surface and Displacement Velocity')

