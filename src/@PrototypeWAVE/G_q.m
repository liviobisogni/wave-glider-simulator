function G = G_q( model, q )
%G_Q Evaluates the vector of gravitational forces and moments g(q) for the
% WAVE prototype.
%
%    G = G_Q( MODEL, Q )
%       returns the value of the vector of gravitational forces and moments
%       G(q) evaluated on the basis of the prototype dynamic parameters for
%       a particular value of the joint variables Q. The vehicle is assumed
%       to have the Centre Of Gravity (COG) lower with respect to the
%       Centre Of Buoyancy (COB), each one located at distance radius/2
%       from the midline. The buoyancy contribution is evaluated only for
%       the parts of the vehicle actually submerged on the basis of the
%       current wave profile.
%
% References:
% [1] Caiti, Andrea et al. (2012). Lagrangian Modelling of an Underwater
%     Wave Glider. Ship Technology Research. 59 (1), pp. 6-12.

% Masses
m1 = model.mass.vehicle;
m2 = model.mass.link;
m3 = model.mass.wing;

% Buoyancies
b1 = model.buoyancy.vehicle;
b2 = model.buoyancy.link;
b3 = model.buoyancy.wing;

% Gravity
g = model.gravity;

% Submerged percentage og the vehicle and of the wing
uw_perc_v = model.submerged_perc.vehicle;
uw_perc_w = model.submerged_perc.wing;

% Centre Of Gravity (COG) and Centre Of Buoyancy (COB) of the vehicle in
% the vehicle-fixed frame {4} illustrated in [1].
cog1 = [ model.cog.vehicle; 0];
cob1 = [ model.cob.vehicle; model.diameter.vehicle/2 ];

% Centre Of Buoyancy (COB) of the wing in the wing-fixed frame {6}
% illustrated in [1].
cob3 = [ model.cob.wing; 0 ];

% Gravitational forces acting on the bodies constituting the prototype
G_vehicle = - [ Jacobian(model, q, 'vehicle', cog1)'*[0; m1*g; 0] + ...
    Jacobian(model, q, 'vehicle', cob1)'*[0; -b1*g*uw_perc_v; 0]; 0; 0];
G_link    = - [ Jacobian(model, q, 'link')'*[0; -(b2-m2)*g; 0]; 0 ];
G_wing    = - ( Jacobian(model, q, 'wing')'*[0; m3*g; 0] + ...
    Jacobian(model, q, 'wing', cob3)'*[0; -b3*g*uw_perc_w; 0] );

G = G_vehicle + G_link + G_wing;
end

