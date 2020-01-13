function [ error ] = mkClusterFootprint( fpDate1,fpDate2 )
%mkClusterFootprint Determine footprint along the Cluster SC3 orbit. 
%   CAA product, determine footprint from simulation data along 
%   Cluster SC3 orbit on a given day. 
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2012-2013
%
% -----------------------------------------------------------------
%
    error=0;
    % Data path
%    sim_path='/home/facsko/stornext/';  
    sim_path='/media/My\ Book/ECLAT/dynamic\ runs';
    data_path='/home/gfacsko/QSAS/C3_CP_AUX_POSGSE_1M/';
    root_path='/home/gfacsko/Projects/Matlab/ECLAT/';     

    % Preparing for launching    
    footprintDate=[];
    for d=str2num(fpDate1(7:8)):str2num(fpDate2(7:8))
        strD=num2str(d);
        if (d<10),strD=['0',strD];end;
        footprintDate=[footprintDate;[fpDate1(1:6),strD]];
    end;
    
    % Processes more days 
    for in=1:numel(footprintDate(:,1))      
        % Delete previous results
        [status,result]=unix(['rm ',root_path,'products/footprint-',...
            footprintDate(in,:),'.dat 2>&1 > /dev/null']);   
        [status,result]=unix(['rm ',root_path,'data/footprint-',...
            footprintDate(in,:),'-temp.dat 2>&1 > /dev/null']);    

        % Determine the appropriate directories      
        mstateArray=[];
         [status,result]=unix(['cd ',sim_path,...
             ';ls -lR orbit[234][0-9][0-9]-[01][0-9]-*',...
             footprintDate(in,:),'*|grep constBx0:']);
%        [status,result]=unix(['cd ',sim_path,...
%            ';ls -lR tanja-*',footprintDate(in,:),'*|grep constBx0:']);
        posOrbit=[strfind(result,'orbit'),numel(result)+1];
%        posOrbit=[strfind(result,'tanja'),numel(result)+1];
        for id=2:numel(posOrbit)
           dirStr=result(posOrbit(id-1):posOrbit(id)-3);            
            % Determine the appropriate files (exclude intialisation!!!)
            [status,result2]=unix(['cd ',sim_path,';ls -R ',dirStr,...
                '/mstate',footprintDate(in,:),'_*.hc']); 
            posOrbit2=strfind(result2,'orbit');
%            posOrbit2=strfind(result2,'tanja-');
            for io=1:numel(posOrbit2)
                filename='';
                if (io==1 && numel(posOrbit2)>1)
                    filename=result2(1:posOrbit2(io+1)-2);
                end;
                if (io>1 && io<numel(posOrbit2))
                    filename=result2(posOrbit2(io):posOrbit2(io+1)-2);
                end;
                if (io==numel(posOrbit2))
                    filename=result2(posOrbit2(io):numel(result2)-1);
                end;    
              
                 % Exclude initialisation
                 strStart=filename(:,13:25);%strStart=filename(:,7:19);%
                 strMstate=filename(:,60:72);%strMstate=filename(:,54:68);
                 tStart=datenum([str2num(strStart(1:4)) str2num(strStart(5:6))...
                     str2num(strStart(7:8)) str2num(strStart(10:11))...
                     str2num(strStart(12:13)) 0]);
                 tMstate=datenum([str2num(strMstate(1:4)) str2num(strMstate(5:6))...
                     str2num(strMstate(7:8)) str2num(strMstate(10:11))...
                     str2num(strMstate(12:13)) 0]);
                 if (tStart<tMstate)                             
                     mstateArray=[mstateArray;deblank(filename)];
                 end;
             end;
        end;
        % Sort in ascending order
        mstateArray=sortrows(mstateArray);

        % Read orbit data ----------------------------------------------------
        % Determination of the intervall - octave specific code
%         strDate=footprintDate(in,:);
%         tStart=datenum([str2num(strDate(1:4)) str2num(strDate(5:6))...
%              str2num(strDate(7:8)) 0 0 1]);
%         tEnd=datenum([str2num(strDate(1:4)) str2num(strDate(5:6))...
%              str2num(strDate(7:8)) 23 59 59]);
%         Filename
%         [status,posFilename]=unix(['ls ',data_path,'C3_CP_AUX_POSGSE_1M__',...
%             strDate,'_000000_*_000000_V091203.cef']);
%         posArray=readCefPos('','',posFilename(1:numel(posFilename)-1),tStart,tEnd);
        
        % Couple orbit and orbit simulation data ---------------------------        
        for im=1:numel(mstateArray(:,1))            
            strTime=mstateArray(im,60:72);%mstateArray(im,54:68);% 
            t=datenum([str2num(strTime(1:4)) str2num(strTime(5:6))...
                str2num(strTime(7:8)) str2num(strTime(10:11))...
                str2num(strTime(12:13)) 0]);    
            % Restart date (if any)
            if (t>datenum([2002 10 11 10 15 0]) && t<datenum([2002 10 11 10 20 0]))            
            %if (t>datenum([2002 10 11 1 40 0]) && t<datenum([2002 10 11 1 45 0]))
            %if (t>datenum([2002 10 12 6 0 0]) && t<datenum([2002 10 12 6 5 0]))
                clPos=getClusterPosition([data_path,...
                     'C3_CP_AUX_POSGSE_1M__20021011_000000_20021013_000000_V091201.cdf'],t);
%                    'C3_CP_AUX_POSGSE_1M__20020129_000000_20030203_000000_V091201.cdf'],t);
%                    'C3_CP_AUX_POSGSE_1M__20090624_000000_20090802_000000_V110110.cdf'],t);
%                    'C3_CP_AUX_POSGSE_1M__20080717_000000_20080808_000000_V091203.cdf'],t);                    
                         
                % Determine footprint
                [fpStatus,fpPos,fpSMPos,fpTsyStatus,fpTsyPos,fpTsySMPos,param]=...
                    getFootprint(mstateArray(im,:),[clPos(1),clPos(2),clPos(3)]);    
                % Save results                        
                [status,result]=unix(['echo ',datestr(t,'yyyymmddThh:MM:ss.000Z'),' ',...
                    num2str(clPos(1)),' ',num2str(clPos(2)),' ',...
                    num2str(clPos(3)),' ',num2str(param),' ',...
                    num2str(fpStatus),' ',num2str(fpPos),' ',...
                    num2str(fpSMPos),' ',num2str(fpTsyStatus),' ',...
                    num2str(fpTsyPos),' ',num2str(fpTsySMPos),' >> ',...
                    root_path,'data/footprint-',footprintDate(in,:),'-temp.dat']);       
                [status,result]=unix(['gzip ',root_path,'images/footprint-',...
                    strTime,'00.eps; mv ',root_path,'images/footprint-',...
                    strTime,'00.eps.gz ',root_path,'products/']);
            end;
        end;    
        % Formated output for each file
        [status,result]=unix(['cd ',root_path,...
            'data; ./footprint-filter.sh footprint-',footprintDate(in,:),...
            '-temp.dat ../products/footprint-',footprintDate(in,:),...
            '.dat;rm ',root_path,'data/footprint-',footprintDate(in,:),...
            '-temp.dat']);
   %end;
end

