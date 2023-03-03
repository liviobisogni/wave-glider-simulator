function value = get(self, property)
%GET Summary of this function goes here
%   Detailed explanation goes here

    assert(nargin >= 1, 'Not enough input arguments.')
    assert(nargin <= 2, 'Too many input arguments.')

    if (nargin == 1)
        value = self;
    else
        if ~ischar(property)
            error ('@Body/get: PROPERTY must be a string');
        end

        switch (lower(property))
            case 'dimensions'                   % [m]
                value = Dimensions(self);
            case 'surface'                      % [m^2]
                value = Surface(self);
            case 'volume'                       % [m^3]
                value = Volume(self);
            case 'mass'                         % [kg]
                if ~isnan(self.options.mass)                                                      
                    if ~isnan(self.options.materialdensity)
                        warning(['Specified both the mass and the density of the material: ' ...
                            'the latter will be ignored'])
                    end
                    value = self.options.mass;
                else
                    value = Volume(self)*self.options.materialdensity;
                end
            case 'momentofinertia'              % [kg*m^2]
                value = get(self, 'Mass')*GeometricInertia(self);
            case 'addedmass'                    % [kg]
                value = AddedMass(self, self.options.waterdensity);
            case 'drag'                         % damping and drag
                value = Drag(self);
            case 'buoyancy'                     % [kg]
                if ~isnan(self.options.buoyancy)
                    value = self.options.buoyancy;
                else
                    value = Volume(self)*self.options.waterdensity;
                end
            case {'cog', 'centreofgravity'}     % [m]
                value = CentreOfGravity(self);
            case 'jointposition'                % [m]
                value = self.options.jointposition;
            case 'mounting'                     % [m]
                value = self.options.mounting;
            otherwise
                error ('@Body/get: invalid PROPERTY "%s"', property);
        end
    end

end

