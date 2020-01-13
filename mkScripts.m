function [ error ] = mkScripts(norbArray,Nslice,nsave)
%createConfigFile Save config file
%   Write a job and a launch scripts for gumics runs. 
%
%   norbArray: Three orbit numbers
%   Nslice   : Slice number
%   nsave    : Save frequency
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2012
% ------------------------------------------------------
%
    % Path
    path='';
    % Filename
    strOrbit=[];
    for i=1:numel(norbArray)
        strOrbit=[strOrbit,'o',num2str(norbArray(i))];
    end;

    % gumics_job.sh    
    fid=fopen([path,'gumicsfiles/gumics_job-',strOrbit,'.sh'], 'w');    
        
    fprintf(fid,'#!/bin/bash -l\n');
    fprintf(fid,'## Created by Gabor Facsko (gabor.facsko@fmi.fi)\n');
    fprintf(fid,'## Finnish Meteorological Institute, 2012\n');
    fprintf(fid,'#PBS -l mppwidth=1\n');
    fprintf(fid,'#PBS -V\n');
    fprintf(fid,'#PBS -N %s\n',strOrbit);
    fprintf(fid,'#PBS -l mppnppn=1\n');
    fprintf(fid,'#PBS -l mppdepth=%i\n',numel(norbArray)*Nslice);
    fprintf(fid,'#PBS -l walltime=504:00:00\n');
    fprintf(fid,'#PBS -j oe\n');
    fprintf(fid,'#PBS -r y\n');
    fprintf(fid,'cd $PBS_O_WORKDIR\n');
    fprintf(fid,'t1=$( date +%s)\n','%s');
    fprintf(fid,'echo "##gumicsrun Job started $( date )"\n');    
    fprintf(fid,'aprun -cc numa_node -n1 -N1 -d%i ./gumics_launch-%s.sh 2>&1 > /dev/null\n',...
        numel(norbArray)*Nslice,strOrbit);
    fprintf(fid,'echo "##gumicsrun Job finished $( date )"\n');
    fprintf(fid,'t2=$( date +%s)\n','%s');
    fprintf(fid,'echo "##gumicsrun Total execution time $(( t2 - t1 )) s "  \n'); 
    
    fclose(fid);   
       
    % Input and config files
    for i=1:numel(norbArray),mkInputFile(norbArray(i),Nslice,nsave);end;
    
    % Directories
    strSample=[];
    for i=1:numel(norbArray)
        strSample=[strSample,' orbit',num2str(norbArray(i)),'*'];
    end;
    [status,strDir]=unix(['cd ',path,'gumicsfiles/; ls ',strSample,'|grep :|cut -d: -f1']);
    orbitIndex=findstr(strDir,'orbit');
    strDir2=[];    
    for i=1:numel(orbitIndex)-1
        strDir2=[strDir2,strDir(orbitIndex(i):orbitIndex(i+1)-2),' '];                
    end;
    strDir2=[strDir2,strDir(orbitIndex(numel(orbitIndex)):numel(strDir)-1)];
        
    % gumics_launch.sh
    fid=fopen([path,'gumicsfiles/gumics_launch-',strOrbit,'.sh'], 'w');  
    
    fprintf(fid,'#!/bin/bash\n');
    fprintf(fid,'for d in %s\n',strDir2);
    fprintf(fid,'do\n');
    fprintf(fid,'cd $d\n');
    fprintf(fid,'if [ -z "$(ls mstate*.hc 2>&1 |tail -1|grep -v such)" ]\n');
    fprintf(fid,'then\n');
    fprintf(fid,'./gumics -config config$(echo $d|cut -d t -f2|cut -f1,2,3 -d-)-constBx0 2>&1 >> gumics-$(echo $d|cut -d t -f2|cut -f1,2,3 -d-)-constBx0.log &\n');
    fprintf(fid,'else\n');
    fprintf(fid,'./gumics -config config$(echo $d|cut -d t -f2|cut -f1,2,3 -d-)-constBx0 -input $(ls mstate*.hc|tail -1) 2>&1 >> gumics-$(echo $d|cut -d t -f2|cut -f1,2,3 -d-)-constBx0.log & \n');
    fprintf(fid,'fi\n');
    fprintf(fid,'# ---\n');
    fprintf(fid,'#ls -l|less\n');
    fprintf(fid,'#less gumics*.log\n');
    fprintf(fid,'#less input*.dat\n');
    fprintf(fid,'#vi config*\n');
    fprintf(fid,'# ---\n');
    fprintf(fid,'cd ..\n');
    fprintf(fid,'done\n');
    fprintf(fid,'wait\n');
    
    fclose(fid);   
end
