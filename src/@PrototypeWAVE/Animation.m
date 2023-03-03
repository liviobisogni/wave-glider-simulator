function Animation(model, sea_wave, trajectory, varargin)
% ANIMATION Displays an animation of the WAVE prototype for the given
%           trajectory.
%
%    ANIMATION(MODEL, SEA_WAVE, TRAJECTORY)
%       returns the value of the inertia matrix B(q) evaluated on the basis
%       of the prototype dynamics parameters for a particular value of the
%       joint variables Q.

% Parse optional arguments
p = inputParser;
addParameter(p, 'vehicle', true, @islogical);
addParameter(p, 'recordvideo', false, @islogical);
addParameter(p, 'seawavevelocity', false, @islogical);
addParameter(p, 'vehiclevelocity', false, @islogical);
addParameter(p, 'viewpoint', [0 0], @(x) isnumeric(x) && isvector(x) && length(x) == 2);
parse(p,varargin{:});
params = p.Results;

% Animation flags
PLOT_WAVE_VELOCITY    = params.seawavevelocity;
PLOT_VEHICLE_VELOCITY = params.vehiclevelocity;
PLOT_VEHICLE          = params.vehicle;
RECORD_VIDEO          = params.recordvideo;

if RECORD_VIDEO
   vw = VideoWriter('Simulation.mp4', 'MPEG-4');
   vw.FrameRate = 1/mean(diff(trajectory.Time(1:10:end)));
   open(vw);
end

% Coordinates transformation matrix from the base navigation frame {b} to
% the animation reference frame {a}
a_T_b = [ 1 0 0 0; 0 -1 0 0; 0 0 -1 0; 0 0 0 1];

% Animation
wave_prototype = vehicleDraw(model);
x_min = -5; x_max = 5;
y_min = -3; y_max = 3;
z_min = -2; z_max = 1.5;    

close all;

figure(1)
h_1 = subplot(3,1,1:2, 'XTickLabel', [], 'YTickLabel', [], 'ZTickLabel', []);
view(h_1, params.viewpoint(1), params.viewpoint(2));    % Set X-Z plane as default view
grid on; hold on; axis equal;
h_2 = subplot(3,1,3); grid on; hold on;
set(h_2, 'FontSize',12, 'TickLabelInterpreter', 'latex');
xlabel(h_2, '\textbf{Time (s)}', 'Interpreter', 'latex');
ylabel(h_2, '$\mathbf{q_4}$ \textbf{(deg)}', 'Interpreter', 'latex');

% #########################################################################
% #                               Animation                               #
% #########################################################################
for i = 1:10:length(trajectory.Time)
    cla(h_1);
    axis(h_1, [x_min x_max y_min y_max z_min z_max])

    % Plot the wave
    [x_wave, y_wave] = meshgrid(x_min:0.1:x_max, y_min:0.1:y_max );
    z_wave = -height(sea_wave, x_wave, trajectory.Time(i));
    surf(h_1, x_wave, y_wave, z_wave, 'EdgeColor', 'none', ...
        'FaceColor', 'cyan', 'FaceAlpha', .5);                      % Roof
    surf(h_1, [x_wave(end,:); x_wave(end,:)], [y_wave(end,:); y_wave(end,:)], ...
        [z_min*ones(1, size(z_wave,2)); z_wave(end,:)], 'EdgeColor', 'none', ...
        'FaceColor', 'cyan', 'FaceAlpha', .5);                      % Back wall
    surf(h_1, [x_wave(1,:); x_wave(1,:)], [y_wave(1,:); y_wave(1,:)], ...
        [z_min*ones(1, size(z_wave,2)); z_wave(1,:)], 'EdgeColor', 'none', ...
        'FaceColor', 'cyan', 'FaceAlpha', .5);                      % Front wall
    surf(h_1, [x_wave(:,end) x_wave(:,end)]', [y_wave(:,end) y_wave(:,end)]', ...
        [z_min*ones(size(z_wave,1), 1) z_wave(:,end)]', 'EdgeColor', 'none', ...
        'FaceColor', 'cyan', 'FaceAlpha', .5);                      % Right wall
    plot3(h_1, x_wave(end,:), y_wave(end,:), z_wave(end,:), 'w');   % Back edge
    plot3(h_1, x_wave(1,:), y_wave(1,:), z_wave(1,:), 'w');         % Front edge
    plot3(h_1, x_wave(:,end), y_wave(:,end), z_wave(:,end), 'w');   % Right edge

    if PLOT_WAVE_VELOCITY   % Plot the wave velocity field
        x_wave = x_min:0.5:x_max;
        for x = x_wave
            [y_wave, z_wave] = meshgrid(y_min:0.5:y_max, ...
                z_min:0.2:-height(sea_wave, x, trajectory.Time(i)));
            wave_velocity = velocity(sea_wave, x, -z_wave(:,1), trajectory.Time(i));
            quiver3(h_1, x*ones(size(y_wave)), y_wave, z_wave, ...
                repmat(wave_velocity(1,:)', 1, size(y_wave,2)), zeros(size(y_wave)), ...
                -repmat(wave_velocity(2,:)', 1, size(y_wave,2)), ...
                'LineWidth', 1.5, 'Color', 'red');
        end
    end

    if PLOT_VEHICLE
        % Evaluate the coordinate transformation matrices from the bodies
        % reference frames {v}, {l} and {w} to the animation reference frame
        a_T_v = a_T_b*RotoTranslation(model, trajectory.Data(i,:), 'vehicle');
        a_T_l = a_T_b*RotoTranslation(model, trajectory.Data(i,:), 'link');
        a_T_w = a_T_b*RotoTranslation(model, trajectory.Data(i,:), 'wing');

        hull_a = (a_T_v*[ wave_prototype.hull.x(:) wave_prototype.hull.y(:) ...
            wave_prototype.hull.z(:), ones(numel(wave_prototype.hull.x),1)]')';
        link1_a = (a_T_l*[ wave_prototype.link1.x(:) wave_prototype.link1.y(:) ...
            wave_prototype.link1.z(:), ones(numel(wave_prototype.link1.x),1)]')';
        wing1_a = (a_T_w*[ wave_prototype.wing1.x(:) wave_prototype.wing1.y(:) ...
            wave_prototype.wing1.z(:), ones(numel(wave_prototype.wing1.x),1)]')';

        % Plot the vehicle
        cog_a = a_T_v*[model.cog.vehicle 0 0 1]';
        plot3(h_1, cog_a(1)*[1 1], [0 0], [z_min z_max], 'k--' )
        text(h_1, cog_a(1), 0, z_max, num2str(cog_a(1)), ...
            'FontSize', 12, 'Interpreter', 'latex', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom');
        mesh(h_1, reshape(hull_a(:,1), size(wave_prototype.hull.x)), ...
            reshape(hull_a(:,2), size(wave_prototype.hull.x)), ...
            reshape(hull_a(:,3), size(wave_prototype.hull.x)), ...
            'FaceColor', 'yellow', 'EdgeColor', 'yellow');
        mesh(h_1, reshape(link1_a(:,1), size(wave_prototype.link1.x)), ...
            reshape(link1_a(:,2), size(wave_prototype.link1.x)), ...
            reshape(link1_a(:,3), size(wave_prototype.link1.x)), ...
            'FaceColor', [.7 .7 .7], 'EdgeColor', 'black');
        mesh(h_1, reshape(link1_a(:,1), size(wave_prototype.link1.x)), ...
            -reshape(link1_a(:,2), size(wave_prototype.link1.x)), ...
            reshape(link1_a(:,3), size(wave_prototype.link1.x)), ...
            'FaceColor', [.7 .7 .7], 'EdgeColor', 'black');
        mesh(h_1, reshape(wing1_a(:,1), size(wave_prototype.wing1.x)), ...
            reshape(wing1_a(:,2), size(wave_prototype.wing1.x)), ...
            reshape(wing1_a(:,3), size(wave_prototype.wing1.x)), ...
            'FaceColor', 'r', 'EdgeColor', 'r');
        mesh(h_1, reshape(wing1_a(:,1), size(wave_prototype.wing1.x)), ...
            -reshape(wing1_a(:,2), size(wave_prototype.wing1.x)), ...
            reshape(wing1_a(:,3), size(wave_prototype.wing1.x)), ...
            'FaceColor', 'r', 'EdgeColor', 'r');
    end

    if PLOT_VEHICLE_VELOCITY
       % Evaluate the vehicle and the wave velocity in the XZ plane
        vehicle_pos_v = [ model.samples.vehicle; ...
            zeros(2,length(model.samples.vehicle)); ones(size(model.samples.vehicle)) ];
        vehicle_pos_b = RotoTranslation(model, trajectory.Data(i,:), 'vehicle')*vehicle_pos_v;
        J_i = arrayfun(@(x) Jacobian(model, trajectory.Data(i,:), 'vehicle', [x 0]), ...
            vehicle_pos_v(1,:)', 'UniformOutput', false );
        vehicle_vel_b = [1 0 0; 0 1 0]*reshape(vertcat(J_i{:})*trajectory.Data(i,6:8)', 3, size(vehicle_pos_v,2));
        wave_vel_b    = velocity(sea_wave, vehicle_pos_b(1,:), vehicle_pos_b(3,:), trajectory.Time(i));
        rel_vel_b     = vehicle_vel_b-wave_vel_b;

        % Plot the vehicle velocity
        vehicle_pos_a = a_T_b*vehicle_pos_b;
        quiver3(h_1, vehicle_pos_a(1,:), vehicle_pos_a(2,:), vehicle_pos_a(3,:), ...
            wave_vel_b(1,:), zeros(1,model.n_samples.vehicle), -wave_vel_b(2,:), ...
            'AutoScale', 'off', 'LineWidth', 1.5, 'Color', 'red');
        quiver3(h_1, vehicle_pos_a(1,:), vehicle_pos_a(2,:), vehicle_pos_a(3,:), ...
            vehicle_vel_b(1,:), zeros(1,model.n_samples.vehicle), -vehicle_vel_b(2,:), ...
            'AutoScale', 'off', 'LineWidth', 1.5, 'Color', [0 0.5 0]);
        quiver3(h_1, vehicle_pos_a(1,:), vehicle_pos_a(2,:), vehicle_pos_a(3,:), ...
            rel_vel_b(1,:), zeros(1,model.n_samples.vehicle), -rel_vel_b(2,:), ...
            'AutoScale', 'off', 'LineWidth', 1.5, 'Color', 'blue');
    end

    % Display current time
    text(h_1,  x_max-(x_max-x_min)/7, y_max, 1.3, [ '\textbf{t=', num2str(trajectory.Time(i)), '}'], ...
        'FontSize', 14, 'Interpreter', 'latex');
    
    z_tick = h_1.ZTick;
    z_ticklabel = strcat(strtrim(cellstr(num2str(z_tick'))), {' m'});
    z_tick([1, end]) = z_tick([1, end]) + [0.1 -0.1];
    text((h_1.XLim(1)+0.1)*ones(size(z_tick)), y_min*ones(size(z_tick)), z_tick, z_ticklabel, ...
        'Parent', h_1, 'FontSize', 12, 'Interpreter', 'latex')
    
    % #####################################################################
    % #                               Angles                              #
    % #####################################################################
    cla(h_2);
    plot(h_2, trajectory.Time, rad2deg(trajectory.Data(:,4)), 'LineWidth', 1);
    actual_time = trajectory.Time(i)-trajectory.Time(1);
    plot(h_2, [actual_time, actual_time], get(h_2, 'YLim'), 'k', 'LineWidth', 1)
    if(trajectory.Time(end)-trajectory.Time(1) < 10)
        axis tight
    elseif(actual_time >= 5)
        xlim(h_2, [actual_time-5 actual_time+5])
    else
        xlim(h_2, [0 10])
    end
    if RECORD_VIDEO
        writeVideo(vw, getframe(h_1));
    end
    drawnow;
end

if RECORD_VIDEO
    close(vw);
end

end

function model_mesh = vehicleDraw(model)

% #########################################################################
% #                             Hull drawing                              #
% #########################################################################

% Construct the vehicle bow and stern as semi-ellipsoid, each one having
% length equal to the 8% of the total length of the vehicle
v_length = model.length.vehicle;
v_radius = model.diameter.vehicle/2;
h_ellipse  = 0.08*v_length; 
[x1,y1,z1] = ellipsoid(0,0,0,v_radius,v_radius,h_ellipse);

% Stern - ellipsoid back
xb1=x1(1:11,:);
yb1=y1(1:11,:);
zb1=z1(1:11,:);

% Bow - ellipsoid front
xf1=x1(10:end,:);
yf1=y1(10:end,:);
zf1=z1(10:end,:);

% Construct the vehicle body as a (vertical) cylinder with length equal to
% the remaining part (84% of the total length)
h_cylinder = v_length-2*h_ellipse;
[xc,yc,zc] = cylinder(v_radius);
zc = h_cylinder*zc;     % Stretch the cylinder to reach the desired length 

% Put the bow on top of the hull
zf1 = zf1 + h_cylinder.*ones(size(xf1));

% Construct the hull by assembling stern, body and bow in sequence; then,
% adjust the hull position and orientation to reach the desired pose in the
% vehicle-fixed reference frame
hull.x = [zf1; zc; zb1]-h_cylinder/2*0+h_ellipse;
hull.y = [xf1; xc; xb1];
hull.z = [yf1; yc; yb1];

model_mesh.hull = hull;

% #########################################################################
% #                             Link drawings                             #
% #########################################################################

% Construct the link as a parallelepiped
l_length = model.length.link;
l_width  = model.width.link;
l_height = model.height.link;

% Construct the link as a parallelepiped (q4=0 configuration with the link
% aligned with the body of the vehicle)
[xp,yp,zp] = parallelepiped(l_length,l_width,l_height);

link.x = xp;
link.y = zp - l_width/2;
link.z = v_radius + yp;

model_mesh.link1 = link;
model_mesh.link2 = link;
model_mesh.link2.z = -model_mesh.link2.z;

% #########################################################################
% #                             Wing drawings                             #
% #########################################################################
w_length = model.length.wing;
w_width  = model.width.wing;
w_height = model.height.wing;

% Construct the wing
[xw,yw,zw] = wing_shape(w_length, w_width, w_height);

% Construct the wing; then, rotate the coordinates to reach the desired 
% pose.
wing.x = xw;
wing.y = zw-w_height/2;
wing.z = yw + v_radius;

model_mesh.wing1 = wing;
model_mesh.wing2 = wing;
model_mesh.wing2.z = -model_mesh.wing2.z;

% figure(2), hold on
% title('Top view')
% set(gca, 'Color', 'c')
% mesh(hull.x, hull.y, hull.z, 'EdgeColor', 'y', 'FaceColor', 'y')
% mesh(link.x, link.y, link.z, 'EdgeColor', 'k', 'FaceColor', 'k')
% mesh(wing.x, wing.y, wing.z, 'EdgeColor', 'r')
% mesh(link.x, link.y, -link.z, 'EdgeColor', 'k', 'FaceColor', 'k')
% mesh(wing.x, wing.y, -wing.z, 'EdgeColor', 'r')
% xlabel('x'); ylabel('y'); zlabel('z');
% axis equal

end

function [xp, yp, zp] = parallelepiped(length, width, height)
    xp = length*[ repmat([0 1], [2 4]), zeros(2), ones(2)];
    yp = width*[ repmat([0 1]', [1 4]), zeros(2), ones(2), repmat([0 1]', [1 4]) ];
    zp = height*[ zeros(2), ones(2), repmat([0 1]',[1 4]), repmat([0 1],[2 2])];
end

function [xw, yw, zw] = wing_shape(length, width, height, N)
    if nargin == 3
       N = 100; 
    end

    x_samples = linspace(0, length, N);
    xw = repmat(x_samples, [2 2]);
    yw = repmat([ zeros(1,N); width(x_samples) ], [1 2]);
    zw = height*[ zeros(2,N), ones(2,N)];
end