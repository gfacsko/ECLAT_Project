function [ maxtime, maxvalue, pcc ]=getCrossCorr(f,g,limit,isOMNI)
%mkCrossCorr Calculate the cross correlation 
%   Calculate the cross correlation of two functions and save the results
%   and correlation functions in a file. 
%
%   f, g  : Functions
%   limit : Interval
%   cf    : Correlation function
%   isOMNI: OMNIWeb or GUMICS vs Cluster SC3
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2013
%   Finnish Meteorological Institute, Helsinki
%----------------------------------------------------------------------
%   
    error=0;
    % Correlation calculation
    dt=(-limit);
    maxtime=0;
    maxvalue=0.0;  
%     if (isOMNI)
        ptime=zeros(1,2*limit);
        pcc=zeros(1,2*limit);    
%     else
%         ptime=zeros(1,2*limit/5);
%         pcc=zeros(1,2*limit/5); 
%     end;
    i=1;
    while (dt<=limit) 
        ptime(i)=dt;
        value=getCrossCorrValue(f,g,limit,dt);
        pcc(i)=value; 
        % Maximum with saving the time
        if (value>maxvalue)
            maxtime=dt;
            maxvalue=value;
        end;
        i=i+1;
 %       dt=dt+limit/10;
%         if (isOMNI)
            dt=dt+1;
%         else
%             dt=dt+5;
%         end;
    end;
end

