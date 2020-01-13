function [ error ] = plotE( An, degree, hem)
%plotE Plots electric field
%   Plots horizontal ionospheric electric field calculated from electric
%   potential.
%
%   An    : Coordinated and electric potential
%   degree: Network refinetement
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2012-2013
%
% ------------------------------------------------------------------------

    error = 0;
    % Resolution
    dv=pi/180*degree;    
    %dv=pi/72;
    % Intervallum
    v=-pi/6:dv:pi/6;
    [mx,my]=meshgrid(v);
    % Defition of the new potential array
    mPhi=mx;
    % Counts the potential value in the new grid
    for ix=1:numel(v)
        for iy=1:numel(v)
            nan=0;
            tempPhi=0;            
            for ian=1:numel(An(:,1))
                if (abs(mx(ix,iy)-An(ian,2))<dv/2 &&...
                        abs(my(ix,iy)-An(ian,1))<dv/2)
                    tempPhi=tempPhi+An(ian,3);       
                    nan=nan+1;
                end;             
            end;                
            if (nan>0),mPhi(ix,iy)=tempPhi/nan;end;
            if (nan==0),mPhi(ix,iy)=0;end;
        end;
    end;    
    % Electric field vectors (-grad (Phi))   
    [dx,dy]=gradient(mPhi,dv,dv);
    % Eliminate singurality
    izero=floor(numel(v)/2)+1;   
    dx(izero-1:izero+1,izero)=0;
    dx(izero,izero-1:izero+1)=0;    
    dy(izero-1:izero+1,izero)=0;
    dy(izero,izero-1:izero+1)=0;    
    if (hem=='n'),quiver(mx,my,-2*dx,-2*dy,2,'-y');end;
    if (hem=='s'),quiver(mx,my,2*dx,2*dy,2,'-y');end;    
end