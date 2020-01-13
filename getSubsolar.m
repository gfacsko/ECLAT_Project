function [ x ] = getSubsolar(Babs, vSW, nSW ) %   % B, Vsw, th, Np, Tp
%getSubsolar Determine the subsolar point location
%   Determine the subsolar point location. 
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2012
% ------------------------------------------------------
%
    % Size
    R = 20;
    % Alfven velocity
    Ca = Babs*10.0^(-9)/sqrt(4.0*pi*10.0^(-7)*nSW*1.67*10.0^(-27))/1000.0;
    % Mach-Alfven number
    MA = vSW/Ca; 
    
    % Peredo modell.
    a1 = 0.0117-5.18*0.001*MA-3.47*0.0001*MA^2;
    a3 = 0.712+0.044*MA-1.35*0.001*MA^2;
    a4 = 0.3-0.071*MA+3.53*0.001*MA^2;
    a7 = 62.8-2.05*MA+0.079*MA^2;
    a8 = -4.85+1.02*MA-0.048*MA^2;
    a10 = -911.39+23.4*MA-0.86*MA^2;

    % Bow shock location
    xx = (1:1000).*R/1000;
    B = a4*xx+a8;
    C = a1*xx.^2+a7*xx+a10;
    D = B.^2-4*C;
    xx = xx(find(D>0));
    D = D(find(D>0));
    B = B(find(D>0));
    D=sqrt(D);
    %OPLOT, xx, (-B-D)/2, THICK=cSize
    %OPLOT, xx, (-B+D)/2, THICK=cSize
    %OPLOT, [MAX(xx), MAX(xx)], [MAX(-B-D), MIN(-B+D)]/2, THICK=cSize
    y1=(-B-D)/2;
    y2=(-B+D)/2;
    [m1,i1]=max(y1);
    [m2,i2]=min(y2); 
    x=xx(i1);
    
%       % Farris and Russell (1994) as
%       Va =  20.3 * B / sqrt (Np); % B / sqrt(4*pi * (4*Na + Np) * Mp) =
%       Vs = 0.12 * (Tp + 1.28*10^5)^0.5; 
%       Vms = sqrt(0.5 * (Va^2 + Vs^2 + sqrt((Va^2 + Vs^2)^2 - 4*(Va^2*Vs^2 * (cos(th))^2)));
%       Mms = Vsw / Vms;
%       Rt = Rmp * (1.0 + 1.1 * ((2/3)*Mms^2 + 2) / ((8/3) * (Mms^2 - 1));    
end

