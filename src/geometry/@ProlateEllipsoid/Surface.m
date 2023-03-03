function S = Surface(self)
%SURFACE Returns the surface area of a prolate ellipsoid.
%
%   S = SURFACE( SELF )
%       returns the surface area of a prolate ellipsoid with semi-axes long
%       a and c, evaluated as:
%           S = 2*pi*a^2*(1+c/(a*e)*asin(e))
%
% References:
% [1] Wikipedia, The free Encyclopedia (Accessed 2018, June). Ellipsoid.
%     URL: https://en.wikipedia.org/wiki/Ellipsoid#Surface_area

a = self.diameter/2;    % Semi-minor axis
c = self.length/2;      % Semi-major axis
e = self.eccentricity;  % Eccentricity

S = 2*pi*a^2*(1+c/(a*e)*asin(e));
end

