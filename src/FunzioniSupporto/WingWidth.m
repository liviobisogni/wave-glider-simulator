function w = WingWidth( wing, x )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if wing.min_length == wing.max_length
    w = wing.max_width*ones(size(x));
else
    w = wing.max_width * double(x>=(wing.max_length-wing.min_length)) + ...
            (wing.min_width + x*(wing.max_width-wing.min_width)/(wing.max_length-wing.min_length)).*double(x<(wing.max_length-wing.min_length));
end

end

