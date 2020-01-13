function [ pos ] = readCefPos(rootPath,posPath,posFilename,Tstart,Tend)
%readCefPos Read AUX position cef files
%   This function reads cef files of FGM instrument
%
%   pos        : data struct
%   rootPath   : data directory path
%   posPath    : AUX data files path
%   posFilename: AUX data filename 
%   Tstart     : first data
%   Tend       : last data
%
%   Developed by Gabor FACSKO, Finnish Meteorological Institute
%                
% -----------------------------------------------------------------
%             
    % Preparing to read
%	addpath([rootPath,posPath]);   
    % Counting the number of lines ----------------------------
    fid = fopen ([rootPath,posPath,posFilename], 'r');
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
        str2num(strLine(12:13)),str2num(strLine(15:16)),str2num(strLine(18:19)));
           if (t>=Tstart && t<=Tend)  
               lineN=lineN+1;
           end;
        strLine=fgetl(fid);          
    end;
    fclose (fid);
    % Accelerate reading
%    lineN=1500;
    % Reading -------------------------------------------------
	fid = fopen ([rootPath,posPath,posFilename], 'r');
	% Skiping header
	strLine = fgetl(fid);
        while (numel(strfind(strLine,'DATA_UNTIL'))==0)
	    strLine = fgetl(fid);
	end;
    % Reading data
    i=1;
    posT=(1:lineN);
    posX=(1:lineN);
    posY=(1:lineN);
    posZ=(1:lineN);
	strLine=fgetl(fid);
	while (numel(strfind(strLine,'!RECORDS='))==0)
	    t=datenum(str2num(strLine(1:4)),str2num(strLine(6:7)),str2num(strLine(9:10)),...
		str2num(strLine(12:13)),str2num(strLine(15:16)),str2num(strLine(18:19)));
            if (t>=Tstart && t<=Tend)
	        posT(i)=t;
		indexLine=findstr(strLine,',');
                posX(i)=str2num(strLine(indexLine(1)+1:indexLine(2)-1));
                posY(i)=str2num(strLine(indexLine(2)+1:indexLine(3)-1));
                posZ(i)=str2num(strLine(indexLine(3)+1:indexLine(4)-1));
		i=i+1;
            end;
	    strLine=fgetl(fid);
	end;
	fclose(fid);
    posT=posT(1:i-1);
    posX=posX(1:i-1);
    posY=posY(1:i-1);
    posZ=posZ(1:i-1);
 	pos = struct('time', posT, 'x', posX, 'y', posY, 'z', posZ);  
end

