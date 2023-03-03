function self = RightPrism(base, height, varargin)
%RIGHTPRISM Implementation of a right prism.
%
%   SELF = RIGHTPRISM(BASE, HEIGHT)
%       returns an object modelling a right prism with a generic-shaped
%       base face.
%
%   SELF = RIGHTPRISM(___, Property, Value, ...)

    if nargin == 0
        base = Shape();
        height = 0;
    end

    % Check the required input parameters
    assert(isa(base, 'Shape'), 'Base must be a shape.')
    assert(isnumeric(height), 'Height must be a numeric value.')

    self.base   = base;
    self.height = height;

    s = Body(varargin{:});

    self = class(self, 'RightPrism', s);
end