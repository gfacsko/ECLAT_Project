function [ dataGap ] = getDataGap(time,dT)
%getDataGap Determine datagaps
%   This function determines datagaps and save their start and end
%   time in an array. 
%
%   dataGap   : the result array
%   dT        : definition of datagap (s)
%
%   Developed by Gabor FACSKO, Finnish Meteorological Institute, 2011
%                
% -----------------------------------------------------------------
%    
    dataGap=[];
    for i=2:numel(time)
        % Identification of datagaps
        if (86400*(time(i)-time(i-1))>dT)
            dataGap=[dataGap,(i-1),i];
        end;
    end;
end

