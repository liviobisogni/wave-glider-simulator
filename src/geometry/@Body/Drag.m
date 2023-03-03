function D = Drag(self)
%DRAG Evaluates the hydrodynamic damping and drag matrices for a prolate
% ellipsoid-shaped body.
%
%   D = DRAG( SELF )
%       returns the hydrodynamic damping and drag matrices for a prolate
%       ellipsoid-shaped body with semi-axes long a and c moving in fluid
%       with density rho.
%       The damping matrix is a diagonal matrix with the damping
%       coefficients v on the main diagonal.
%       The drag matrix is evaluated based on the drag coefficients Cd:
%           D.drag = 0.5*rho*A*Cd
%       where A is the reference area, dependent on the body shape.

rho = self.options.waterdensity;
v   = self.options.damping;
Cd  = self.options.drag;
A   = ReferenceDragArea(self);

assert((isnumeric(A) && (isscalar(A) || all(size(A) == size(Cd)))) || isa(A, 'function_handle'), ...
    ['Reference area must be either a scalar, a vector with the same ', ...
    'dimensions of the drag coefficients vector or a function handle']);

D.damping = diag(v);
if isnumeric(A)
    D.drag = 0.5*rho*diag(A)*diag(Cd);
else
    D.drag = @(x) 0.5*rho*A(x)*diag(Cd);
end

end