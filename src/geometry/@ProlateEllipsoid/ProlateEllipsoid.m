function self = ProlateEllipsoid(length, diameter, cog, varargin)
%PROLATEELLIPSOID Implementation of a prolate ellipsoid.
%
%   SELF = PROLATEELLIPSOID(LENGTH, DIAMETER, COG)
%       returns an object modelling a prolate ellipsoid, that is an
%       ellipsoid in which the the principal semi-axes a, b and c are
%       subject to the following relationship:
%           a = b < c
%       In this case, a (or b) represents the semi-minor axis, whereas c is
%       the semi-major axis.
%
%   SELF = PROLATEELLIPSOID(___, Property, Value, ...)
%
% References:
% [1] Wikipedia, The free Encyclopedia (Accessed 2016, March). Ellipsoid.
%     URL: https://en.wikipedia.org/wiki/Ellipsoid

    if nargin == 0
        length = 0;
        diameter = 0;
        cog = 0;
    end

    % Check the required input parameters
    assert(isnumeric(length), 'Length must be a numeric value')
    assert(isnumeric(diameter), 'Diameter must be a numeric value')
    assert(isnumeric(cog), 'COG must be a numeric value')

    self.major_axis   = length;
    self.minor_axis   = diameter;
    self.eccentricity = sqrt(1-(self.minor_axis)^2/(self.major_axis)^2);
    self.cog          = cog;

    s = Body(varargin{:});
    
    self = class(self, 'ProlateEllipsoid', s);
end