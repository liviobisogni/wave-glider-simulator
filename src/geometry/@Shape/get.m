function value = get(self, property)
%GET Summary of this function goes here
%   Detailed explanation goes here

    assert(nargin >= 1, 'Not enough input arguments.')
    assert(nargin <= 2, 'Too many input arguments.')

    if (nargin == 1)
        value = self;
    else
        if ~ischar(property)
            error ('@Shape/get: PROPERTY must be a string');
        end

        switch (lower(property))
            case 'dimensions'                   % [m]
                value.length = self.length;
                value.width  = self.width;
            case 'surface'                      % [m^2]
                if isnumeric(self.width)    % Shape is a rectangle
                    value = self.length*self.width;
                else
                    value = integral(self.width, 0, self.length, ...
                        'ArrayValued', true, 'AbsTol', 1e-12);
                end
            case {'cog', 'centreofgravity'}     % [m]
                if isnumeric(self.width)    % Shape is a rectangle
                    value = self.length/2;
                else
                    value = integral(@(x) x*self.width(x), 0, self.length, ...
                        'ArrayValued', true)/get(self, 'Surface');
                end
            case 'referencedragarea'
                if isnumeric(self.width)    % Shape is a rectangle
                    value = get(self, 'Surface');
                else
                    value = @(x) self.length*self.width(x);
                end
            otherwise
                error ('@Shape/get: invalid PROPERTY "%s"', property);
        end
    end
end

