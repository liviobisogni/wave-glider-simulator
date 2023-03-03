function I = GeometricInertia(self)
%GEOMETRICINERTIA Evaluates the inertia matrix of a prolate ellipsoid-shaped 
% body.
%
%   I = GEOMETRICINERTIA( SELF )
%       returns the geometric moment of inertia matrix for a prolate
%       ellipsoid-shaped body with semi-axes long a and c.
%
% References:
% [1] Wikipedia, The free Encyclopedia (Accessed 2016, March). Ellipsoid.
%     URL: https://en.wikipedia.org/wiki/Ellipsoid#Dynamical_properties

a = self.minor_axis/2;
c = self.major_axis/2;

Ixx = (a^2+a^2)/5;
Iyy = (a^2+c^2)/5;
Izz = (c^2+a^2)/5;
I = diag([Ixx Iyy Izz]);
end