function Ma = AddedMass(self, rho)
%ADDEDMASS Evaluates the added mass matrix of a prolate ellipsoid-shaped 
% body.
%
%   MA = ADDEDMASS( SELF, RHO )
%       returns the added mass matrix for a prolate ellipsoid-shaped body
%       with semi-axes long a and c, moving in a fluid with density RHO.
%
% References:
% [1] Imlay, Frederick H. (1961). The complete expressions for added mass 
%     of a rigid body moving in an ideal fluid. No. DTMB-1528. 
%     David Taylor Model Basin Washington DC.

% Dimensions
dim = get(self.base, 'Dimensions');
a = self.height/2;
c = dim.length/2;
ecc = 1-a^2/c^2;

% Mass of the volume of the fluid displaced
m = rho*Volume(self);

% Constants that define the relative proportions of a prolate spheroid
alpha0 = (2*(1-ecc^2))/(ecc^3)*(1/2*log((1+ecc)/(1-ecc))-ecc);
beta0 = (1/(ecc^2)) - (1-ecc^2)/(2*ecc^3)*log((1+ecc)/(1-ecc));

% Added mass
Xu_d = -m*alpha0/(2-alpha0);
Yv_d = -m*beta0/(2-beta0);
Zw_d = Yv_d;
Kp_d = 0;
Nr_d = -m*(a^2-c^2)^2*(alpha0-beta0)/(2*(a^2-c^2)+(a^2+c^2)*(beta0-alpha0));
Mq_d = Nr_d;

Ma = - diag([Xu_d, Yv_d, Zw_d, Kp_d, Mq_d, Nr_d]);
end

