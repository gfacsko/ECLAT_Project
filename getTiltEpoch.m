function [ tiltepoch ] = getTiltEpoch(tStart,tEnd,tiltangle)
%getTiltEpoch Calculate tilt epoch
%   Calculate avarage tiltepoch from tilt angle
%
%   tiltangle  : averadge tiltangle
%   tStart     : first data
%   tEnd       : last data
%   tiltepoch  : calculated tiltepoch
%
%   Developed by Gabor FACSKO, Finnish Meteorological Institute, 2012
%                
% -----------------------------------------------------------------
%           
    global GEOPACK1
    
    Ntilt=round(abs(tEnd-tStart)*24*12);
    tiltArray=(1:Ntilt);
    
    i=1;
    t=tStart;       
    step=abs(tEnd-tStart)/Ntilt;   
    while (t<tEnd)        
        tStr=datestr(t,'yyyymmdd-hh:MM:ss');
        GEOPACK_RECALC(str2num(tStr(1:4)), date2doy(t),...
            str2num(tStr(10:11)), str2num(tStr(13:14)), 0); 
        tiltArray(i) = GEOPACK1.PSI;            
 
        i=i+1;
        t=t+step;
    end;
    
    [vmin,imin]=min(abs(tiltArray-tiltangle));
    strMin=datestr(tStart+(imin-1)*step,'yyyymmdd-hh:MM:ss');    
    tiltepoch=[strMin(1:8),strMin(10:11),strMin(13:14)];
end