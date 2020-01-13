function [ pos ] = getClusterPosition(posFilename,tPos)
%getCluster Position Read AUX position of cdf files
%   This function reads AUX cdf files and gives the location of the 
%   Cluster SC1. 
%   posFilename: AUX data filename 
%   tStart     : first data
%
%   Developed by Gabor FACSKO, Finnish Meteorological Institute
%                
% -----------------------------------------------------------------
%             
    % Earth radii
    RE=6380; 
    % Read positions
    t = [];   
    r = [];
    % Reading AUX data
    posCell = cdfread(posFilename,'Variable',...
        {['time_tags__C3_CP_AUX_POSGSE_1M'],...
        ['sc_r_xyz_gse__C3_CP_AUX_POSGSE_1M']},...
        'ConvertEpochToDatenum',true);
    % Converting cells to double --- AUX
    pos = cell2struct(posCell,{'time','r'},2); 
    t = [t,pos.time];  
    [tmin,timin]=min(abs(t-tPos));
    pos=pos(timin).r;
end
