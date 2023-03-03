function V = Volume(self)
%VOLUME Evaluates the volume of a rigth prism.
%
%   V = VOLUME(SELF) 
%       returns the volume of a right prism with base area B and height h,
%       evaluated as:
%           V = B*h
%
% References:
% [1] Wikipedia, The free Encyclopedia (Accessed 2018, June). Prism.
%     URL: https://en.wikipedia.org/wiki/Prism_(geometry)#Volume

h = self.height;

V = get(self.base, 'Surface')*h;

end