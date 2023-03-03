function A = ReferenceDragArea( self )
%REFERENCEDRAGAREA Evaluates the reference area for the drag evaluation of
% a prolate ellipsoid-shaped body.
%
%   A = REFERENCEDRAGAREA( SELF )
%       returns the reference area for the drag evaluation of a right prism
%       having as base a generic shape.

A = get(self.base, 'ReferenceDragArea');
end

