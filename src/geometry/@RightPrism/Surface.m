function S = Surface(self)
%SURFACE Returns the surface area of a right prism.
%
%   S = SURFACE( SELF )
%       returns the base area of a right prism having as base a generic
%       shape.

S = get(self.base, 'Surface');

end

