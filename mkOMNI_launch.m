function [ error ] = mkOMNI_launch(strSuffix) 
%plotCorrelation_launch Comparation of Cluster and 
%   OMNIWeb/GUMICS measurements
%   Check all previously created OMNIWeb/GUMICS and Cluster 
%   files. Study the OMNI data for each of them
%
%   Developed by Gabor Facsko (facsko.gabor@csfk.mta.hu)
%   HAS RCAES Geodetic and Geophysical Institute, 2017
%
% -----------------------------------------------------------------
%    
    error=0;
    % R_Earth
    RE=6380.0;
    % Default directories
    root_path='/home/facskog/Projectek/Matlab/ECLAT/';
    omni_path='/home/facskog/OMNIWeb/';
    % Saving the result in the right subdirectory   
    strSubDir='GUMICS-ClusterSC3-MSH/';    
    if (strcmp(strSuffix,'-sw'))
        strSubDir='GUMICS-ClusterSC3-SW/';
    end;
    if (strcmp(strSuffix,'-msph'))
        strSubDir='GUMICS-ClusterSC3-MSPH/';
    end;    
    
    % Delete old files
    [status,result]=unix(['rm $(echo ',root_path,'images/',strSubDir,...
        'corr-*-omni',strSuffix,'.eps)']);
    
    % Load OMNI data
    A = load([omni_path,'omni_min_20020131_20030201.dat']);  
    % Time conversion
    for ito=1:numel(A(:,1))
        A(ito,1)=datenum([A(ito,1) 0 A(ito,2) A(ito,3) A(ito,4) 0]);
    end;
    % Spare memory
    A=[A(:,1),A(:,5:14)];
    % Delete wrong data
    A=A(find(A(:,2)<999999),:);
    A=A(find(A(:,3)<99999),:);
    A=A(find(A(:,6)<999),:);
    
    % Read file        
    bzStr='-bz';
    [status,result]=unix(['ls ',root_path,'data/',strSubDir,...
        'corr-*',bzStr,'-gumics',strSuffix,'.dat']);   
    % Delete old file
    [status2,results2]=unix(['rm ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat']);
    % Process result
    startIndex=strfind(result,'corr-');
    endIndex=strfind(result,'.dat');
    for i=1:numel(startIndex)
        % Correlation file
        corrFilename=result(startIndex(i):endIndex(i)+3)
        % Determination of timeshift (min)
        B=load([root_path,'data/',strSubDir,corrFilename]);
        tShift=ceil(7.*RE/mean(A(:,6))/60.);
        tStart=datenum([corrFilename(6:9),'-',corrFilename(10:11),...
            '-',corrFilename(12:13),'T',corrFilename(15:16),...
            ':',corrFilename(17:18)],'yyyy-mm-ddThh:MM:00');
        tEnd=datenum([corrFilename(22:25),'-',corrFilename(26:27),...
            '-',corrFilename(28:29),'T',corrFilename(31:32),':',...
            corrFilename(33:34)],'yyyy-mm-ddThh:MM:00');
        % Time shift
%         tStart=tStart-tShift;
%         tEnd=tEnd-tShift;
        % Get the OMNI parameters
        [mLowOMNI,iLowOMNI]=min(abs(tStart-A(:,1)));        
        [mHighOMNI,iHighOMNI]=min(abs(tEnd-A(:,1)));  
        output=[corrFilename(6:9),'-',corrFilename(10:11),...
            '-',corrFilename(12:13),'T',corrFilename(15:16),...
            ':',corrFilename(17:18),':',corrFilename(19:20),...
            '.000Z/',corrFilename(22:25),'-',...
            corrFilename(26:27),'-',corrFilename(28:29),'T',...
            corrFilename(31:32),':',corrFilename(33:34),...
            ':',corrFilename(35:36),'.000Z & ',...
            num2str(mean(A(iLowOMNI:iHighOMNI,3))),' & ',...
            num2str(mean(A(iLowOMNI:iHighOMNI,4))),' & ',...
            num2str(mean(A(iLowOMNI:iHighOMNI,5))),' & ',...
            num2str(mean(A(iLowOMNI:iHighOMNI,6))),' & ',...
            num2str(mean(A(iLowOMNI:iHighOMNI,7))),' & ',...
            num2str(mean(A(iLowOMNI:iHighOMNI,8))),' & ',...
            num2str(mean(A(iLowOMNI:iHighOMNI,11))),' \\\\'];
        [status3,results3]=unix(['echo "',output,'" >> ',...
            root_path,'data/omni_parameters-gumics-bz',strSuffix,'.dat']);
        
        % Figure in the background   
        p = figure('visible','off');   
        % B plot
        subplot(3,1,1); 
        plot(A(iLowOMNI:iHighOMNI,1),A(iLowOMNI:iHighOMNI,3),'-r');
        hold on;    
        plot(A(iLowOMNI:iHighOMNI,1),A(iLowOMNI:iHighOMNI,4),'-b');
        plot(A(iLowOMNI:iHighOMNI,1),A(iLowOMNI:iHighOMNI,5),'-g');
        hold off;   
        datetick('x','HH:MM'); grid on;    
        axis([tStart tEnd ...
            10*floor(min(min(A(iLowOMNI:iHighOMNI,3:5)/10))) ...
            10*round(max(max(A(iLowOMNI:iHighOMNI,3:5)/10+1)))]);  
        title(['B_x, B_y, B_z, V_x, V_y, V_z and p from OMNI from ',...
            datestr(tStart,'yyyymmdd HH:MM'),' to ',...
            datestr(tEnd,'yyyymmdd HH:MM')]);         
        ylabel('B_x, B_y, B_z [nT]'); 
        
        % V plot
        subplot(3,1,2);        
        plot(A(iLowOMNI:iHighOMNI,1),A(iLowOMNI:iHighOMNI,6),'-r');
        hold on;
        plot(A(iLowOMNI:iHighOMNI,1),A(iLowOMNI:iHighOMNI,7),'-b');
        plot(A(iLowOMNI:iHighOMNI,1),A(iLowOMNI:iHighOMNI,8),'-g');
        hold off;           
        datetick('x','HH:MM'); grid on;   
        axis([tStart tEnd ...
            200*floor(min(min(A(iLowOMNI:iHighOMNI,6:8)/200))) ...
            200*round(max(max(A(iLowOMNI:iHighOMNI,6:8)/200+1)))]);                 
        ylabel('V_x, V_y, V_z [km/s]');

        % p plot
        subplot(3,1,3);    
        plot(A(iLowOMNI:iHighOMNI,1),A(iLowOMNI:iHighOMNI,11),'-k');           
        datetick('x','HH:MM'); grid on;    
        axis([tStart tEnd ...
            5*floor(min(A(iLowOMNI:iHighOMNI,11)/5)) ...
            5*round(max(A(iLowOMNI:iHighOMNI,11)/5+1))]);            
        xlabel('Time [HH:MM]');
%         ylabel('n [cm^{-3}]');    
        ylabel('p [nPa]');    
        
        % Saving result in an eps file
        strTstart=datestr(tStart,'yyyymmdd_HHMMSS');
        strTend=datestr(tEnd,'yyyymmdd_HHMMSS');   
        print(p,'-depsc2',[root_path,'images/',strSubDir,'corr-',...
            strTstart,'_',strTend,'-omni',strSuffix,'.eps']);      
        % Closing the plot box
        close;
    end;          
end