function h = height( seaWave, x, t )
%HEIGHT Elevation of a planar wave with respect to the sea surface.
%
%   H = HEIGHT( SEAWAVE, X, T )
%       returns the elevation of a planar wave with respect to the sea
%       surface. Considering an upward z-axis and a x-axis directed forward
%       as in [1], the wave elevation can be modelled as:
%           z(x,t)  = A*cos(k*x - w*t)
%       where A is the wave amplitude (m), w is the wave frequency (rad/s)
%       and k is the wave number. Since the z-axis in marine robotics is 
%       usually directed downward, the elevation needs a sign change. 
%       Moreover, when the wave direction is from right to left (backward x 
%       direction) also the x argument needs a sign change.
%       The wave profile hence results:
%           z(x,t)  = -A*cos(k*x + w*t)
%
% References:
% [1] Salmon, Rick (2008). Introduction to ocean waves. Scripps Institution
%     of Oceanography, University of California, San Diego. p. 8.

    signCh = 1 - 2*double(strcmp(seaWave.direction, 'left'));
    h = - seaWave.amplitude*cos(seaWave.number*x - signCh*seaWave.frequency*t);
end

