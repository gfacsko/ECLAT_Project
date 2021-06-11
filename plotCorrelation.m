function [ mt, mv ] = plotCorrelation(corrFilename,isOMNI,isBz,is5min,...
    strSuffix) 
%plotCorrelation Comparation of Cluster and OMNIWeb measurements
%   Read the previously created OMNIWeb and Cluster files. 
%   Calculetes the cross correlations and determines the time shift
%   distribution. Plots all functions and creates distributions. 
%
%   corrFilename: The previously created file name
%   isOMNI      : OMNIWeb or GUMICS correlation
%   isBz        : Use B or Bz for calculation
%   is5min   : 5 min / 1 min average
%   strSuffix   : Extra string to distinguish the results
%
%   Developed by Gabor Facsko (facsko.gabor@wigner.hu)
%   Wigner Research Centre for Physics, Budapest, 2014-2021
%
% -----------------------------------------------------------------
%      
    % The correlation hift limit
    limit=60;
    % Default directories
    root_path='/home/facskog/Projectek/Matlab/ECLAT/';
    % Saving the result in the right subdirectory
    strSubDir='OMNI-ClusterSC3-SW/';
    if ((~isOMNI) & (strcmp(strSuffix,'-msh'))),
        strSubDir='GUMICS-ClusterSC3-MSH/';
    end; 
    if ((~isOMNI) & (strcmp(strSuffix,'-sw'))),
        strSubDir='GUMICS-ClusterSC3-SW/';
    end; 
    if ((~isOMNI) & (strcmp(strSuffix,'-msph'))),
        strSubDir='GUMICS-ClusterSC3-MSPH/';
    end; 
    
    % 5 min / 1 min average
    str5min='';
    if (is5min)
        % 5 min average       
        str5min='-5min';
    end;
    
    % Read file
    A=load([root_path,'data/',strSubDir,corrFilename]);
    % Time :(
    fid=fopen ([root_path,'data/',strSubDir,corrFilename], 'r');    
    for i=1:numel(A(:,1))
        strLine=fgetl(fid);
        t=datenum(strLine(1:22),'yyyy-mm-ddTHH:MM:SS.FFF');
        A(i,1)=t;               
    end;
    fclose(fid);
    
    % Correlation
    [mtFgm,mvFgm,cfFgm]=getCrossCorr(A(:,2),A(:,5),limit,isOMNI);
    [mtVCis,mvVCis,cfVCis]=getCrossCorr(A(:,3),A(:,6),limit,isOMNI);
    [mtNCis,mvNCis,cfNCis]=getCrossCorr(A(:,4),A(:,7),limit,isOMNI);
    [mtNEfw,mvNEfw,cfNEfw]=getCrossCorr(A(:,4),A(:,8),limit,isOMNI);
        
    % Figure in the background --------------------------
    p = figure('visible','off');  
    
%     % FGM correlation -----------------------------------
%     subplot(2,4,1);
%     plot((-limit:limit),cfFgm,'-k');    
%     axis square; grid on;    
%     set(gca,'FontSize',10);
%     % If there is intervall to plot
%     if (~sum(isnan(cfFgm))),axis([-limit limit min(cfFgm) 1]);end;
%     ylabel('Correlation');       
%     
%     % CIS HIA Vx correlation
%     subplot(2,3,2);
%     plot((-limit:limit),cfVCis,'-k');     
%     axis square; grid on;
%     set(gca,'FontSize',10);
%     % If there is intervall to plot
%     if (~sum(isnan([cfVCis,cfNCis]))),...
%             axis([-limit limit min(cfVCis) 1]);end;
%     if (isOMNI)
%         bzStr='';
%         if (isBz),bzStr='_z';end;
%         title(['Correlation of B',bzStr,...
%             ' from OMNIWeb and Cluster SC3 from ',...
%             datestr(A(1,1),'yyyymmdd HH:MM'),' to ',...
%             datestr(A(numel(A(:,1)),1),'yyyymmdd HH:MM')]);            
%     else
%         bzStr='';
%         if (isBz),bzStr='_z';end;        
%         title(['\rm \fontsize{8}Correlation of {B_z}, V_x, n_{CIS} and n_{EFW} from GUMICS and Cluster SC3 from ',...
%             datestr(A(1,1),'yyyymmdd HH:MM'),' to ',...
%             datestr(A(numel(A(:,1)),1),'yyyymmdd HH:MM')]);        
%     end;
% %     ylabel('Correlation');    
%     
%     % CIS HIA n correlation
%     subplot(2,3,3);
%     plot((-limit:limit),cfNCis,'-r');
%     hold on;
%     plot((-limit:limit),cfNEfw,'-b');
%     hold off;
%     axis square tight; grid on;  
%     set(gca,'FontSize',10);
%     % If there is intervall to plot
%     if (~sum([isnan(cfNCis),isnan(cfNEfw)]))
%             axis([-limit limit min([cfNCis,cfNEfw]) 1]);
%     end;
% %     ylabel('Correlation');    

    % Scattered plot - Bz
  %  subplot(2,3,4);
subplot(1,3,1);
    plot(A(:,2),A(:,5),'.k','MarkerSize',2);
    if (strcmp(strSuffix,'-sw')) % SW
        axis([-20 20 -20 20]);
        set(gca,'XTick',-20:10:20);
        set(gca,'XTickLabel',{'-20','-10','0','10','20'});
        set(gca,'YTick',-20:10:20);
        set(gca,'YTickLabel',{'-20','-10','0','10','20'});
    end;
    if (strcmp(strSuffix,'-msh')) % MSH
        axis([-60 60 -60 60]);
        set(gca,'XTick',-60:30:60);
        set(gca,'XTickLabel',{'-60','-30','0','30','60'});
        set(gca,'YTick',-60:30:60);
        set(gca,'YTickLabel',{'-60','-30','0','30','60'});
    end;
%       axis([10*floor(min(A(:,2))/10) 10*round(max(A(:,2))/10) ...
%           10*floor(min(A(:,5))/10) 10*round(max(A(:,5))/10)]);  
    axis square;  
    % Set dotted grid lines
    grid on;
    ax = gca;
    ax.GridLineStyle = ':';
    % End of grid line settings
    set(gca,'FontSize',8);
   % xlabel('\fontsize{10}Cluster');
    ylabel('\fontsize{10}GUMICS-4');
    text(0.05,0.9,'\fontsize{8}(a)','Units','Normalized');
    % y=x
    hold on;
    plot([-1500,1500],[-1500,1500],'--g');
    hold off;
    
    % Scattered plot - Vx
%    subplot(2,3,5);
 subplot(1,3,2);
    plot(A(:,3),A(:,6),'.k','MarkerSize',2);
    if (strcmp(strSuffix,'-sw')), % SW
        axis([-800 -200 -800 -200]);
        set(gca,'XTick',-800:200:600);
        set(gca,'XTickLabel',{'-800','-600','-400','-200','0','200'});
        set(gca,'YTick',-800:200:600);
        set(gca,'YTickLabel',{'-800','-600','-400','-200','0','200'});
    end;
    if (strcmp(strSuffix,'-msh')) % MSH
        axis([-600 200 -600 200]);
        set(gca,'XTick',-600:200:600);
        set(gca,'XTickLabel',{'-600','-400','-200','0','200'});
        set(gca,'YTick',-600:200:600);
        set(gca,'YTickLabel',{'-600','-400','-200','0','200'});
    end;
      %axis([50*floor(min(A(:,3))/50) 50*round(max(A(:,3))/50) ...
      %     50*floor(min(A(:,6))/50) 50*round(max(A(:,6))/50)]);  
    axis square;
    % Set dotted grid lines
    grid on;
    ax = gca;
    ax.GridLineStyle = ':';
    % End of grid line settings
    set(gca,'FontSize',8);
    xlabel('\fontsize{10}Cluster');
 %   ylabel('\fontsize{10}GUMICS-4');
    title(['\rm \fontsize{7}B_z, V_x, n_{CIS} and n_{EFW} from GUMICS vs Cluster SC3 from ',...
            datestr(A(1,1),'yyyymmdd HH:MM'),' to ',...
            datestr(A(numel(A(:,1)),1),'yyyymmdd HH:MM')]);
    text(0.05,0.9,'\fontsize{8}(b)','Units','Normalized');
    % y=x
    hold on;
    plot([-1500,1500],[-1500,1500],'--g');
    hold off;
    
    % Scattered plot - nCIS
%    subplot(2,3,6);
subplot(1,3,3);  
    plot(A(:,4),A(:,7),'.r','MarkerSize',1);
    hold on;
    plot(A(:,4),A(:,8),'.b','MarkerSize',1);
    hold off;  
    axis([0 150 0 150]); % SW and MSH
%    axis([0 10*round(max(A(:,4))/10+1) 0 10*round(max([A(:,7);A(:,8)])/10+1)]);  
    axis square;
    % Set dotted grid lines
    grid on;
    ax = gca;
    ax.GridLineStyle = ':';
    % End of grid line settings
    set(gca,'FontSize',8);
%    xlabel('\fontsize{10}Cluster');
%    ylabel('\fontsize{10}GUMICS-4');
    text(0.05,0.9,'\fontsize{8}(c)','Units','Normalized');
    % y=x
    hold on;
    plot([0,1200],[0,1200],'--g');
    hold off; 
    
    % Saving result in an eps file
    strTstart=datestr(A(1,1),'yyyymmdd_HHMMSS');
    strTend=datestr(A(numel(A(:,1)),1),'yyyymmdd_HHMMSS');  
    if (isOMNI)       
        bzStr='';
        if (isBz),bzStr='-bz';end; 
        print(p,'-depsc2',[root_path,'images/',strSubDir,...
            'corr-OMNIWeb-Cluster-',strTstart,'_',strTend,bzStr,'.eps']);
    else
        bzStr='';
        if (isBz),bzStr='-bz';end;       
        print(p,'-depsc2',[root_path,'images/',strSubDir,...
            'corr-GUMICS-Cluster-',strTstart,'_',strTend,bzStr,...
            strSuffix,str5min,'.eps']);
    end;
    
    % Closing the plot box
    close; 
    
    % Return values
    mt = [mtFgm,mtVCis,mtNCis,mtNEfw];
    mv = [mvFgm,mvVCis,mvNCis,mvNEfw];
end
