function [ geoArray ] = readTsyFootprint( )
%readFootprints Read the saved footprint file(s) and give the Tsyganenko 
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
    fpFilename=[root_path,'data/c3_full_ts05.dat'];
    Bfp=load(fpFilename);
    for ifp=1:numel(Bfp(:,1))
        Bfp(ifp,1)=datenum([Bfp(ifp,1) 0 Bfp(ifp,2) Bfp(ifp,3) Bfp(ifp,4) 0]);
    end;
                         
    % Create result
    geoArray=[Bfp(:,1),Bfp(:,11),Bfp(:,5:10)];
end

