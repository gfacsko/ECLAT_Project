function [ error ] = mkKarinOrbitDump( dumpDate )
%mkClusterPointfiles Dump data along the geotail and polar orbit. 
%   Dump simulation data along polar and geotail orbit on a given 
%   day. 
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2012-2013
%
% -----------------------------------------------------------------
%
%   octave version!!!
% 
% -----------------------------------------------------------------
%
    % GLIBCXX problem
    MatlabPath = getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH',getenv('PATH'));
    setenv('LD_LIBRARY_PATH',MatlabPath);
    % Normal start
    error=0;
    % Data path
    sim_path='/home/gfacsko/stornext/';  
    root_path='/home/gfacsko/Projects/Matlab/ECLAT/';   
%    root_path=['/media/Gabor\ FACSKO/Ilmatieteen\ Laitos/gabor10k/',...
%        'ubuntu-20131209/Projects/matlab/ECLAT/'];
%    data_path='/home/facsko/QSAS/C3_CP_AUX_POSGSE_1M/';
    data_path=[root_path,'data/'];
    
    % Processes more days 
    for in=1:numel(dumpDate(:,1))  
[datestr(now),' ',dumpDate(in,:)]        
        % Delete previous results and temporary files
        [status,result]=unix(['rm ',root_path,'products/geotail-',dumpDate(in,:),'-dump.dat 2>&1 > /dev/null']);
        [status,result]=unix(['rm ',root_path,'data/geotail-',dumpDate(in,:),'-temp.dat 2>&1 > /dev/null']);
        [status,result]=unix(['rm ',root_path,'pointfiles/temp_pointfile-',dumpDate(in,:),'.dat 2>&1 > /dev/null']);

        % Determine the appropriate directories      
        mstateArray='';
        [status,result]=unix(['cd ',sim_path,';ls -lR orbit[234][0-9][0-9]-[01][0-9]-*',dumpDate(in,:),'*|grep constBx0:']);
        posOrbit=[strfind(result,'orbit'),numel(result)+1];
        for id=2:numel(posOrbit)
            dirStr=result(posOrbit(id-1):posOrbit(id)-3)
            % Determine the appropriate files (exclude intialisation!!!)
            [status,result2]=unix(['cd ',sim_path,';ls -R ',dirStr,'/mstate',dumpDate(in,:),'_*.hc']); 
            posOrbit2=strfind(result2,'orbit');
            for io=1:numel(posOrbit2)
                filename='';
                if (io==1 && numel(posOrbit2)>1),filename=result2(1:posOrbit2(io+1)-2);end;
                if (io>1 && io<numel(posOrbit2)),filename=result2(posOrbit2(io):posOrbit2(io+1)-2);end;
                if (io==numel(posOrbit2)),filename=result2(posOrbit2(io):numel(result2)-1);end;
                % Exclude initialisation
                strStart=filename(:,13:25);
                strMstate=filename(:,60:72);
                tStart=datenum([str2num(strStart(1:4)) str2num(strStart(5:6))...
                    str2num(strStart(7:8)) str2num(strStart(10:11))...
                    str2num(strStart(12:13)) 0]);
                tMstate=datenum([str2num(strMstate(1:4)) str2num(strMstate(5:6))...
                    str2num(strMstate(7:8)) str2num(strMstate(10:11))...
                    str2num(strMstate(12:13)) 0]);
                if (tStart<tMstate),mstateArray=[mstateArray;filename];end;
            end;
        end;

        % Read orbit data ----------------------------------------------------
        % Determination of the interval
        strDate=dumpDate(in,:);
        tStart=datenum([str2num(strDate(1:4)) str2num(strDate(5:6))...
             str2num(strDate(7:8)) 0 0 1]);
        tEnd=datenum([str2num(strDate(1:4)) str2num(strDate(5:6))...
             str2num(strDate(7:8)) 23 59 59]);
        % Filename
        posFilename=[data_path,'geotail_orbit_gse.txt'];         
        posArray=load(posFilename);       
        % Time
        fid=fopen (posFilename, 'r');    
        ip=1;
        while (~feof(fid))        
            strLine=fgetl(fid);
            t=datenum(strLine(1:19),'yyyy-mm-ddTHH:MM:00');       
            posArray(ip,1)=t;               
            ip=ip+1;
        end;
        fclose(fid);     
        posArray(:,2:4)=posArray(:,2:4)/1000;

        % Couple orbit and orbit simulation data ---------------------------
        for im=1:numel(mstateArray(:,1))
            strTime=mstateArray(im,60:72);
            t=datenum([str2num(strTime(1:4)) str2num(strTime(5:6))...
                str2num(strTime(7:8)) str2num(strTime(10:11))...
                str2num(strTime(12:13)) 0]);
                [vmin,imin]=min(abs(posArray(:,1)-t));
                % Dump at the right time
                if (24*3600*vmin<5)
%[datestr(t),'  ',datestr(posArray.time(imin))]    
                     % Create point files
                     fid=fopen([root_path,'pointfiles/temp_pointfile-',dumpDate(in,:),'.dat'], 'w');   
                     fprintf(fid,'%i\t%10i\t%10i\n',posArray(imin,2)*1000,...
                         posArray(imin,3)*1000,posArray(imin,4)*1000);
                     fclose(fid);    
                     % GLIBCXX problem
                     MatlabPath = getenv('LD_LIBRARY_PATH');
                     setenv('LD_LIBRARY_PATH',getenv('PATH')); 
                     % Normal start
                     [status,result2]=unix(['cd ',sim_path,'; echo ',...
                         datestr(t,'yyyy-mm-ddTHH:MM:SS.000Z'),...
                         ' $(/home/gfacsko/gumics/bin/hcintpol -n -v rho,n,rhovx,rhovy,rhovz,vx,vy,vz,P,T,Bx,By,Bz,Ex,Ey,Ez,Sx,Sy,Sz,Kx,Ky,Kz,jx,jy,jz ',...
                         mstateArray(im,:),' < ',root_path,...
                         'pointfiles/temp_pointfile-',dumpDate(in,:),'.dat) >> ',root_path,...
                         'data/geotail-',dumpDate(in,:),'-temp.dat; cat ',...
                         root_path,'pointfiles/temp_pointfile-',dumpDate(in,:),'.dat']);     
                     % GLIBCXX problem
                     setenv('LD_LIBRARY_PATH',MatlabPath);
                end;
        end;
 
        % Formated output for each file
        unix(['cd ',root_path,'data; ./filter.sh geotail-',dumpDate(in,:),...
            '-temp.dat ../products/geotail-',dumpDate(in,:),'-dump.dat;rm ',root_path,...
            'data/geotail-',dumpDate(in,:),'-temp.dat']);
   end;
end
