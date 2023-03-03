function I = GeometricInertia(self)
%GEOMETRICINERTIA Evaluates the inertia matrix of a prolate ellipsoid-shaped 
% body.
%
%   I = GEOMETRICINERTIA( SELF )
%       returns the geometric moment of inertia matrix of a right prism
%       having as base a generic shape.

dim = get(self.base, 'Dimensions');

l = dim.length;
if isnumeric(dim.width)
    w = dim.width;
else
    w = dim.width(fminbnd(@(x) -dim.width(x),0,dim.length));
end
h = self.height;

Ixx = (w^2+h^2)/12;
Iyy = (l^2+h^2)/12;
Izz = (l^2+w^2)/12;

I = diag([Ixx Iyy Izz]);
end