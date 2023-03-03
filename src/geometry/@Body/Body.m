function self = Body(varargin)
%BODY Implementation of a generic body
%
%   SELF = BODY(Property, Value, ...)
%       returns an object modelling a generic shape. Shape is an abstract
%       class; derived classes should implement the methods:
%       * AddedMass
%       * CentreOfGravity;
%       * Dimensions;
%       * GeometricInertia;
%       * ReferenceDragArea;
%       * Surface;
%       * Volume.

    if nargin == 0
        varargin = {'Mass', 0};
    end

    % Check the input parameters (required and optional)
    p = inputParser;
    
    addParameter(p, 'materialdensity', nan, @(x) isscalar(x) && isnumeric(x));
    addParameter(p, 'waterdensity', 1, @(x) isscalar(x) && isnumeric(x));
    addParameter(p, 'waterviscosity', 1, @(x) isscalar(x) && isnumeric(x));
    addParameter(p, 'mass', nan, @(x) isscalar(x) && isnumeric(x));
    addParameter(p, 'buoyancy', nan, @(x) isscalar(x) && isnumeric(x));
    addParameter(p, 'damping', zeros(1,3), @(x) isnumeric(x) && isvector(x) && ...
        ismember(length(x),[1 3 6]));
    addParameter(p, 'drag', zeros(1,3), @(x) isnumeric(x) && isvector(x) && ...
        ismember(length(x),[1 3 6]));
    addParameter(p, 'jointposition', nan, @(x) isscalar(x) && isnumeric(x));
    addParameter(p, 'mounting', nan, @(x) isscalar(x) && isnumeric(x));
    
    % Parse the parameters
    parse(p, varargin{:});
    assert(~isnan(p.Results.mass) || ~isnan(p.Results.materialdensity), ...
        'Mass undefined. Specify either the mass or the density of the material')
    self.options = p.Results;

    self = class(self, 'Body');
end