function [ tStart,tEnd ] = getOrbitTime(posFilename,Norb)
%getOrbitTime Read AUX position cef files
%   This function reads AUX cef files and gives the begining and the end
%   of the orbit. 
%   %   rootPath   : data directory path
%   posPath    : AUX data files path
%   posFilename: AUX data filename 
%   tStart     : first data
%   tEnd       : last data
%
%   Developed by Gabor FACSKO, Finnish Meteorological Institute
%                
% -----------------------------------------------------------------
%             
    % Earth radii
    RE=6378; 
    % Read positions
    t = [];   
    norb = [];        
    % Reading AUX data
    posCell = cdfread(posFilename,'Variable',...
        {['time_tags__C1_CP_AUX_POSGSE_1M'],...
%        ['sc_r_xyz_gse__C1_CP_AUX_POSGSE_1M'],...
        ['sc_orb_num__C1_CP_AUX_POSGSE_1M']},...
        'ConvertEpochToDatenum',true);
    % Converting cells to double --- AUX
    pos = cell2struct(posCell,{'time','norb'},2); % 'r',
    t = [t,pos.time];  
    norb=[norb,pos.norb];   
    [tmin,timin]=min(abs(norb-Norb));
    [tmax,timax]=min(abs(norb-(Norb+1)));
    tStart=t(timin);
    tEnd=t(timax);
end

