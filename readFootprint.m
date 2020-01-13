function [ smArray ] = readFootprint( dateStr )
%readFootprints Read the saved footprint file(s) and give the GUMICS 
% footprint if there is any. 
%   
% Developed by Gabor Facsko (gabor.facsko@fmi.fi)
% Finnish Meteorological Institute, 2013
%
% -----------------------------------------------------------------
%    
    % Paths
    root_path='/home/facsko/Projects/matlab/ECLAT/';
        
    % Read GUMICS footprint file   
    fpFilename=[root_path,'products/footprints/footprint-',dateStr,'.dat'];
    Bfp=load(fpFilename);
    % Time :(
    fid=fopen (fpFilename, 'r');    
    i=1;
    while (~feof(fid))        
        strLine=fgetl(fid);
        t=datenum(str2num(strLine(1:4)),str2num(strLine(5:6)),...
            str2num(strLine(7:8)),str2num(strLine(10:11)),...
            str2num(strLine(13:14)),str2num(strLine(16:21)));       
        Bfp(i,1)=t;               
        i=i+1;
    end;
    fclose(fid);
           
    % Filter - valid results
    Bfp=Bfp(find(Bfp(:,13)),:);
                
    % Create result
    smArray=[Bfp(:,1),Bfp(:,13),Bfp(:,20:25)];
end

