function  v_wave = velocity( seaWave, x, z, t )
%VELOCITY Velocity of a planar sea-wave.
%
%   V_WAVE = VELOCITY( SEAWAVE, X, Z, T )
%       returns the velocity components of a planar sea-wave along the x
%       and z axes, evaluated as the directional derivative of the wave 
%       velocity field along the corresponding axis [1]:
%           v_x = A*w*e^(-k*z)*cos(k*x - w*t)
%           v_z = A*w*e^(-k*z)*sin(k*x - w*t)
%       where A is the wave amplitude (m), w is the wave frequency (rad/s)
%       and k is the wave number.
%
% References:
% [1] Salmon, Rick (2008). Introduction to ocean waves. Scripps Institution
%     of Oceanography, University of California, San Diego. p. 8.

    if ~isrow(x)
        x = x';
    end
    if ~isrow(z)
        z = z';
    end

    A = seaWave.amplitude;
    w = seaWave.frequency;
    k = seaWave.number;

    signCh = 1 - 2*double(strcmp(seaWave.direction, 'left'));
    v_wave = [ signCh*A*w*exp(-k*z).*cos(k*x - signCh*w*t); ...
              -signCh*A*w*exp(-k*z).*sin(k*x - signCh*w*t)  ];

end

