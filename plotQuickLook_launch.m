function [ error ] = plotQuickLook_launch( Norb, strRestart )
%plotQuickLook_launch Read the mstate files and generate plots
%  Enters the target directory, list the available mstate files and
%  creates quicklook plots. 
% 
%  Norb: Orbit number
%
%  Developed by Gabor Facsko, Finish Meteorologycal Institute, 2012
%  gabor.facsko@fmi.fi
%
%------------------------------------------------------------------
%
    error=0;
    tRestart=datenum(strRestart,'yyyymmdd_HHMM');
    % Data path
    sim_path='/home/facsko/stornext/';  
    root_path='/home/facsko/Projects/matlab/ECLAT/';         
    
    % Footprint reading initalisation
    strDate='99999999';
    % Tsyganenko footprint - read once
    fpTsyArray=readTsyFootprint();
    
    % Processes more orbits
    for io=Norb(1):Norb(2)
    
        % Create working directory    
        [status,result]=unix(['mkdir ',root_path,'products/o',...
            num2str(io),' 2>&1 > /dev/null']);
       
        % List mstate files  
        for is=1:12
            % Orbit number
            strS=num2str(is);
            if (is<10),strS=['0',strS];end;
            % mstate/istate File list
            [status,result] = unix(['ls -R ',sim_path,'orbit',...
                num2str(io),'-',strS,'-*/mstate*.hc']);
            nBegin=strfind(result,[sim_path,'orbit']);
            strBegin=result(nBegin(1)+34:nBegin(1)+48);
            tBegin=datenum([str2num(strBegin(1:4)) str2num(strBegin(5:6))...
                str2num(strBegin(7:8)) str2num(strBegin(10:11))...
                str2num(strBegin(12:13)) 0]);        
            nTime=strfind(result,'mstate');           
            % Read footprint(s)
            if (strcmp(strDate,'99999999'))
                strDate=result(nTime(1)+6:nTime(1)+13);                                  
                fpArray=readFootprint(strDate);
            end;        
            % Process files
            for it=1:numel(nTime)
                strTime=result(nTime(it)+6:nTime(it)+20);
                t=datenum([str2num(strTime(1:4)) str2num(strTime(5:6))...
                    str2num(strTime(7:8)) str2num(strTime(10:11))...
                    str2num(strTime(12:13)) 0]);                                                                
                % Read footprints?
                if (~strcmp(strDate,strTime(1:8)))
                    strDate=strTime(1:8)                
                    fpArray=readFootprint(strDate);
                    % Is there any footprint?
                    if (numel(fpArray(:,1))==0),fpArray=zeros(1,8);end;                    
                end;
                [vfp,ifp]=min(abs(fpArray(:,1)-t));
                fp=fpArray(ifp,2:8);
                % Is the result close?
                if (1440*vfp>10),fp=[0,0,0,0,0,0,0];end;    
                [vfpTsy,ifpTsy]=min(abs(fpTsyArray(:,1)-t));  
                fpTsy=fpTsyArray(ifpTsy,2:8);
                % Is the result close?
                if (1440*vfpTsy>10),fpTsy=[0,0,0,0,0,0,0];end;                                
                fp=[fp,fpTsy];
                % Restart if the script collapses               
                if ((t>tBegin) && (t>tRestart))
                     % Check whether the data was dumped or not
%                      [status2,result2] = unix(['ls ',root_path,...
%                          'data/*Dump-',strTime,'.dat']);
                     isDump=1;
%                      if (status2==0),isDump=0;end;
% Logging indicator
[datestr(now),' ',result(nBegin(1)+22:nBegin(1)+73), ' ',datestr(t)]
                    fileStr=result(nTime(it):nTime(it)+23);
%                      plotQuickLook_magn(result(nBegin(1)+22:nBegin(1)+73),...
%                          result(nTime(it):nTime(it)+23),isDump);
                     plotQuickLook_iono(result(nBegin(1)+22:nBegin(1)+73),...
                          fileStr,isDump,fp);
                     % Compres eps files
%                     unix(['gzip ',root_path,'images/*[anp]QuickPlot*.eps ']);
                     unix(['gzip ',root_path,'images/[ns]*QuickPlot-',...
                         fileStr(7:numel(fileStr)-3),'.eps ']);
                     % Move results 
%                      unix(['mv ',root_path,'images/*[anp]QuickPlot*.* ',...
%                          root_path,'products/o',num2str(io),'/']);
                     unix(['mv ',root_path,'images/[ns]*QuickPlot-',...
                         fileStr(7:numel(fileStr)-3),'.eps.gz ',...
                         root_path,'products/o',num2str(io),'/']);
                     % Delete data files
                     unix(['rm ',root_path,'data/*Dump-',...
                         fileStr(7:numel(fileStr)-3),'.dat']);
                end;
            end;
        end;    
     end;
end

