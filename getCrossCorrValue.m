function [ cc ] = getCrossCorrValue( f, g, limit, dt)
%getCrossCorr Calculate the correlation function
%   Calculate the correlation of two functions within certain interval
%   using approriate steps.
%   
%   f, g  : Functions
%   limit : Interval
%   dt    : Step size
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2013
%   Finnish Meteorological Institute, Helsinki
%----------------------------------------------------------------------
%   
    aa=0.0;
    bb=0.0;
    cc=0.0;
    t=limit+1;    
    while (t<min([numel(f),numel(g)])-limit)
        aa=aa+(f(t))^2;
        bb=bb+(g(t-dt))^2;
        cc=cc+f(t)*g(t-dt);
        t=t+1;        
    end;
    cc=cc/sqrt(aa*bb);
end

