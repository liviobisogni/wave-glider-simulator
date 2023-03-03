%The author of this code is Kevin J. Delaney
%(https://it.mathworks.com/matlabcentral/answers/375627-how-can-i-control-the-stacking-order-of-objects-in-appdesigner)

% Call this function in the startupFcn function of the App Designer

function move_to_bottom(uifigure, uiobject)
%move_to_bottom Moves the desired object to the bottom of the stack.
%   For use with appdesigner objects where uistack no longer works.

    if ~exist('uifigure', 'var')
        help(mfilename);
        return
    end
    
    if isempty(uifigure) || ~ishandle(uifigure)
        return
    end
    
    if ~exist('uiobject', 'var') || isempty(uiobject)
        return
    end
    
    all_handles = uifigure.Children;
    
    if (numel(all_handles) < 2)
        return
    end
    
    all_indices = (1:numel(all_handles))';
    
    for index = 1:numel(uiobject)
        if ishandle(uiobject(index))
            this_index = find(all_handles == uiobject(index));

            if ~isempty(this_index)
                rest_of_indices = setdiff(all_indices, this_index);
                all_handles = all_handles([rest_of_indices; this_index]);
            end
        end
    end
    
    uifigure.Children = all_handles;
end