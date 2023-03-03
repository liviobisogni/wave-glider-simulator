function A = ReferenceDragArea( self )
%REFERENCEDRAGAREA Evaluates the reference area for the drag evaluation of
% a prolate ellipsoid-shaped body.
%
%   A = REFERENCEDRAGAREA( SELF )
%       returns the reference area for the drag evaluation of a prolate
%       ellipsoid-shaped body with principal axes long 2a and 2c.

a = self.minor_axis/2;
c = self.major_axis/2;

A = 2*a*2*c;
end

