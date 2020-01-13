function [ Rt ] = getSubsolar2(B, Bz, Vsw, costh, Np, Tp)
%getSubsolar Determine the subsolar point location
%   Determine the subsolar point location. 
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2012
% ------------------------------------------------------
%
      % Shue et al. (1997)
      K = 0.013;
      if (Bz < 0), K = 0.140;end;
      P = (2*10^(-6))*Np*Vsw^2; % Vsw=Vp supposed
      Rmp = (11.4 + K * Bz) * P^(-1/6.6);

      % Farris and Russell (1994) as
      Va =  20.3*B/sqrt(Np); % B / sqrt(4*pi * (4*Na + Np) * Mp) =
      Vs = 0.12*(Tp+1.28*10^5)^0.5; 
      Vms = sqrt(0.5*(Va^2+Vs^2+sqrt((Va^2+Vs^2)^2-4*Va^2*Vs^2*costh^2))); % cos(th)
      Mms = Vsw / Vms;
      Rt = Rmp * (1.0 + 1.1 * ((2/3)*Mms^2 + 2) / ((8/3) * (Mms^2 - 1)));   
%       if (abs(Rt)>100)
%           Mms          
%           acos(costh)/pi*180          
%       end;
end

