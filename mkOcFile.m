function [ error ] = mkOcFile( )
%mkOcFile Create oc files to Ilja's tracker program.
%   Read OMNIWeb data, Cluster positions and GUMICS simulation results. 
% 
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2012
%   Finnish Meteorologycal Institute, Helsinki
%----------------------------------------------------------------------
%   
    % Default directories
    root_path='/home/facsko/Projects/matlab/ECLAT/';   
    data_path='/home/facsko/QSAS/C1_CP_AUX_POSGSE_1M/';
    sim_path='/media/My\ Passport/ECLAT/dynamic_runs/orbit267-nodiv/';
    % Orbit number
    Norb=267;  
    % Start and end time
    tStart=datenum(2002,3,20,20,0,0); % datenum(2002,3,21,3,0,0); % 
    tEnd=datenum(2002,3,23,4,3,0); % datenum(2002,3,21,12,3,0);  % 

    % Read orbit data ----------------------------------------------------
    pos=readCefPos(data_path,'','C1_CP_AUX_POSGSE_1M__20020320_000000_20020324_000000_V091203.cef',tStart,tEnd);    
    
    % Create oc files ---------------------------
    [status,result]=unix(['cd ',sim_path,';ls mstate20020320_2*.hc mstate2002032[1-3]*.hc|sort']);%     
    fnStart=strfind(result,'mstate')+6;
    fnEnd=strfind(result,'.hc')-1;
    tGUMICS=(1:numel(fnStart));
    bzGUMICS=(1:numel(fnStart));
    for i=1:numel(fnStart)
         timeStr=result(fnStart(i):fnEnd(i));
         tcl=datenum([str2num(timeStr(1:4)) str2num(timeStr(5:6))...
             str2num(timeStr(7:8)) str2num(timeStr(10:11))...
             str2num(timeStr(12:13)) str2num(timeStr(14:15))]);
         tGUMICS(i)=tcl;
         [vmin,imin]=min(abs(pos.time-tcl));
         [datestr(tcl),'  ',datestr(pos.time(imin))]      
         % Create point file
         fid=fopen([root_path,'pointfiles/',result(fnStart(i)-6:fnEnd(i)),'.oc'], 'w');   
             fprintf(fid,'%i\t%10i\t%10i\n',pos.x(imin)*1000,pos.y(imin)*1000,pos.z(imin)*1000);
         fclose(fid);
%[status,result2]=unix(['export ; cd ',root_path,'pointfiles; field_tracer.py ',sim_path,result(fnStart(i)-6:fnEnd(i)+3),' -d ',root_path,'pointfiles'])
     end;
%     [status,result2]=unix(['cd ',root_path,'pointfiles; field_tracer.py ',sim_path,'mstate20020320_2*.hc -d ',root_path,'pointfiles'])
     % mstate2002032[1-3]*.hc        
end

