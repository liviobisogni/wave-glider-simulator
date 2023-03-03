function D = Dimensions( self )
%DIMENSIONS Returns the dimensions of a prolate ellipsoid
%
%   D = DIMENSIONS( SELF )
%       returns the dimensions of a prolate ellipsoid as a struct
%       containing the following fields:
%       * major_axis: the major axis (2*c)
%       * minor_axis: the minor axis (2*a)

D.major_axis = self.major_axis;
D.minor_axis = self.minor_axis;

end

