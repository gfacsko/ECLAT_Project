function [ error ] = plotClusterOrbit( is5min,strSuffix )
%plotClusterOrbit Plot Cluster SC3 orbit used in the study
%   Read cdf files and plot Cluster SC3 orbit in the solar wind. 
% 
%   strSuffix : The type of the data
%
%   Developed by Gabor Facsko (facsko.gabor@wigner.hu), Wigner 
%   Research Centre for Physics, 2017-2021
%----------------------------------------------------------------------
%   
    % Earth radius
    RE=6378.000;
    % Default directories
    root_path='/home/facskog/Projectek/Matlab/ECLAT/';
    data_path = '/home/facskog/QSAS/';
   
    % Read SW file ----------------------------------------------
    fid=fopen ([root_path,'data/cluster_',...
        strSuffix(2:numel(strSuffix)),'.txt'], 'r');
    % Skiping header
	strLine=fgetl(fid);
    tStart=datenum(strLine(1:23),'yyyy-mm-ddTHH:MM:SS.FFF');      
    tEnd=datenum(strLine(26:48),'yyyy-mm-ddTHH:MM:SS.FFF');
    % Temporary Correlation file  
    error=mkCorrInputFile(tStart,tEnd,false,false,is5min,strSuffix);
    isFirst=true;
    while ~feof(fid)
        strLine = fgetl(fid);
        tStart=datenum(strLine(1:23),'yyyy-mm-ddTHH:MM:SS.FFF');      
        tEnd=datenum(strLine(26:48),'yyyy-mm-ddTHH:MM:SS.FFF');       
        % Read Cluster FGM data
        for id=floor(tStart):ceil(tEnd)-1
            cdfFilename=['C3_CP_FGM_SPIN__',datestr(id,'yyyymmdd_HHMMSS_'),...
                 datestr(id+1,'yyyymmdd_HHMMSS'),'_V140305.cdf'];        
            fgmFilename=[data_path,'C3_CP_FGM_SPIN/',cdfFilename];           
            % Converting cells to double --- FGM            
            if (id==floor(tStart))
                fgmCell = cdfread(fgmFilename,'Variable',...
               {['time_tags__C3_CP_FGM_SPIN'],...           
               ['sc_pos_xyz_gse__C3_CP_FGM_SPIN']},...
               'ConvertEpochToDatenum',true);
            else
                fgmCell = [fgmCell;cdfread(fgmFilename,'Variable',...
               {['time_tags__C3_CP_FGM_SPIN'],...           
               ['sc_pos_xyz_gse__C3_CP_FGM_SPIN']},...
               'ConvertEpochToDatenum',true)];
            end;
        end;
        fgm = cell2struct(fgmCell,{'time','fgmPos'},2);
        pos=[fgm.fgmPos]/RE;
        tfgm=[fgm.time];
        % Cut of the array: only the interval remains
        [tiStart,iStart]=min(abs(tfgm-tStart));
        [tiEnd,iEnd]=min(abs(tfgm-tEnd));
        tfgm=tfgm(iStart:iEnd);
        pos=pos(1:3,iStart:iEnd);
        % Save results
        if (isFirst)
            posArray=pos;
            isFirst=false;
        else
            posArray=[posArray,pos];
        end;
	end;
    
%     % Small figure for the QSAS plot
%     if (isSmall)
%         iArray=find((datenum([2002 2 20 10 0 0]) <= timeArray) & ...
%             (datenum([2002 2 20 20 0 0]) >= timeArray));
%         timeArray=timeArray(iArray);
%         posArray=posArray(:,iArray);
%     end;
    
    % Figures in the background --------------------------------------
    p = figure('visible','off');         
    R=20;
    Niono=3.7;
    % Bow-shock model
    Bvec=[5 0 0];
    n=5;
    V=[-400 0 0];
    Babs= sqrt(sum(Bvec.^2))*10^9;%11;    
 	nSW = n/10^6; %5;
    vSW=V/1000;  %[-400,0,0];
    vSWabs=sqrt(sum(vSW.^2))*1000.0;
    % For BS model
    Ca = Babs*10.0^(-9)/sqrt(4.0*pi*10.0^(-7)*nSW*1.67*10.0^(-27))/1000.0;    
    MA = vSWabs/Ca;    
    %  1rst figure
    subplot(2,1,1);
    % Peredo modell.
    a1 = 0.0117-5.18*0.001*MA-3.47*0.0001*MA^2;
    a3 = 0.712+0.044*MA-1.35*0.001*MA^2;
    a4 = 0.3-0.071*MA+3.53*0.001*MA^2;
    a7 = 62.8-2.05*MA+0.079*MA^2;
    a8 = -4.85+1.02*MA-0.048*MA^2;
    a10 = -911.39+23.4*MA-0.86*MA^2;
    % Tsyganenko magnetopauza model.
    tau = R*((1:2000000)/1000000.0-1.);    
    x0 = 5.48;
    a = 70.48;
    sigma = 1.078;
    xxx = x0-a*(1.-sigma*tau);   
    phi = zeros(1,numel(tau));
    yyy = a*sqrt(sigma*sigma-1.)*sqrt(1.-tau.*tau).*cos(phi);
    phi = ones(1,numel(tau))*pi/2;
    zzz = a*sqrt(sigma.*sigma-1.)*sqrt(1.-tau.*tau).*sin(phi);
    ixxx=intersect(find(real(yyy)),find(real(zzz)));
    xxx=xxx(ixxx);
    yyy=yyy(ixxx);
    zzz=zzz(ixxx);
%     xxx=xxx(find(real(yyy)));
%     yyy=yyy(find(real(yyy)));   
    phi = ones(1,numel(tau))*pi/2;      
    % BS position
    xx = R*(((1:200000)/100000.0)-1.);
    B = a4*xx+a8;
    C = a1*xx.^2.+a7*xx+a10;
    D = sqrt(B.^2.-4*C);
    xx = xx(find(real(D)));
    D = D(find(real(D)));
    B = B(find(real(D)));
    xx = xx(find(xx < 50));
    D = D(find(xx < 50));
    B = B(find(xx < 50));      
    % XZ plot ----------------------------------------------------------
    subplot(2,2,1);
%     if (isSmall)
%         plot(posArray(1,:),posArray(3,:),'.r','markersize',3;
%     else
        plot(posArray(1,:),posArray(3,:),'.k','markersize',1);
%    end;
    axis([-R R -R R]); axis square;    
    title('\rm \fontsize{8}XZ GSE plane');
    xlabel('\rm \fontsize{8}X_{GSE} [R_E]');
    ylabel('\rm \fontsize{8}Z_{GSE} [R_E]');       
    text(-18,16,'\fontsize{8}(a)');
    set(gca,'xtick',[-20 -10 0 10 20]);
    set(gca,'ytick',[-20 -10 0 10 20]);
    set(gca,'FontSize',8); set(gca,'LineWidth',1); 
    hold on;
    % Bow shock
    plot(xx,0.5*(-B-D),'--k','LineWidth',1);
    plot(xx,0.5*(-B+D),'--k','LineWidth',1);
    plot([max(xx), max(xx)], 0.5*[max(-B-D), min(-B+D)],...
        '--k','LineWidth',1);

    % Cyrindlic plot calculations -----------------
    zzR=0.5*(-B+D);
    yyR = sqrt(-(a1*xx.^2+a7*xx+a10)/a3);
    xxR = xx(find(real(zzR)));
    yyR = yyR(find(real(zzR)));
    zzR = zzR(find(real(zzR)));
    % Cyrindlic plot calculations -----------------
    
    % BS text
%    text(12.5, 15, 'BS');
    % Magnetopause
    [xmax,ixmax]=max(xxx);
    plot(xxx,yyy,'--k','LineWidth',1); 
    plot(xxx,-yyy,'--k','LineWidth',1);
    plot([xxx(ixmax),xxx(ixmax)],[yyy(ixmax),-yyy(ixmax)],...
        '-k','LineWidth',1);
    % MP text
%    text(2.5, 15, 'MP');
    % The Earth
    rectangle('Position',[-1,-1,2,2],'FaceColor',[0,0,0],'EdgeColor',...
        [0.99 0.99 0.99],'Curvature',[1,1],'LineWidth',1);  
    % Ionospheric domain
    rectangle('Position',[-1,-1,2,2]*Niono,'EdgeColor',...
        [0 0 0],'Curvature',[1,1],'LineWidth',1,'LineStyle',':');  
    hold off;        
    % XY plot ----------------------------------------------------------
    subplot(2,2,3); plot(posArray(1,:),posArray(2,:),'.k','markersize',1); 
    axis([-R R -R R]); axis square; 
    title('\rm \fontsize{8}XY GSE plane');
    xlabel('\rm \fontsize{8}X_{GSE} [R_E]');
    ylabel('\rm \fontsize{8}Y_{GSE} [R_E]');   
    text(-18,16,'\fontsize{8}(c)');
    set(gca,'xtick',[-20 -10 0 10 20]);
    set(gca,'ytick',[-20 -10 0 10 20]);
    set(gca,'FontSize',8); set(gca,'LineWidth',1);      
    hold on;
    xx = R*((1:2000)/1000.0-1.);
    zz = sqrt(-(a1*xx.^2+a7*xx+a10)/a3);
    xx = xx(find(real(zz)));
    zz = zz(find(real(zz)));
%     xx = xx[WHERE(xx lt 50)]
%     D = D[WHERE(xx lt 50)]
    plot(xx,zz,'--k','LineWidth',1);
    plot(xx,-zz,'--k','LineWidth',1);
    plot([max(xx), max(xx)],[-min(zz),min(zz)],...
        '--k','LineWidth',1);
%     % BS text
%     text(15,15,'BS');
    % MP position
%    tau = R*((1:2000000)/1000000.0-1.);
%    phi = ones(1,numel(tau))*pi/2;
%    xxx = x0-a*(1.-sigma.*tau);
%    zzz = a*sqrt(sigma.*sigma-1.)*sqrt(1.-tau.*tau).*sin(phi);
%     xxx=xxx(find(real(zzz)));   
%     zzz=zzz(find(real(zzz)));
    plot(xxx,zzz,'--k','LineWidth',1);
    plot(xxx,-zzz,'--k','LineWidth',1);
    plot([xxx(ixmax),xxx(ixmax)],[zzz(ixmax),-zzz(ixmax)],...
        '--k','LineWidth',1);
%     % MP text
%     text(2.5,15,'MP');   
    % The Earth
    rectangle('Position',[-1,-1,2,2],'FaceColor',[0,0,0],'EdgeColor',...
        [0.99 0.99 0.99],'Curvature',[1,1],'LineWidth',1);      
    % Ionospheric domain
    rectangle('Position',[-1,-1,2,2]*Niono,'EdgeColor',...
        [0 0 0],'Curvature',[1,1],'LineWidth',1,'LineStyle',':');  
    hold off;
   % YZ plot ----------------------------------------------------------
    subplot(2,2,2);plot(posArray(2,:),posArray(3,:),'.k','markersize',1); 
    axis([-R R -R R]); axis square; 
    title('\rm\fontsize{8}YZ GSE plane');
    xlabel('\rm\fontsize{8}Y_{GSE} [R_E]');
    ylabel('\rm\fontsize{8}Z_{GSE} [R_E]');  
    text(-18,16,'\fontsize{8}(b)'); 
    set(gca,'xtick',[-20 -10 0 10 20]);
    set(gca,'ytick',[-20 -10 0 10 20]); 
    set(gca,'FontSize',8); set(gca,'LineWidth',1);
    hold on;   
    % False MP    
    rectangle('Position',[-1,-1,2,2]*15,'EdgeColor',...
        [0 0 0],'Curvature',[1,1],'LineWidth',1,'LineStyle','--');  
    % The Earth
    rectangle('Position',[-1,-1,2,2],'FaceColor',[0,0,0],'EdgeColor',...
        [0.99 0.99 0.99],'Curvature',[1,1],'LineWidth',1);      
    % Ionospheric domain
    rectangle('Position',[-1,-1,2,2]*Niono,'EdgeColor',...
        [0 0 0],'Curvature',[1,1],'LineWidth',1,'LineStyle',':');  
    hold off;
    % Cylindrical plot ----------------------------------------------------------
    subplot(2,2,4);
    plot(posArray(1,:),sqrt(posArray(2,:).^2.+posArray(3,:).^2),'.k','markersize',1); 
    axis([-R R 0 R]); axis square; % axis([0 R 0 R]);
    title('\rm\fontsize{8}Cylindrical projection');
    xlabel('\rm\fontsize{8}X_{GSE} [R_E]');
    ylabel('\rm\fontsize{8}(Y_{GSE}^2+Z_{GSE}^2)^{0.5} [R_{E}]');
    text(-18,18,'\rm\fontsize{8}(d)'); %1,16 % text(17,18,'\fontsize{12}(d)'); %1,16
    set(gca,'xtick',[-20 -10 0 10 20]); %set(gca,'xtick',[0 5 10 15 20]);
    set(gca,'ytick',[0 5 10 15 20]);
    set(gca,'FontSize',8); set(gca,'LineWidth',1);  
    hold on;   
    % MP    
    plot(xxx,sqrt(yyy.^2+zzz.^2),'--k','LineWidth',1);
    plot([max(xxx),max(xxx)],[0,min(sqrt(yyy.^2+zzz.^2))],...
        '--k','LineWidth',1);
    % BS
    plot(xxR,sqrt(yyR.^2+zzR.^2),'--k','LineWidth',1);
    plot([max(xxR),max(xxR)],[0,min(sqrt(yyR.^2+zzR.^2))],...
        '--k','LineWidth',1);
    % The Earth
    rectangle('Position',[-1,-1,2,2],'FaceColor',[0,0,0],'EdgeColor',...
        [0.99 0.99 0.99],'Curvature',[1,1],'LineWidth',1);      
    % Ionospheric domain
    rectangle('Position',[-1,-1,2,2]*Niono,'EdgeColor',...
        [0 0 0],'Curvature',[1,1],'LineWidth',1,'LineStyle',':');  
    hold off;
    % Save image ---------------------------------------------------------
%     if (isSmall)
%         print(p,'-depsc',[root_path,'images/cluster_sc3_orbit-small.eps']);   
%     else
        print(p,'-depsc',[root_path,'images/cluster_sc3_orbit',...
            strSuffix,'.eps']);   
%     end;
    % Closing the plot box
   close;    
end

