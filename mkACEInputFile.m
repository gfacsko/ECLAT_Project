function [ error ] = mkACEInputFile( )
%mkACEInputFile Creates GUMICS4 input files from OMNIWeb data
%   Read OMNIWeb data, interpolates and remove the divergency. A plot of
%   Bx created for comparision. 
% 
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2012
%   Finnish Meteorologycal Institute, Helsinki
%----------------------------------------------------------------------
%   
    % Default directories
    root_path='/home/facsko/Projects/matlab/ECLAT/';   
   
    % Array declaration
    N=282;
    A=zeros(N,13);
    t=(1:N);
    % Read the ACE file
    fid=fopen([root_path,'data/ACE_MAGSWE_Data-20010920_090000_20010920_140000.dat'], 'r');      
    % Reading data
    i=1;   
	strLine=fgetl(fid);
	while (feof(fid)==0)
		A(i,:) = sscanf(strLine,'%i %i %i %i %f %f %f %f %f %f %f %f %f\n');
        t(i)=datenum([A(i,1) 0 A(i,2) A(i,3) A(i,4) A(i,5)]);
        i=i+1;           
	    strLine=fgetl(fid);
    end;
    A(i,:) = sscanf(strLine,'%i %i %i %i %f %f %f %f %f %f %f %f %f\n');
    t(i)=datenum([A(i,1) 0 A(i,2) A(i,3) A(i,4) A(i,5)]);
    fclose(fid);
      
    % Interpolation
    p=0;
    m=0;
    for i=1:numel(A(:,1))
        % density interpolation
        if (A(i,6)~=-9999.900 && p>0)
            if (i>p+1)
                for k=1:p          
                    A(i-p-1+k,6:7)=A(i-p-1,6:7)+k/(p+1)*(A(i,6:7)-A(i-p-1,6:7));
                end;
            else
                for k=1:p          
                    A(i-p-1+k,6:7)=A(i,6:7);
                end;
            end;
            p=0;
        end;
        if (A(i,6)==-9999.900)
            p=p+1;            
        end;        
        % IMF
        if (A(i,8)~=-9999.900 && m>0)
            if (i>m+1)
                for k=1:m      
                    A(i-m-1+k,8:10)=A(i-m-1,8:10)+k/(m+1)*(A(i,8:10)-A(i-m-1,8:10));                    
                end;
            else
                for k=1:m                     
                    A(i-m-1+k,8:10)=A(i,8:10);                    
                end;
            end;
            m=0;
        end;
        if (A(i,8)==-9999.900)
            m=m+1;            
        end; 
    end;
    % Datagaps at the end
    if (A(i,8)==-9999.900)
        for k=1:m      
            A(i-m+k,8:10)=A(i-m,8:10);
        end; 
    end;
    if (A(i,6)==-9999.900)
        for k=1:p      
            A(i-p+k,6:7)=A(i-p,6:7);
        end; 
    end;
    
    % Generate files for GUMICS ---------------------------------           

    % Figure in the background   
    p = figure('visible','off');   
    % Bz plot
    subplot(2,1,1); plot(t,A(:,13),'-k'); datetick('x','HH:MM'); grid on;
    axis([t(1) t(numel(t)) 5*floor(min(A(:,13))/5) 5*round(max(A(:,13))/5+1)]);       
    title(['B_z and V_x from ACE SC from ',...
        datestr(t(1),'yyyymmdd hh:MM'),' to ',...
        datestr(t(numel(t)),'yyyymmdd hh:MM')]);
%        xlabel('Time [HH:MM]');
    ylabel('B_z [nT]');              
     % Vx plot
    subplot(2,1,2); plot(t,A(:,8),'-k'); datetick('x','HH:MM'); grid on;
    axis([t(1) t(numel(t)) 50*floor(min(A(:,8))/50) 0]);  % 50*round(max(A(minIndex:maxIndex,8))/50+1)
    xlabel('Time [HH:MM]');
    ylabel('V_x [nT]');        
    % Saving result in an eps file                
    print(p,'-depsc2',[root_path,'/images/ACE_SWEPAM-20010920_090000_20010920_140000.eps']);
    % Closing the plot box
    close;        

    % Inputfile ---------------------------------------------------        
    inputFilename='ace_input_20010920_090000_20010920_140000-constBx0.dat';
    fid=fopen([root_path,'gumicsfiles/',inputFilename], 'w');    
    % Initialisation
    for j=1:55
        fprintf(fid,'%e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\n',(j-1)*64.,...
             A(1,6)*10^6,A(1,7),A(1,8)*1000,A(1,9)*1000,A(1,10)*1000,...
             0.0,A(1,12)*10^-9,A(1,13)*10^-9);
    end;  
    % Input file
    for j=1:numel(A(:,1))
        fprintf(fid,'%e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\t%14.6e\n',(j-1+55)*64.,...
            A(j,6)*10^6,A(j,7),A(j,8)*1000,A(j,9)*1000,A(j,10)*1000,...
            0.0,A(j,12)*10^-9,A(j,13)*10^-9);
    end;
    fclose(fid);   

    % constBx0
    constBx0=sum(A(:,11))/numel(A(:,11));

    % Config file --------------------------------------------------

    % Calculate average tiltangle
    tiltangle=getTilt(t(1),t(numel(t)));
    % Generating tiltepoch
    tiltepoch=getTiltEpoch(t(1),t(numel(t)),tiltangle);
    % Configuration filename
    configFilename=['gumicsfiles/','ace_config_20010920_090000_20010920_140000-constBx0'];
    swEpoch=datestr(t(1)-224/225/24,'yyyymmddhhMM');
    % Initialisation
    mkConfigFile([root_path,configFilename],inputFilename,constBx0,...
        swEpoch,tiltepoch,300,64*(numel(A(:,1))+54));      
end

