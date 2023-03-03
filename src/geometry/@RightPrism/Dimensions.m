function D = Dimensions( self )
%DIMENSIONS Returns the dimensions of a right prism
%
%   D = DIMENSIONS( SELF )
%       returns the dimensions of a right prism as a struct containing as
%       fields the dimensions of the base and the height h.

D = get(self.base, 'Dimensions');
D.height = self.height;

end

