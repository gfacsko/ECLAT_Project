function [ cis ] = readCefCIS(rootPath,cisPath,cisFilename,Tstart,Tend)
%readCefCIS Read CIS cef files
%   This function reads cef files of FGM instrument
%
%   cis     : data struct
%   rootPath: data directory path
%   cisPath : CIS data files path
%   cisFilename: data filename 
%   Tstart  : first data
%   Tend    : last data
%
%   Developed by Gabor FACSKO, Finnish Meteorological Institute
%                
% -----------------------------------------------------------------
%             
    % Preparing to read
	addpath([rootPath,cisPath]);   
    % Counting the number of lines ----------------------------
	fid=fopen ([rootPath,cisPath,cisFilename], 'r');
    % Skiping header
	strLine = fgetl(fid);
       while (numel(strfind(strLine,'DATA_UNTIL'))==0)
	    strLine = fgetl(fid);
	end;
   % Counting lines of data
   lineN=0;
   strLine=readCefCISLine(fid,strLine);
	while (numel(strfind(strLine,'!RECORDS='))==0)	 
	    t=datenum(str2num(strLine(1:4)),str2num(strLine(6:7)),...
		str2num(strLine(9:10)),str2num(strLine(12:13)),...
               str2num(strLine(15:16)),str2num(strLine(18:23)));
           if (t>=Tstart && t<=Tend)  
               lineN=lineN+1;
           end;
	    strLine = readCefCISLine(fid,strLine);
	    strLine = fgetl(fid);
        end;
	fclose (fid);
    % Accelerate reading --------------------------------------
%         lineN=21600;
    % Reading -------------------------------------------------
	fid=fopen ([rootPath,cisPath,cisFilename], 'r');
	% Skiping header
	strLine=fgetl(fid);
        while (numel(strfind(strLine,'DATA_UNTIL'))==0)
	    strLine=fgetl(fid);
	end;
    % Reading data
    i=1;
    cisT=(1:lineN);
    cisN=(1:lineN);
    cisVx=(1:lineN);
	cisVy=(1:lineN);
	cisVz=(1:lineN);
	cisV=(1:lineN);
    cisTemp=(1:lineN);
    cisP=(1:lineN);
	strLine=readCefCISLine(fid,strLine);
	while (numel(strfind(strLine,'!RECORDS='))==0)
	    t=datenum(str2num(strLine(1:4)),str2num(strLine(6:7)),str2num(strLine(9:10)),...
		str2num(strLine(12:13)),str2num(strLine(15:16)),str2num(strLine(18:23)));                       
	    strLine = readCefCISLine(fid,strLine);
	    if (t>=Tstart && t<=Tend)
	        cisT(i)=t;
		indexLine=findstr(strLine,',');
                cisN(i)=str2num(strLine(indexLine(4)+1:indexLine(5)-1));
		cisVx(i)=str2num(strLine(indexLine(8)+1:indexLine(9)-1));
		cisVy(i)=str2num(strLine(indexLine(9)+1:indexLine(10)-1));
		cisVz(i)=str2num(strLine(indexLine(10)+1:indexLine(11)-1));
                cisV(i)=sqrt(cisVx(i)^2+cisVy(i)^2+cisVz(i)^2);
                cisTemp(i)=str2num(strLine(indexLine(11)+1:indexLine(12)-1));
                cisP(i)=str2num(strLine(indexLine(13)+1:indexLine(14)-1));
		i=i+1;
            end;
	    strLine = fgetl(fid);
	end;
	fclose(fid);
    cisT=cisT(1:i-1);
    cisN=cisN(1:i-1);
    cisVx=cisVx(1:i-1);
    cisVy=cisVy(1:i-1);
    cisVz=cisVz(1:i-1);
    cisV=cisV(1:i-1);
    cisTemp=cisTemp(1:i-1);
    cisP=cisP(1:i-1);
 	cis = struct ('time',cisT,'n',cisN,'vx',cisVx,'vy',cisVy,'vz',cisVz,'v',cisV,'T',cisTemp,'p',cisP);
end