function [ dst ] = getDst( time )
%getDst Gives the Dst index of given day
%   Determines the Dsp index based on the year, day and month. Applicable
%   only for the year run.
%
%   Source: 
%   
%   http://wdc.kugi.kyoto-u.ac.jp/dstae/format/dstformat.html
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2013
%
% -----------------------------------------------------------------
        
    root_path='/home/gfacsko/Projects/Matlab/ECLAT/';
    dstFilename='dst_20020101_20030228.dat';
    % Number of dst lines
    N=424;
    A=zeros(N,25);
        
    % Read Dst index from file
    fid=fopen([root_path,'data/',dstFilename],'r');   
    % Reading data
    i=1;   
	strLine=fgetl(fid);
    for i=1:N
        for j=2:25
            A(i,1)=datenum([2000+str2num(strLine(4:5)) str2num(strLine(6:7)) ...
                 str2num(strLine(9:10)) 0 0 0]);        
            strDst=strLine(21+(j-2)*4:21+(j-2)*4+3);
            if (j<25),A(i,j+1)=str2num(strDst);end;
            if (j==25 && i<N),A(i+1,2)=str2num(strDst);end;
        end;
        i=i+1;           
	    strLine=fgetl(fid);
    end;  
    fclose(fid);

    % Select day
    [amin,iamin]=min(abs(A(:,1)-floor(time)));
    % Select hour and Dst index
    dst=A(iamin,str2num(datestr(time,'HH'))+2);   
end

