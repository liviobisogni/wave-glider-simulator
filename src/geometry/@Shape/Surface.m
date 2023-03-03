function S = Surface(self)
%SURFACE Returns the surface area of a generic shape.
%
%   S = SURFACE( SELF )
%       returns the base area of a generic shape with length l and width
%       w(l)

l = self.length;
w = self.width;

if isnumeric(w) % Shape is a rectangle
    S = l*w;
else
    S = integral(w, 0, l, 'ArrayValued', true, 'AbsTol', 1e-12);
end
end

