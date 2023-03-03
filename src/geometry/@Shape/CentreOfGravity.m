function COG = CentreOfGravity( self )
%CENTREOFGRAVITY Evaluates the coordinate of the centre of gravity in the
% direction of the length for a generic planar figure
%
%   COG = CENTREOFGRAVITY(SELF)
%       returns the coordinate of the centre of gravity in the direction of
%       the length for a right prism having as base a generic shape with
%       length l and width w(l).

l = self.length;
w = self.width;

if isnumeric(w) % Shape is a rectangle
    COG = l/2;
else
    COG = integral(@(x) x*w(x), 0, l, 'ArrayValued', true)/get(self, 'Surface');
end

end

