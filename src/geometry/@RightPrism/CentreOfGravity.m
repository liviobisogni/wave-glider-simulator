function cog = CentreOfGravity( self )
%CENTREOFGRAVITY Evaluates the coordinate of the centre of gravity in the
% direction of the length for a right prism having as base a generic shape.
%
%   COG = CENTREOFGRAVITY(SELF)
%       returns the coordinate of the centre of gravity in the direction of
%       the length for a right prism having as base a generic shape.

cog = get(self.base, 'COG');

end

