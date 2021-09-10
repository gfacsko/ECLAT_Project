function [ error ] = mkInputFile( omniFileName, nsave )
%plotGaps Creates GUMICS4 input files from OMNIWeb data
%   Read OMNIWeb data, interpolates and remove the divergency. A plot of
%   Bx created for comparision. 
% 
%   omniFileName : The name of the OMNI file
%   nsave        : Save frequency
%
%   Developed by Gabor Facsko (facsko.gabor@wigner.hu), 2012-2021
%   Wigner Research Institute for Physics, Budapest, Hungary
%----------------------------------------------------------------------
%   
    % Default directories
    root_path='/home/facskog/Projectek/Matlab/ECLAT/'; 
    omni_path='/home/facskog/OMNIWeb/';
  
    % Number of lines
    [status,result]=unix(['wc -l ',omni_path,omniFileName]);
    N=str2num(result(1:findstr(result,' ')));
    % Array declaration    
    A=zeros(N,12);
    t=(1:N);
    % Read the OMNIWeb file
    fid=fopen([omni_path omniFileName], 'r');   
    % Reading data
    i=1;   
	strLine=fgetl(fid);
	while (feof(fid)==0)
		A(i,:) = sscanf(strLine,'%i %i %i %i %f %f %f %f %f %f %f %f\n');
        t(i)=datenum([A(i,1) 0 A(i,2) A(i,3) A(i,4) 0]);
        i=i+1;           
	    strLine=fgetl(fid);
    end;
    A(i,:) = sscanf(strLine,'%i %i %i %i %f %f %f %f %f %f %f %f\n');
    t(i)=datenum([A(i,1) 0 A(i,2) A(i,3) A(i,4) 0]);
    fclose(fid);
      
    % Interpolation
    p=0;
    m=0;
    for i=1:numel(A(:,1))
        % Plasma data interpolation
        if (A(i,12)~=9999999 && p>0)
            if (i>p+1)
                for k=1:p          
                    A(i-p-1+k,8:12)=A(i-p-1,8:12)+k/(p+1)*(A(i,8:12)-A(i-p-1,8:12));
                end;
            else
                for k=1:p          
                    A(i-p-1+k,8:12)=A(i,8:12);
                end;
            end;
            p=0;
        end;
        if (A(i,12)==9999999)
            p=p+1;            
        end;        
        % IMF
        if (A(i,5)~=9999.99 && m>0)
            if (i>m+1)
                for k=1:m      
                    A(i-m-1+k,5:7)=A(i-m-1,5:7)+k/(m+1)*(A(i,5:7)-A(i-m-1,5:7));                    
                end;
            else
                for k=1:m                     
                    A(i-m-1+k,5:7)=A(i,5:7);                    
                end;
            end;
            m=0;
        end;
        if (A(i,5)==9999.99)
            m=m+1;            
        end; 
    end;
    % Datagaps at the end
    if (A(i,5)==9999.99)
        for k=1:m      
            A(i-m+k,5:7)=A(i-m,5:7);
        end; 
    end;
    if (A(i,12)==9999999)
        for k=1:p      
            A(i-p+k,8:12)=A(i-p,8:12);
        end; 
    end;
    
    % Generate files for the interval ---------------------------------    
    minIndex=1;
    maxIndex=round(N);
    if (maxIndex>numel(A(:,1))),maxIndex=numel(A(:,1));end;
        
    % Figure in the background   
    p = figure('visible','off');   
    % Bz plot
    subplot(2,1,1); plot(t(minIndex:maxIndex),A(minIndex:maxIndex,7),'.k','MarkerSize',1); 
    datetick('x','HH:MM'); grid on;
    axis([t(minIndex) t(maxIndex) 5*floor(min(A(minIndex:maxIndex,7))/5) ...
        5*round(max(A(minIndex:maxIndex,7))/5+1)]);       
    title(['B_z and V_x from OMNIWeb from ',...
        datestr(t(minIndex),'yyyymmdd HH:MM'),' to ',...
        datestr(t(maxIndex),'yyyymmdd HH:MM')]);
%        xlabel('Time [HH:MM]');
    ylabel('B_z [nT]');              
    % Vx plot
    subplot(2,1,2); plot(t(minIndex:maxIndex),A(minIndex:maxIndex,8),'.k','MarkerSize',1); 
    datetick('x','HH:MM'); grid on;
    axis([t(minIndex) t(maxIndex) 50*floor(min(A(minIndex:maxIndex,8))/50) ...
        0]);  % 50*round(max(A(minIndex:maxIndex,8))/50+1)
    xlabel('Time [HH:MM]');
    ylabel('V_x [nT]');        
    % Saving result in an eps file
    strTstart=datestr(t(minIndex),'yyyymmdd_HHMMss');
    strTend=datestr(t(maxIndex),'yyyymmdd_HHMMss');
    if (i<10),strNum=['0',strNum];end;            
    print(p,'-depsc2',[root_path,'/images/constBx0-',...
        strTstart,'_',strTend,'.eps']);
    % Closing the plot box
    close;        
         
    % Create directory
    strDir=['omni-',strTstart,'_',strTend,'-constBx0/'];
    [status,result]=unix(['mkdir ',root_path,'gumicsfiles/',strDir]);
    
    % Inputfile ---------------------------------------------------        
    inputFilename=['input-',strTstart,'_',strTend,'-constBx0.dat'];
    fid=fopen([root_path,'/gumicsfiles/',strDir,inputFilename], 'w');    
    % Initialisation
    for j=1:59
        fprintf(fid,'%e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\n',(j-1)*60.,...
             A(minIndex,11)*10^6,A(minIndex,12),A(minIndex,8)*1000,...
             A(minIndex,9)*1000,A(minIndex,10)*1000,0.0,...
             A(minIndex,6)*10^-9,A(minIndex,7)*10^-9);
    end;  
    % Input file
    for j=1:(maxIndex-minIndex)
        fprintf(fid,'%e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\n',(j-1+59)*60.,...
            A(minIndex+j,11)*10^6,A(minIndex+j,12),A(minIndex+j,8)*1000,...
            A(minIndex+j,9)*1000,A(minIndex+j,10)*1000,0.0,...
            A(minIndex+j,6)*10^-9,A(minIndex+j,7)*10^-9);
    end;
    fclose(fid);   
        
    % constBx0
    constBx0=sum(A(1:maxIndex,5))/(maxIndex-minIndex);
        
    % Config file --------------------------------------------------
        
%     % Calculate average tiltangle
%     tiltangle=getTilt(t(minIndex),t(maxIndex));
%     % Generating tiltepoch
%     tiltepoch=getTiltEpoch(t(minIndex),t(maxIndex),tiltangle);
    tiltepoch=datestr(t(minIndex),'yyyymmddHHMM');
    % Configuration filename
    configFilename=['gumicsfiles/',strDir,'config-',strTstart,'_',...
        strTend,'-constBx0'];
    swEpoch=datestr(t(minIndex)-1/24,'yyyymmddHHMM');
    % Initialisation
    tmax=(maxIndex-minIndex+58)*60;
    mkConfigFile([root_path,configFilename],inputFilename,constBx0,...
        swEpoch,tiltepoch,nsave,tmax);        
end

