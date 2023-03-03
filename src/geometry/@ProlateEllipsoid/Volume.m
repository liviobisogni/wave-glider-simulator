function V = Volume(self)
%VOLUME Evaluates the volume of a prolate ellipsoid.
%
%   V = VOLUME(SELF) 
%       returns the volume of a prolate ellipsoid with semi-axes long a and 
%       c, evaluated as:
%           V = 4/3*pi*(c*a^2)
%
% References:
% [1] Wikipedia, The free Encyclopedia (Accessed 2016, March). Ellipsoid.
%     URL: https://en.wikipedia.org/wiki/Ellipsoid#Volume

a = self.minor_axis/2;  % Semi-minor axis
c = self.major_axis/2;  % Semi-major axis

V = 4/3*pi*(c*a^2);
end