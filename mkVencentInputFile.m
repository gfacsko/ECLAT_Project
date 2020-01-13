function [ error ] = mkTanjaInputFile( tStart, tEnd, tiltepoch, nsave )
%plotGaps Creates GUMICS4 input files from OMNIWeb data
%   Read OMNIWeb data, interpolates and remove the divergency. A plot of
%   Bx created for comparision. 
% 
%   tStart   : Start
%   tEnd     : End
%   nsave    : Save frequency
%   tiltepoch: tilt angle
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2012
%   Finnish Meteorologycal Institute, Helsinki
%----------------------------------------------------------------------
%   
    % Default directories
    root_path='/home/facsko/Projects/matlab/ECLAT/';     
  
    N=120;

    % Array declaration
    A=zeros(N,12);
    t=(1:N);
    for i=1:N
        A(i,11)=20.4;
        A(i,12)=190833;
        A(i,8:10)=[-428.4; 292.9; 189.6]; %[-552.3 -10.8 -6.9];
        A(i,5:7)=[-8.3 -0.0 0.0];
        if (i>62)
            A(i,11)=39.8;
            A(i,12)=403193;
            A(i,8:10)=[-709.1 1.0 0.6];
            A(i,5:7)=[-34.1 0.0 0.1];    
        end;
        t(i)=datenum([2000 1 1 0 i 0]);
    end;
    
    % Generate files for the interval ---------------------------------    
    minIndex=1;
    maxIndex=round(N);
    if (maxIndex>numel(A(:,1))),maxIndex=numel(A(:,1));end;
        
    % Figure in the background   
    p = figure('visible','off');   
    % Bz plot
    subplot(2,1,1); plot(t(minIndex:maxIndex),A(minIndex:maxIndex,7),'-k'); 
    datetick('x','HH:MM'); grid on;
    axis([t(minIndex) t(maxIndex) 5*floor(min(A(minIndex:maxIndex,7))/5) ...
        5*round(max(A(minIndex:maxIndex,7))/5+1)]);       
    title(['B_z and V_x from OMNIWeb from ',...
        datestr(t(minIndex),'yyyymmdd hh:MM'),' to ',...
        datestr(t(maxIndex),'yyyymmdd hh:MM')]);
%        xlabel('Time [HH:MM]');
    ylabel('B_z [nT]');              
    % Vx plot
    subplot(2,1,2); plot(t(minIndex:maxIndex),A(minIndex:maxIndex,8),'-k'); 
    datetick('x','HH:MM'); grid on;
    axis([t(minIndex) t(maxIndex) 50*floor(min(A(minIndex:maxIndex,8))/50) ...
        0]);  % 50*round(max(A(minIndex:maxIndex,8))/50+1)
    xlabel('Time [HH:MM]');
    ylabel('V_x [nT]');        
    % Saving result in an eps file
    strTstart=datestr(t(minIndex),'yyyymmdd_hhMMss');
    strTend=datestr(t(maxIndex),'yyyymmdd_hhMMss');
    if (i<10),strNum=['0',strNum];end;            
    print(p,'-depsc2',[root_path,'/images/constBx0-',...
        strTstart,'_',strTend,'.eps']);
    % Closing the plot box
    close;        
         
    % Create directory
    strDir=['vencent-',strTstart,'_',strTend,'-constBx0/'];
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
    constBx0=0;%sum(A(1:maxIndex,5))/(maxIndex-minIndex);
        
    % Config file --------------------------------------------------
        
%     % Calculate average tiltangle
%     tiltangle=getTilt(t(minIndex),t(maxIndex));
%     % Generating tiltepoch
%     tiltepoch=getTiltEpoch(t(minIndex),t(maxIndex),tiltangle);
    % Configuration filename
    configFilename=['gumicsfiles/',strDir,'config-',strTstart,'_',...
        strTend,'-constBx0'];
    swEpoch=datestr(t(minIndex)-1/24,'yyyymmddhhMM');
    % Initialisation
    tmax=(maxIndex-minIndex+58)*60;
    mkConfigFile([root_path,configFilename],inputFilename,constBx0,...
        swEpoch,tiltepoch,nsave,tmax);        
end

