function [ tiltangle ] = getTilt(tStart,tEnd)
%getTilt Calculate averadge tilt angle
%   Calculate avarage tilt along orbit or between the two given time
%
%   tiltangle  : averadge tiltangle
%   tStart     : first data
%   tEnd       : last data
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
%         tilt_angle_degree=tilt_angle/pi*180;

        i=i+1;
        t=t+step;
    end;
    tiltangle=sum(tiltArray)/Ntilt;
end