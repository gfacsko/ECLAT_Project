function [ fgm ] = readCefFGM(rootPath,fgmPath,fgmFilename,Tstart,Tend)
%readCefFGM Read FGM cef files
%   This function reads cef files of FGM instrument
%
%   fgm     : data struct
%   rootPath: data directory path
%   fgmPath : FGM data files path
%   fgmFilename: data filename 
%   Tstart  : first data
%   Tend    : last data
%
%   Developed by Gabor FACSKO, Finnish Meteorological Institute
%                
% -----------------------------------------------------------------
%             
    % Preparing to read
	addpath([rootPath,fgmPath]);   
    % Counting the number of lines ----------------------------
	fid = fopen ([rootPath,fgmPath,fgmFilename], 'r');
    % Skiping header
	strLine = fgetl(fid);
        while (numel(strfind(strLine,'DATA_UNTIL'))==0)
	    strLine = fgetl(fid);
	end;
    % Counting lines of data
    lineN=0;
	strLine=fgetl(fid);
	while (numel(strfind(strLine,'!RECORDS='))==0)	 
	    t=datenum(str2num(strLine(1:4)),str2num(strLine(6:7)),str2num(strLine(9:10)),...
		str2num(strLine(12:13)),str2num(strLine(15:16)),str2num(strLine(18:23)));
       if (t>=Tstart && t<=Tend)  
           lineN=lineN+1;
       end;
	    strLine=fgetl(fid);          
	end;
	fclose (fid);
%     % Accelerate read
%     lineN=21600;
    % Reading -------------------------------------------------
	fid = fopen ([rootPath,fgmPath,fgmFilename], 'r');
	% Skiping header
	strLine = fgetl(fid);
        while (numel(strfind(strLine,'DATA_UNTIL'))==0)
	    strLine = fgetl(fid);
	end;
    % Reading data
    i=1;
    fgmT=(1:lineN);
    fgmB=(1:lineN);
	fgmBx=(1:lineN);
	fgmBy=(1:lineN);
	fgmBz=(1:lineN);
	strLine=fgetl(fid);
	while (numel(strfind(strLine,'!RECORDS='))==0)
	    t=datenum(str2num(strLine(1:4)),str2num(strLine(6:7)),str2num(strLine(9:10)),...
		str2num(strLine(12:13)),str2num(strLine(15:16)),str2num(strLine(18:23)));
        if (t>=Tstart && t<=Tend)
	        fgmT(i)=t;
            indexLine=findstr(strLine,',');
            fgmBx(i)=str2num(strLine(indexLine(2)+1:indexLine(3)-1));
            fgmBy(i)=str2num(strLine(indexLine(3)+1:indexLine(4)-1));
            fgmBz(i)=str2num(strLine(indexLine(4)+1:indexLine(5)-1));
            fgmB(i)=str2num(strLine(indexLine(5)+1:indexLine(6)-1));
            i=i+1;
            end;
	    strLine=fgetl(fid);
	end;
	fclose (fid);
    fgmT=fgmT(1:i-1);
    fgmB=fgmB(1:i-1);
    fgmBx=fgmBx(1:i-1);
    fgmBy=fgmBy(1:i-1);
    fgmBz=fgmBz(1:i-1);
 	fgm = struct ('time', fgmT, 'bx', fgmBx, 'by', fgmBy, 'bz', fgmBz, 'b', fgmB);  
end

