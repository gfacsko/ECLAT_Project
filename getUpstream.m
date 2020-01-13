function [ rho,n,T,V,B ] = getUpstream( mstateFilename )
%getUpstream Read upstream conditions from mstate file
%   Read upstream conditions from mstate file: n, rho, T, Bx, By, Bz, Vx,
%   Vy, Vz. It converts GSE input to GSM. 
%
%   mstateFilename: magnetospheric filename
%   n             : particle density
%   rho           : density
%   T             : temperature
%   B             : magnetic field vector
%   V             : solar wind velocity vector
%
% -----------------------------------------------------------------
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2013
%
% -----------------------------------------------------------------
%

    % Data path
%    sim_path='/home/facsko/stornext/';    
    sim_path='/media/My\ Book/ECLAT/dynamic\ runs/';   
    root_path='/home/gfacsko/Projects/Matlab/ECLAT/';
    
    % GLIBCXX problem
    MatlabPath = getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH',getenv('PATH'));
    [status,result]=unix(['/home/gfacsko/gumics/bin/hcintpol -n -v rho,n,vx,vy,vz,T,Bx,By,Bz ',...
        sim_path,mstateFilename,' < ',...
        root_path,'pointfiles/upstreamPointfile-ECLAT-1RE.dat',' > ',...
        root_path,'data/upstreamDump-',mstateFilename(54:68),'.dat']); 
%        root_path,'data/upstreamDump-',mstateFilename(60:74),'.dat']);  
    % GLIBCXX problem
    setenv('LD_LIBRARY_PATH',MatlabPath);

    % Load yz file
    N=16641; 
    U=zeros(N,12);  
    upstreamDumpFilename=[root_path,'data/upstreamDump-',...
        mstateFilename(54:68),'.dat'];
%        mstateFilename(60:74),'.dat'];
    U=load(upstreamDumpFilename);
     
    % Average
    rho=sum(U(:,4))/N;
    n=sum(U(:,5))/N;
    V=[sum(U(:,6)),sum(U(:,7)),sum(U(:,8))]/N;
    % GSE to GSM conversion
    [vxGSM,vyGSM,vzGSM]=GEOPACK_GSMGSE(V(1),V(2),V(3),-1);
    V=[vxGSM,vyGSM,vzGSM];
    T=sum(U(:,9))/N;
    B=[sum(U(:,10)),sum(U(:,11)),sum(U(:,12))]/N;
    [bxGSM,byGSM,bzGSM]=GEOPACK_GSMGSE(B(1),B(2),B(3),-1);
    B=[bxGSM,byGSM,bzGSM];
    
    % Delete temporary file
    [status,result]=unix(['rm ',upstreamDumpFilename]);
end

