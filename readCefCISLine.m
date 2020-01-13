function [ strLine ] = readCefCISLine(fid,strLine)
%readCefCISLine Read CIS or RAPID multiple cef files
%   This function reads the multiple line records of cef files of 
%   CIS and RAPID instruments.
%
%   fid    : file stream
%   strLine: previous line
%
%   Developed by Gabor FACSKO, Finnish Meteorological Institute
%                
% -----------------------------------------------------------------
%             
        % Read until the timestamp
        while (numel(strfind(strLine,'Z'))==0 && numel(strfind(strLine,'!RECORDS='))==0)
            strLine = fgetl(fid);
        end;
        % Read until the end of the record
        while (numel(strfind(strLine,';'))==0 && numel(strfind(strLine,'$'))==0 && numel(strfind(strLine,'!RECORDS='))==0)
	    strLine=[strLine,fgetl(fid)];
        end;
        % Modifcation for RAPID by Gabor Facsko, 2011084
        strLine=strrep(strLine,' ','');
end

