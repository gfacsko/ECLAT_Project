function [ error ] = mkConfigFile(configFilename,inputFilename,constBx0,swEpoch,tiltepoch, nsave, tmax )
%createConfigFile Save config file
%   Write a config file for gumics run. 
%
%   configFilename     : Name for the save file
%   inputFilename      : Solar wind file
%   constBx0           : Average Bx
%   swEpoch            : mstate filenames start from here
%   tiltepoch          : Tilt angle/epoch
%   nsave              : Save frequency in seconds
%   tmax               : Run time in seconds
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2012
% ------------------------------------------------------
%

    fid=fopen(configFilename, 'w');    
        
    fprintf(fid,'# -Input parameters for GUMICS\n');
    fprintf(fid,'# (1) Solar wind parameters\n');
    fprintf(fid,'# -------------------------\n');
    fprintf(fid,'SWfile = %s\n',inputFilename);
    fprintf(fid,'constBx0 = %e\n',constBx0*10^-9);
    fprintf(fid,'#constBy0 = 0\n');
    fprintf(fid,'#constBz0 = 0\n');
    fprintf(fid,'\n');
    fprintf(fid,'# (2) Ionospheric parameters\n');
    fprintf(fid,'# --------------------------\n');
    fprintf(fid,'# iono_n: Call ionosphere every iono_n th timeleap\n');
    fprintf(fid,'iono_n = 4\n');
    fprintf(fid,'ionospheric_plasma_source = true\n');
    fprintf(fid,'\n');
    fprintf(fid,'# (3) Simulation box and grid size\n');
    fprintf(fid,'# --------------------------------\n');
    fprintf(fid,'# xmax-xmin=256, yzmax=64, ny=nz=16+2, nx=32+2. With these settings, the basegrid\n');
    fprintf(fid,'# size is 8 R_E. Notice that nx also contains the ghost cells, thus it must be +2 larger\n');
    fprintf(fid,'# than what the interior of the simulation box needs. Thus, adaptation level 3 yields to\n');
    fprintf(fid,'# the smallest grid spacing of being (0.5^3)*8 R_E = 1 R_E. Adaptation level 6 yields\n');
    fprintf(fid,'# the smallest grid spacing to be (0.5^6)*8 R_E = 0.125 R_E.\n');
    fprintf(fid,'xmin = -224\n');
    fprintf(fid,'xmax = 32\n');
    fprintf(fid,'yzmax = 64\n');
    fprintf(fid,'nx = 34\n');
    fprintf(fid,'ny = 18\n');
    fprintf(fid,'nz = 18\n');
    fprintf(fid,'# Adaptation depth (use at least 3 or 4 for product runs)\n');
    fprintf(fid,'adapt = 5\n');
    fprintf(fid,'# alpha0: threshold for cell refinement (make it smaller ==> refines more)\n');
    fprintf(fid,'alpha0 = 0.2\n');
    fprintf(fid,'# Maximum number of grid points. This should be roughly 2 times larger than the wanted, "optimal"\n');
    fprintf(fid,'# number of grid points.\n');
    fprintf(fid,'maxnc = 1000000\n');
    fprintf(fid,'\n');
    fprintf(fid,'# (4) Physical MHD parameters\n');
    fprintf(fid,'# ---------------------------\n');
    fprintf(fid,'# Magnitude of Earth s dipole moment (Please, put a positive number here.)\n');
    fprintf(fid,'dipmom = 8e15\n');
    fprintf(fid,'solver = hybrid\n');
    fprintf(fid,'remdiv = true\n');
    fprintf(fid,'remdiv_n = 20\n');
    fprintf(fid,'subcycl = true\n');
    fprintf(fid,'lazybc = true\n');
    fprintf(fid,'diffusion = 0.05\n');
    fprintf(fid,'# Reduced speed of light (Boris-correction)\n');
    fprintf(fid,'#lightspeed = 1e7\n');
    fprintf(fid,'# Event specification parameters\n');
    fprintf(fid,'# epoch_SWfile is yyyymmddhh[mm] of t=0 in SWfile (beginning of Apr 06 2000)\n');
    fprintf(fid,'epoch_SWfile = %s\n',swEpoch);
    fprintf(fid,'epoch_t0     = %s\n',swEpoch);
    fprintf(fid,'#recompute_B0_n = 60\n');
    fprintf(fid,'tiltepoch    = %s\n',tiltepoch);
    fprintf(fid,'\n');
    fprintf(fid,'# (5) Numerical MHD parameters\n');
    fprintf(fid,'# ----------------------------\n');
    fprintf(fid,'# tmax: Duration of run in physical seconds\n');
    fprintf(fid,'tmax = %i\n',tmax);
    fprintf(fid,'# dt: Time leap in seconds (largest allowed timestep)\n');
    fprintf(fid,'dt = 1\n');
    fprintf(fid,'# save_n: Save state after every save_n th time leap (save_n=75 and dt=4 gives 300s=5 min save interval)\n');
    fprintf(fid,'save_n = %i\n',nsave);
    fprintf(fid,'# set on parallel I/O (on T3E, ignored on other machines)\n');
    fprintf(fid,'# one has to use the script hccomb to combine the resulting files into complete *.hc files afterwards\n');
    fprintf(fid,'parallel_io = true\n');

    fclose(fid);   
end

