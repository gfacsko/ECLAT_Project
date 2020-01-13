function [ C, X, Y ] = getMatrix( An )
%getMatrix Converts array to matrix for contour plot
%   The contour plot needs matrix. The script go through the array after 
%   its coordinate transformation and selects the values at the appropriate
%   location. 
%
%   An : Array
%   X,Y: coordinates
%   C  : matrix
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2012
%
% ------------------------------------------------------------------------
%  
    % Array->matrix   
    step=pi/180;
    X=(-pi/6:step:pi/6);
    Y=(-pi/6:step:pi/6);
    C=zeros(length(X),length(Y));
    for i=1:length(X)
        for j=1:length(Y)
            v=0;
            nv=0;
            for k=1:length(An)
                if (abs(An(k,1)-X(i))<step/2 && abs(An(k,2)-Y(j))<step/2)
                    v=v+An(k,3);
                    nv=nv+1;
                end;
            end;
            if (nv>0),C(i,j)=v/nv;end;
        end;
    end;   
end

