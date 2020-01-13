function [ error ] = mkAssimilationInputFile( epsFilename )
%mkAssimilationInputFile Creates GUMICS4 input and configuration 
%   files from OMNIWeb data. Read OMNIWeb data, interpolates. A plot of
%   B, Vx and n created for comparision. 
% 
%   epsFilename : The name of the eps file
%   nsave       : Save frequency
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2013
%   Finnish Meteorologycal Institute, Helsinki
%----------------------------------------------------------------------
%   
    % Default directories
    root_path='/home/facsko/Projects/matlab/ECLAT/';    
    omni_path='/home/facsko/OMNIWeb/';   

    % NUmber of rows
    N=360;
    % Array declaration
    A=zeros(N,12);
    t=(1:N);
    % Read the orbit OMNIWeb file
    fid=fopen([omni_path,'2001292.dat'], 'r');      
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
    
    % Generate files ---------------------------------        
    % Figure in the background   
    p = figure('visible','off');   
    % Bz plot
    Bmag=sqrt(A(1:N,5).^2+A(1:N,6).^2+A(1:N,7).^2);
    subplot(3,1,1); plot(t(1:N),Bmag,'-k'); 
    datetick('x','HH:MM'); grid on;
    axis([t(1) t(N) 5*floor(min([Bmag;A(1:N,5);A(1:N,6);A(1:N,7)])/5)...
        5*round(max(Bmag)/5+1)]);
    title(['B_z and V_x from OMNIWeb from ',...
        datestr(t(1),'yyyymmdd hh:MM'),' to ',...
        datestr(t(N),'yyyymmdd hh:MM')]);
%        xlabel('Time [HH:MM]');
    ylabel('B B_x B_y B_z [nT]');  
    hold on;
    subplot(3,1,1); plot(t(1:N),A(1:N,5),'-r'); 
    subplot(3,1,1); plot(t(1:N),A(1:N,6),'-g'); 
    subplot(3,1,1); plot(t(1:N),A(1:N,7),'-b'); 
    hold off;
    % Vx plot
    subplot(3,1,2); plot(t(1:N),A(1:N,8),'-k'); 
    datetick('x','HH:MM'); grid on;
    axis([t(1) t(N) 50*floor(min(A(1:N,8))/50) 0]);  
    xlabel('Time [HH:MM]');
    ylabel('V_x [km/s]');        
    % n plot
    subplot(3,1,3); plot(t(1:N),A(1:N,11),'-k'); 
    datetick('x','HH:MM'); grid on;
    axis([t(1) t(N) 0 5*floor(max(A(1:N,11))/5+1)]);
    xlabel('Time [HH:MM]');
    ylabel('n [cm^-3]'); 
    % Saving result in an eps file
    strTstart=datestr(t(1),'yyyymmdd_hhMMss');
    strTend=datestr(t(N),'yyyymmdd_hhMMss');
    strNum=num2str(i);
    if (i<10),strNum=['0',strNum];end;            
    print(p,'-depsc2',[root_path,'/images/constBx0-assimilation',...
        '-',strTstart,'_',strTend,'.eps']);
    % Closing the plot box
    close;        

    % Create directories
    strDir=['assimilation-',strTstart,'_',strTend,'-constBx0/'];
    [status,result]=unix(['mkdir ',root_path,'gumicsfiles/',strDir]);
    % Link gumics & MSIS.dat
%        [status,result]=unix(['ln /home/facsko/GUMICS-4/gumics ',root_path,'gumicsfiles/',strDir,'/']);
%        [status,result]=unix(['ln /home/facsko/GUMICS-4/MSIS.dat ',root_path,'gumicsfiles/',strDir,'/']);

    % Inputfile ---------------------------------------------------        
    inputFilename=['input-assimilation-',strTstart,'_',strTend,...
        '-constBx0.dat'];
    fid=fopen([root_path,'/gumicsfiles/',strDir,inputFilename], 'w');    
    % Initialisation
    for j=1:59
        fprintf(fid,'%e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\n',(j-1)*60.,...
             A(1,11)*10^6,A(1,12),A(1,8)*1000,...
             A(1,9)*1000,A(1,10)*1000,0.0,...
             A(1,6)*10^-9,A(1,7)*10^-9);
    end;  
    % Input file
    for j=1:(N-1)
        fprintf(fid,'%e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\n',(j-1+59)*60.,...
            A(1+j,11)*10^6,A(1+j,12),A(1+j,8)*1000,...
            A(1+j,9)*1000,A(1+j,10)*1000,0.0,...
            A(1+j,6)*10^-9,A(1+j,7)*10^-9);
    end;
    fclose(fid);   

    % constBx0
    constBx0=sum(A(1+1:N,5))/(N-1);

    % Config file --------------------------------------------------

    % Calculate average tiltangle
    tiltangle=getTilt(t(1),t(N));
    % Generating tiltepoch
    tiltepoch=getTiltEpoch(t(1),t(N),tiltangle);
    % Configuration filename
    configFilename=['gumicsfiles/',strDir,'config-assimilation-',...
        strTstart,'_',strTend,'-constBx0'];
    swEpoch=datestr(t(1)-1/24,'yyyymmddhhMM');
    % Initialisation
%        nsave=60;
    %tmax=600; 
    %if (nsave~=60), 
    nsave=60;
    tmax=(N-1+58)*60;
    mkConfigFile([root_path,configFilename],inputFilename,constBx0,...
        swEpoch,tiltepoch,nsave,tmax);
end

