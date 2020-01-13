function [ posArray ] = getClusterPosition(posFilename,tStart,tEnd)
%getClusterPosition Read AUX position of cdf files
%   This function reads AUX cdf files and gives the location of the 
%   Cluster SC1. 
%   posFilename: AUX data filename 
%   tStart     : first data
%
%   Developed by Gabor FACSKO, Finnish Meteorological Institute
%                
% -----------------------------------------------------------------
%             
    sc=posFilename(40);
    % Earth radii
    RE=6380; 
    % Read positions
    t = [];   
    r = [];
    % Reading AUX data
    posCell = cdfread(posFilename,'Variable',...
        {['time_tags__C',sc,'_CP_AUX_POSGSE_1M'],...
        ['sc_r_xyz_gse__C',sc,'_CP_AUX_POSGSE_1M']},...
        'ConvertEpochToDatenum',true);
    % Converting cells to double --- AUX
    pos = cell2struct(posCell,{'time','r'},2); 
    t = [t,pos.time];  
    [tmin,timin]=min(abs(t-tStart));
    [tmax,timax]=min(abs(t-tEnd)); 
    posArray=zeros(timax-timin,4);
    for ia=timin:timax
        posArray(ia,1)=t(ia);
        r=pos(ia).r;
        posArray(ia,2)=r(1);
        posArray(ia,3)=r(2);
        posArray(ia,4)=r(3);
    end;
end
