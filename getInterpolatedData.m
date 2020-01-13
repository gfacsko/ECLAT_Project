function [ array ] = getInterpolatedData( array )
%getInterpolatedData Interpolates data to 1 min resolution
%   
%   array : the data
%
%   Developed by Gabor Facsko (facsko.gabor@mta.csfk.hu), 2014-2017
%   Geodetic and Geophysical Institute, RCAES, Sopron, Hungary
%----------------------------------------------------------------------
%   
    % Interpolation
    m=0;
    for i=1:numel(array)           
        % IMF
        if (array(i)~=0 && m>0)
            if (i>m+1)
                for k=1:m      
                    array(i-m-1+k)=array(i-m-1)+k/(m+1)*...
                        (array(i)-array(i-m-1));
                end;
            else
                for k=1:m                     
                    array(i-m-1+k)=array(i);
                end;
            end;
            m=0;
        end;
        if (array(i)==0)
            m=m+1;            
        end; 
    end;
    
    % Datagaps at the end
    if (array(i)==0)
        for k=1:m      
            array(i-m+k)=array(i-m);
        end; 
    end;
end

