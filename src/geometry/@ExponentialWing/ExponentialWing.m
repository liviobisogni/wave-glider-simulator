function self = ExponentialWing(min_length, max_length, min_width, max_width, alpha)
%EXPONENTIALWING Implementation of an exponential wing.
%
%   SELF = EXPONENTIALWING(MIN_LENGTH, MAX_LENGTH, MIN_WIDTH, MAX_WIDTH, ALPHA)
%       returns an object modelling the wing shape with an eponential one.

    if nargin == 0
        min_length = 0;
        max_length = 0;
        min_width = 0;
        max_width = 0;
        alpha = 0;
    end

    % Check the required input parameters
    assert(isscalar(min_length) && isnumeric(min_length), ...
        'Minimum length must be a numeric value');
    assert(isscalar(max_length) && isnumeric(max_length), ...
        'Maximum length must be a numeric value');
    assert(isscalar(min_width) && isnumeric(min_width), ...
        'Minimum width must be a numeric value');
    assert(isscalar(max_width) && isnumeric(max_width), ...
        'Maximum width must be a numeric value');
    assert(isscalar(alpha) && isnumeric(alpha), ...
        'Maximum width must be a numeric value');
    
    % Check wing dimensions:
    % * minimum values must be less or equal to the maximum values;
    % * minimum and maximum of one dimension can be equal iff the minimum
    %   and the maximum of the other dimension are equal (XNOR)
    assert( max_width >= min_width && max_length >= min_length && ...
            ~xor(max_width == min_width, max_length == min_length), ...
            'Wing dimensions are not consistent');

    self = struct();
    s = Shape(max_length, @(x) Width(min_length, max_length, min_width, max_width, alpha, x));

    self = class(self, 'ExponentialWing', s);
end

function w = Width( min_length, max_length, min_width, max_width, alpha, x )
%WIDTH Evaluates the width of the wing shape along
%the coordinate on the length dimension.
%
%   W = WIDTH( MIN_LENGTH, MAX_LENGTH, MIN_WIDTH, MAX_WIDTH, ALPHA, X)
%       returns the width of the wing shape with
%       minimum and maximum dimensions (MIN_LENGTH, MIN_WIDTH) and
%       (MAX_LENGTH, MAX_WIDTH), respectively, at the coordinate X along
%       the length dimension, using ALPHA as decay rate.

    if min_length == max_length
        w = max_width*ones(size(x));
    else
        normalizza = 1-exp(-alpha);
        w = max_width * double(x>=(max_length-min_length)) + ...
            (min_width + (max_width-min_width).*((1-exp(-alpha.*x./(max_length-min_length)))./normalizza)).*double(x<(max_length-min_length));
    end

end