function [ error ] = mkClusterOrbitDump( dumpDate )
%mkClusterPointfiles Dump simulation data along the Cluster SC3 orbit. 
%   CAA product, dump simulation data along Cluster SC3 orbit on a given 
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
    % Data path
    sim_path='/home/facsko/stornext/';  
    data_path='/home/facsko/QSAS/C3_CP_AUX_POSGSE_1M/';
    root_path='/home/facsko/Projects/matlab/ECLAT/';     

    % Processes more days 
    for in=1:numel(dumpDate(:,1))  
[datestr(now),' ',dumpDate(in,:)]        
        % Delete previous results and temporary files
        [status,result]=unix(['rm ',root_path,'products/clo-',dumpDate(in,:),'-dump.dat 2>&1 > /dev/null']);
        [status,result]=unix(['rm ',root_path,'data/clo-',dumpDate(in,:),'-temp.dat 2>&1 > /dev/null']);
        [status,result]=unix(['rm ',root_path,'pointfiles/temp_pointfile-',dumpDate(in,:),'.dat 2>&1 > /dev/null']);

        % Determine the appropriate directories      
        mstateArray='';
        [status,result]=unix(['cd ',sim_path,';ls -lR orbit[234][0-9][0-9]-[01][0-9]-*',dumpDate(in,:),'*|grep constBx0:']);
        posOrbit=[strfind(result,'orbit'),numel(result)+1];
        for id=2:numel(posOrbit)
            dirStr=result(posOrbit(id-1):posOrbit(id)-3)
            % Determine the appropriate files (exclude intialisation!!!)
            [status,result2]=unix(['cd ',sim_path,';ls -R ',dirStr,'/mstate',dumpDate(in,:),'_*.hc']) 
            posOrbit2=strfind(result2,'orbit')
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
        [status,posFilename]=unix(['ls ',data_path,'C3_CP_AUX_POSGSE_1M__',strDate,'_000000_*_000000_V091203.cef']);
        posArray=readCefPos('','',posFilename(1:numel(posFilename)-1),tStart,tEnd);

        % Couple orbit and orbit simulation data ---------------------------
        for im=1:numel(mstateArray(:,1))
            strTime=mstateArray(im,60:72);
            t=datenum([str2num(strTime(1:4)) str2num(strTime(5:6))...
                str2num(strTime(7:8)) str2num(strTime(10:11))...
                str2num(strTime(12:13)) 0]);
                [vmin,imin]=min(abs(posArray.time-t));
%[datestr(t),'  ',datestr(posArray.time(imin))]    
                 % Create point files
                 fid=fopen([root_path,'pointfiles/temp_pointfile-',dumpDate(in,:),'.dat'], 'w');   
                     fprintf(fid,'%i\t%10i\t%10i\n',posArray.x(imin)*1000,...
                         posArray.y(imin)*1000,posArray.z(imin)*1000);
                 fclose(fid);    
                 [status,result2]=unix(['cd ',sim_path,'; echo ',...
                     datestr(t,'yyyy-mm-ddTHH:MM:SS.000Z'),...
                     ' $(hcintpol -n -v rho,n,rhovx,rhovy,rhovz,vx,vy,vz,P,T,Bx,By,Bz,Ex,Ey,Ez,Sx,Sy,Sz,Kx,Ky,Kz,jx,jy,jz ',...
                     mstateArray(im,:),' < ',root_path,...
                     'pointfiles/temp_pointfile-',dumpDate(in,:),'.dat) >> ',root_path,...
                     'data/clo-',dumpDate(in,:),'-temp.dat; rm ',...
                     root_path,'pointfiles/temp_pointfile-',dumpDate(in,:),'.dat']);        
        end;
 
        % Formated output for each file
        unix(['cd ',root_path,'data; ./filter.sh clo-',dumpDate(in,:),...
            '-temp.dat ../products/clo-',dumpDate(in,:),'-dump.dat;rm ',root_path,...
            'data/clo-',dumpDate(in,:),'-temp.dat']);
   end;
end
