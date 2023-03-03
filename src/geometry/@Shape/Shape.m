function self = Shape(length, width)
%SHAPE Implementation of a generic shape.
%
%   SELF = SHAPE(LENGTH, WIDTH)
%       returns an object modelling a generic planar shape.

    if nargin == 0
        length = 0;
        width = 0;
    end

    % Check the required input parameters
    assert(isscalar(length) && isnumeric(length), ...
        'Length must be a numeric value')
    assert((isscalar(width) && isnumeric(width)) || isa(width, 'function_handle'), ...
        'Width must be either a numeric value or a function handle')

    self.length = length;
    self.width = width;

    self = class(self, 'Shape');
end