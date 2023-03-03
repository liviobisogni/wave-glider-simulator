function SW = SeaWave(A, f, varargin)
%SEAWAVE Planar sea wave
%
%   SW = SEAWAVE(A, F, G, Property, Value, ...)
%       returns an object describing a planar sea-wave with amplitude A and
%       frequency F. The wave is also charachterised by the wave number,
%       defined as:
%           k = (2*pi*F)^2 / G,
%       where G is the gravity.
%       
%   PROPERTIES:
%       Direction       - 'rigth' (default) | 'left'. Direction towards
%                         which the sea-wave flows: For instance, right
%                         means that the wave is flowing left to right.

    % Support the zero input argument case for use within parfor loops
    if nargin == 0
       A = 1;
       f = 1;
    end

    % Parse optional arguments
    p = inputParser;
%     addOptional (p, 'seabeddepth', Inf, @(x) isscalar(x) && x > 0);
    addParameter(p, 'direction', 'right', @(x) any(validatestring(x,{'left', 'right'})));
    addParameter(p, 'gravity', 9.81, @isscalar);
    parse(p,varargin{:});
    
    SW = p.Results;
    SW.amplitude = A;                           % [m]
    SW.frequency = 2*pi*f;                      % [rad/s]
    SW.number    = SW.frequency^2/SW.gravity;   % Wave number [m^-1]

    SW = class(SW, 'SeaWave');
end