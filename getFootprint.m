function [ fpStatus,fpPos,fpSMPos,fpTsyStatus,fpTsyPos,fpTsySMPos,param ] = ...
    getFootprint( mstateFilename, scPos)
global GEOPACK1;
%getFootprint Determine footprint of given position. 
%   CAA product, determine footprint from simulation data from a given
%   location. Create an image file to check the method, as well as the
%   position of the footprint in GSE. A status variable describes what
%   footprint are given: both, north, south. The hcmap is used in thesqrt(sum(fpTsyPos(1:3).^2))
%   magnetospheric domain. 
%
%   mstateFilename: Magnetospheric filename
%   scPos         : Start of raytracing
%   result        : 0; No footprint, 1; Southern hemisphere, 2; Northern
%                   hemispehere, 3; Both hemispheres
%   fpPos         : 6 position variable in GSE
%   fpSMPos       : 6 position variable in SM
%   fpTsyPos      : Tsyganenko 6 position variable in GSE
%   fpTsySMPos    : Tsyganenko 6 position variable in SM
%   param         : upstream parameters: n, T, Vx, Vy, Vz, Bx, By, Bz
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2013
%
% -----------------------------------------------------------------
%
    % Earth radius
    RE=6380000;
    % Ionospheric domain
    Niono=3.7;
    step_size=100000;
    % "Surface": 100km 
    Rend=RE+step_size;
    % Raytracing boundaries
    hcxmax=32;
    hcxmin=64;%-226;   
    hcymax=64;
    hcymin=-hcymax;
    hczmax=hcymax; 
    hczmin=-hczmax;  

    % Data path
%    sim_path='/home/facsko/stornext/';  
    sim_path='/media/My\ Book/ECLAT/dynamic\ runs/';
    data_path='/home/gfacsko/QSAS/';
    root_path='/home/gfacsko/Projects/Matlab/ECLAT/';    
    
    % MATLAB path
    path(path,'/home/gfacsko/Projects/Matlab/geopack'); 
    
    % Default values
    fpStatus = 0;
    fpTsyStatus = 0;
    fpTsyPos=[-1,-1,-1,-1,-1,-1];
    fpTsySMPos=[-1,-1,-1,-1,-1,-1];
    fpPos1=scPos*1000;
    fpPos2=fpPos1;
    % This is included into all filename
    strDate=mstateFilename(strfind(mstateFilename,'/')+7:numel(mstateFilename)-3);
    
    % Initialisation of Tsyganenko model
    GEOPACK_RECALC(str2num(strDate(1:4)),...
        floor(date2doy(datenum([str2num(strDate(1:4)) str2num(strDate(5:6)) ...
        str2num(strDate(7:8)) str2num(strDate(10:11)) ...
        str2num(strDate(12:13)) 0]))),str2num(strDate(10:11)),...
        str2num(strDate(12:13)),0);

     % Read upstream parameters
    [rho,n,T,V,Bvec]=getUpstream(mstateFilename);        
%     rho=-1;
%     n=-1;
%     T=-1;
%     V=[-1,-1,-1];
%     Bvec=[-1,-1,-1];

    % Read Dst index
    Dst=getDst(datenum([str2num(strDate(1:4)) str2num(strDate(5:6)) ...
        str2num(strDate(7:8)) str2num(strDate(10:11)) 0 0])); 

    % Raytracing forward until R<Niono*RE by Pekka's code
    fpPosArray1=fpPos1;     
    result=[num2str(fpPos1(1)/RE),' ',num2str(fpPos1(2)/RE),' ',...
        num2str(fpPos1(3)/RE),' 0 0 0'];
    if (sqrt(sum(fpPos1.^2))>Niono*RE)
        % GLIBCXX problem
        MatlabPath = getenv('LD_LIBRARY_PATH');
        setenv('LD_LIBRARY_PATH',getenv('PATH'));
        [status,result]=unix(['echo ',num2str(fpPos1/RE),...
            '|/home/gfacsko/gumics/appl/gumics/hcmap -shell ',...
            num2str(Niono),' -xyz -direction plus -vftype B ',...
            sim_path,mstateFilename]);  
        % GLIBCXX problem
        setenv('LD_LIBRARY_PATH',MatlabPath);
    end;
 
    % Raytracing in the ionospheric domain
    if (numel(strfind(result,'0 0 0 0 0 0'))==0)       
        % Only valid positions are saved
        strLimit=strfind(result,' ');
        fpPos1=[str2num(result(1:strLimit(1))),...
            str2num(result(strLimit(1):strLimit(2))),...
            str2num(result(strLimit(2):strLimit(3)))]*RE;
        fpPosArray1=[fpPosArray1;fpPos1]; 
        % Conversion to SM
        [xGSM,yGSM,zGSM]=GEOPACK_GSMGSE(fpPos1(1),fpPos1(2),fpPos1(3),-1);
        [xSM1,ySM1,zSM1]=GEOPACK_SMGSM(xGSM,yGSM,zGSM,-1);    
        % Trace to North if it is on the Northern hemisphere at the domain 
        % boundary, otherwise to the Southern hemisphere
        traceDirection=1;
        if (zSM1<0),traceDirection=-1;end; 
        % Dipole field
        k0 = 8e15;
        % Bx = -3 * k0 * x * z / (x**2 + y**2 + z**2)**(5.0/2.0)
        % By = -3 * k0 * y * z / (x**2 + y**2 + z**2)**(5.0/2.0)
        % Bz = -3 * k0 * (z**2 - (x**2 + y**2 + z**2) / 3.0) / (x**2 + y**2 + z**2)**(5.0/2.0)
        % Bs = step_size / sqrt(Bx**2 + By**2 + Bz**2)
        while (sqrt(xSM1^2+ySM1^2+zSM1^2)>Rend+step_size)                               
            nB=-3*k0*[xSM1*zSM1,ySM1*zSM1,zSM1^2-(xSM1^2+ySM1^2+zSM1^2)/3.0]/...
                (xSM1^2+ySM1^2+zSM1^2)^(5/2);
            step=step_size/sqrt(nB(1)^2+nB(2)^2+nB(3)^2);
            % New position along the field line
            xSM1=xSM1+traceDirection*nB(1)*step;
            ySM1=ySM1+traceDirection*nB(2)*step;
            zSM1=zSM1+traceDirection*nB(3)*step;
            % Convert to GSE
            [xGSM,yGSM,zGSM]=GEOPACK_SMGSM(xSM1,ySM1,zSM1,1);
            [xGSE,yGSE,zGSE]=GEOPACK_GSMGSE(xGSM,yGSM,zGSM,1);
            fpPos1=[xGSE,yGSE,zGSE];
            % Save for visualisation
            fpPosArray1=[fpPosArray1;fpPos1];        
        end;
        % Set fpStatus
        fpStatus=fpStatus+1;       
    end;

    % Raytracing backward until R<Niono*RE by Pekka's code
    fpPosArray2=fpPos2;   
    result=[num2str(fpPos2(1)/RE),' ',num2str(fpPos2(2)/RE),' ',...
        num2str(fpPos2(3)/RE),' 0 0 0'];
    if (sqrt(sum(fpPos2.^2))>Niono*RE)
        % GLIBCXX problem
        MatlabPath = getenv('LD_LIBRARY_PATH');
        setenv('LD_LIBRARY_PATH',getenv('PATH'));
        [status,result]=unix(['echo ',num2str(fpPos2/RE),...
            '|/home/gfacsko/gumics/appl/gumics/hcmap -shell ',...
            num2str(Niono),' -xyz -direction minus -vftype B ',...
            sim_path,mstateFilename]);    
        % GLIBCXX problem
        setenv('LD_LIBRARY_PATH',MatlabPath);
    end;
    
    % Raytracing in the ionospheric domain
    if (numel(strfind(result,'0 0 0 0 0 0'))==0)       
        % Only valid positions are saved
        strLimit=strfind(result,' ');
        fpPos2=[str2num(result(1:strLimit(1))),...
            str2num(result(strLimit(1):strLimit(2))),...
            str2num(result(strLimit(2):strLimit(3)))]*RE;
        fpPosArray2=[fpPosArray2;fpPos2]; 
        % Conversion to SM
        [xGSM,yGSM,zGSM]=GEOPACK_GSMGSE(fpPos2(1),fpPos2(2),fpPos2(3),-1);
        [xSM2,ySM2,zSM2]=GEOPACK_SMGSM(xGSM,yGSM,zGSM,-1);    
        % Trace to North if it is on the Northern hemisphere at the domain 
        % boundary, otherwise to the Southern hemisphere
        traceDirection=1;
        if (zSM2<0),traceDirection=-1;end; 
        % Dipole field
        k0 = 8e15;
        % Bx = -3 * k0 * x * z / (x**2 + y**2 + z**2)**(5.0/2.0)
        % By = -3 * k0 * y * z / (x**2 + y**2 + z**2)**(5.0/2.0)
        % Bz = -3 * k0 * (z**2 - (x**2 + y**2 + z**2) / 3.0) / (x**2 + y**2 + z**2)**(5.0/2.0)
        % Bs = step_size / sqrt(Bx**2 + By**2 + Bz**2)
        while (sqrt(xSM2^2+ySM2^2+zSM2^2)>Rend+step_size)                   
            nB=-3*k0*[xSM2*zSM2,ySM2*zSM2,zSM2^2-(xSM2^2+ySM2^2+zSM2^2)/3.0]/...
                (xSM2^2+ySM2^2+zSM2^2)^(5/2);
            step=step_size/sqrt(nB(1)^2+nB(2)^2+nB(3)^2);
            % New position along the field linesqrt(sum(fpTsyPos(1:3).^2))
            xSM2=xSM2+traceDirection*nB(1)*step;
            ySM2=ySM2+traceDirection*nB(2)*step;
            zSM2=zSM2+traceDirection*nB(3)*step;
            % Convert to GSE
            [xGSM,yGSM,zGSM]=GEOPACK_SMGSM(xSM2,ySM2,zSM2,1);
            [xGSE,yGSE,zGSE]=GEOPACK_GSMGSE(xGSM,yGSM,zGSM,1);
            fpPos2=[xGSE,yGSE,zGSE];
            % Save for visualisation
            fpPosArray2=[fpPosArray2;fpPos2];        
        end;
        fpStatus=fpStatus+2;       
    end;

    % Tsyganenko model ------------------------------------------------   
% Initialisation was moved to the top of the code
    GEOPACK_RECALC(str2num(strDate(1:4)),...  
            floor(date2doy(datenum([str2num(strDate(1:4)) str2num(strDate(5:6)) ...
            str2num(strDate(7:8)) str2num(strDate(10:11)) ...
            str2num(strDate(12:13)) 0]))),str2num(strDate(10:11)),...
            str2num(strDate(12:13)),0);
    [xGSM,yGSM,zGSM]=GEOPACK_GSMGSE(scPos(1)*1000/RE,scPos(2)*1000/RE,...
        scPos(3)*1000/RE,-1);   
    % Model parameters: solar wind ram pressure, nPa
    PARMOD(1) = rho*(V(1)^2+V(2)^2+V(3)^2)*10^9; %3; 
    % Get Dst (nT) from own functionn (see above)
    PARMOD(2) = Dst;% -15; 
    % By, GSM, nT
    PARMOD(3) = Bvec(2)*10^9;  %7; 
    % Bz, GSM, nT
    PARMOD(4) = Bvec(3)*10^9; %-1; 
    % Raytracing by Tsyganenko model - backward (this gives the same
    % result like forward by Pekka's code)
    [XF1,YF1,ZF1,XX,YY,ZZ,L] = GEOPACK_TRACE(xGSM,yGSM,zGSM,-1,abs(hcxmin),...
        Rend/RE,0,PARMOD,'T96','GEOPACK_IGRF_GSM');    
    fpTsyPosArray1=[];
    for i=1:L
        [xGSE,yGSE,zGSE]=GEOPACK_GSMGSE(XX(i),YY(i),ZZ(i),1);       
        fpTsyPosArray1=[fpTsyPosArray1;xGSE,yGSE,zGSE];
    end;    
    % Result in SM for comparison
    [xTsySM1,yTsySM1,zTsySM1]=GEOPACK_SMGSM(XF1,YF1,ZF1,-1);   
    % Status indicator - it must terminate in the ionospheric domain
    if (sqrt(sum(XF1^2+YF1^2+ZF1^2))<Niono),fpTsyStatus=fpTsyStatus+1;end;
    % Raytracing by Tsyganenko model - forward
    [XF2,YF2,ZF2,XX,YY,ZZ,L] = GEOPACK_TRACE(xGSM,yGSM,zGSM,1,abs(hcxmin),...
        Rend/RE,0,PARMOD,'T96','GEOPACK_IGRF_GSM');
    fpTsyPosArray2=[];
    for i=1:L
        [xGSE,yGSE,zGSE]=GEOPACK_GSMGSE(XX(i),YY(i),ZZ(i),1);          
        fpTsyPosArray2=[fpTsyPosArray2;xGSE,yGSE,zGSE];
    end;
    % Result in SM for comparison
    [xTsySM2,yTsySM2,zTsySM2]=GEOPACK_SMGSM(XF2,YF2,ZF2,-1);
    % Status indicator - it must terminate in the ionospheric domain
    if (sqrt(sum(XF2^2+YF2^2+ZF2^2))<Niono),fpTsyStatus=fpTsyStatus+2;end;

    % -----------------------------------------------------------------

    % Figure in the background   
    p = figure('visible','off');  
    % Limit of plot (MP is not good after X_GSE=-50RE)
    R=10;%20;
    % Bow-shock model - 20020220 09:04
    Babs= sqrt(sum(Bvec.^2))*10^9;%11;    
 	nSW = n/10^6; %5;
    vSW=V/1000;  %[-400,0,0];
    vSWabs=sqrt(sum(vSW.^2))*1000.0;
%    vSW=vSW/vSWabs;
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
    phi = zeros(1,numel(tau));
    x0 = 5.48;
    a = 70.48;
    sigma = 1.078;
    xxx = x0-a*(1.-sigma*tau);
    yyy = a*sqrt(sigma*sigma-1.)*sqrt(1.-tau.*tau).*cos(phi);
    xxx=xxx(find(real(yyy)));
    yyy=yyy(find(real(yyy)));
    phi = ones(1,numel(tau))*pi/2;
    % 1rst figure
    plot([scPos(1),scPos(1)]*1000/RE, [scPos(2),scPos(2)]*1000/RE,'+k',...
        'LineWidth',2);
    hold on;   
    set(gca,'LineWidth',2);
%    set(gca,'FontWeight','bold');
    set(gca,'FontSize',15);
    axis equal tight;
    axis([-R R -R R]);%axis([-1.5*R 0.5*R -0.5*R 1.5*R]);
    set(gca,'XTick',-10:5:10);    
    set(gca,'XTickLabel',{'-10','-5','0','5','10'});
%     set(gca,'XTick',-15:5:5);    
%     set(gca,'XTickLabel',{'-15','-10','-5','0','5'}); 
    set(gca,'YTick',-10:5:10);
    set(gca,'YTickLabel',{'-10','-5','0','5','10'});
%     set(gca,'YTick',-5:5:15);
%     set(gca,'YTickLabel',{'-15','-10','-5','0','5'});
    ylabel('\fontsize{20}Y[R_E]'); 
    xlabel('\fontsize{20}X[R_E]');   
    title(['\fontsize{13}',strDate(1:8),' ',strDate(10:11),':',strDate(12:13),' (UT)']);
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
    plot(xx,0.5*(-B-D),'-k','LineWidth',2);
    plot(xx,0.5*(-B+D),'-k','LineWidth',2);
    plot([max(xx), max(xx)], 0.5*[max(-B-D), min(-B+D)],'-k',...
        'LineWidth',2);
    % BS text
%    text(12.5, 15, '\fontsize{15}BS');
    % Magnetopause
    [xmax,ixmax]=max(xxx);
    plot(xxx,yyy,'-k','LineWidth',2); 
    plot(xxx,-yyy,'-k','LineWidth',2);
    plot([xxx(ixmax),xxx(ixmax)],[yyy(ixmax),-yyy(ixmax)],'-k',...
        'LineWidth',2);
    % MP text
%    text(2.5, 15, '\fontsize{15}MP');
    % The Earth
    rectangle('Position',[-1,-1,2,2],'FaceColor',[0,0,0],'EdgeColor',...
        [0.99 0.99 0.99],'Curvature',[1,1],'LineWidth',0.5);  
    % Ionospheric domain
    rectangle('Position',[-1,-1,2,2]*Niono,'EdgeColor',...
        [0 0 0],'Curvature',[1,1],'LineWidth',1,'LineStyle',':');     
    % Tsyganenko trace
    plot(fpTsyPosArray1(:,1),fpTsyPosArray1(:,2),'-k','LineWidth',2);
    plot([fpTsyPosArray1(1,1),fpTsyPosArray2(1,1)],...
        [fpTsyPosArray1(1,2),fpTsyPosArray2(1,2)],'-k','LineWidth',2);
    plot(fpTsyPosArray2(:,1),fpTsyPosArray2(:,2),'-k','LineWidth',2);
    % Raytracing by Pekka
    plot(fpPosArray1(:,1)/RE,fpPosArray1(:,2)/RE,'.r','MarkerSize',5);
    plot([fpPosArray1(1,1),fpPosArray2(1,1)]/RE,...
        [fpPosArray1(1,2),fpPosArray2(1,2)]/RE,'.r','MarkerSize',5);
    plot(fpPosArray2(:,1)/RE,fpPosArray2(:,2)/RE,'.r','MarkerSize',5);
    hold off;
    % 2nd figure ----------------------------------------------------------
    subplot(2,1,2);
    plot([scPos(1),scPos(1)]*1000/RE, [scPos(3),scPos(3)]*1000/RE,'+k',...
        'LineWidth',2);    
    hold on;
    set(gca,'LineWidth',2);  
%    set(gca,'FontWeight','bold');
    set(gca,'FontSize',15); 
    axis equal tight;   
    axis([-R R -R R]);%axis([-1.5*R 0.5*R -R R]);            
    set(gca,'XTick',-10:5:10);    
    set(gca,'XTickLabel',{'-10','-5','0','5','10'});
%     set(gca,'XTick',-15:5:5);    
%     set(gca,'XTickLabel',{'-15','-10','-5','0','5'}); 
    set(gca,'YTick',-10:5:10);
    set(gca,'YTickLabel',{'-10','-5','0','5','10'});
%     set(gca,'YTick',-10:5:10);
%     set(gca,'YTickLabel',{'-10','-5','0','5','10'});
    ylabel('\fontsize{20}Z[R_E]'); 
    xlabel('\fontsize{20}X[R_E]');        
    xx = R*((1:2000)/1000.0-1.);
    zz = sqrt(-(a1*xx.^2+a7*xx+a10)/a3);
    xx = xx(find(real(zz)));
    zz = zz(find(real(zz)));
%     xx = xx[WHERE(xx lt 50)]
%     D = D[WHERE(xx lt 50)]
    plot(xx,zz,'-k','LineWidth',2);
    plot(xx,-zz,'-k','LineWidth',2);
    plot([max(xx), max(xx)],[-min(zz),min(zz)],'-k','LineWidth',2);
    % BS text
%    text(15,15,'\fontsize{15}BS');
    % MP position
    tau = R*((1:2000000)/1000000.0-1.);
    phi = ones(1,numel(tau))*pi/2;
    xxx = x0-a*(1.-sigma.*tau);
    zzz = a*sqrt(sigma.*sigma-1.)*sqrt(1.-tau.*tau).*sin(phi);
    xxx=xxx(find(real(zzz)));
    zzz=zzz(find(real(zzz)));
    plot(xxx,zzz,'-k','LineWidth',2);
    plot(xxx,-zzz,'-k','LineWidth',2);
    plot([xxx(ixmax),xxx(ixmax)],[zzz(ixmax),-zzz(ixmax)],'-k','LineWidth',2);
    % MP text
%    text(2.5,15,'\fontsize{15}MP');   
    % The Earth
    rectangle('Position',[-1,-1,2,2],'FaceColor',[0,0,0],'EdgeColor',...
        [0.99 0.99 0.99],'Curvature',[1,1],'LineWidth',0.5);      
    % Ionospheric domain
    rectangle('Position',[-1,-1,2,2]*Niono,'EdgeColor',...
        [0 0 0],'Curvature',[1,1],'LineWidth',1,'LineStyle',':');    
    % Tsyganenko
    plot(fpTsyPosArray1(:,1),fpTsyPosArray1(:,3),'-k','LineWidth',2);
    plot([fpTsyPosArray1(1,1),fpTsyPosArray2(1,1)],...
        [fpTsyPosArray1(1,3),fpTsyPosArray2(1,3)],'-k','LineWidth',2);
    plot(fpTsyPosArray2(:,1),fpTsyPosArray2(:,3),'-k','LineWidth',2);
    % Raytracing
    plot(fpPosArray1(:,1)/RE,fpPosArray1(:,3)/RE,'.r','MarkerSize',5);
    plot([fpPosArray1(1,1),fpPosArray2(1,1)]/RE,...
        [fpPosArray1(1,3),fpPosArray2(1,3)]/RE,'.r','MarkerSize',5);
    plot(fpPosArray2(:,1)/RE,fpPosArray2(:,3)/RE,'.r','MarkerSize',5);
    hold off;
    
    % Saving result in an eps, png and jpg files
    print(p,'-depsc2',[root_path,'images/footprint-',strDate,'.eps']);
    print(p,'-dpng',[root_path,'images/footprint-',strDate,'.png']);
    print(p,'-djpeg',[root_path,'images/footprint-',strDate,'.jpg']); 
    % Closing the plot box
    close;

    % Finalization
    param=[n/10^6,T,V/1000,Bvec*10^9];
    % GUMICS results
    switch fpStatus
        case 0
            fpPos=[-1,-1,-1,-1,-1,-1];
            fpSMPos=[-1,-1,-1,-1,-1,-1];
        case 1
            fpPos=[fpPos1/RE,-1,-1,-1];
            fpSMPos=[xSM1/RE,ySM1/RE,zSM1/RE,-1,-1,-1];
        case 2
            fpPos=[-1,-1,-1,fpPos2/RE];
            fpSMPos=[-1,-1,-1,xSM2/RE,ySM2/RE,zSM2/RE];
        case 3
            fpPos=[fpPos1,fpPos2]/RE;     
            fpSMPos=[xSM1,ySM1,zSM1,xSM2,ySM2,zSM2]/RE;
    end;
%     % Tsyganenko results
%     switch fpTsyStatus
%         case 0
%             fpTsyPos=[-1,-1,-1,-1,-1,-1];
%             fpTsySMPos=[-1,-1,-1,-1,-1,-1];
%         case 1
%             fpTsyPos=[XF1,YF1,ZF1,-1,-1,-1];
%             fpTsySMPos=[xTsySM1,yTsySM1,zTsySM1,-1,-1,-1];
%         case 2
%             fpTsyPos=[-1,-1,-1,XF2,YF2,ZF2];
%             fpTsySMPos=[-1,-1,-1,xTsySM2,yTsySM2,zTsySM2];
%         case 3
%             fpTsyPos=[XF1,YF1,ZF1,XF2,YF2,ZF2];     
%             fpTsySMPos=[xTsySM1,yTsySM1,zTsySM1,xTsySM2,yTsySM2,zTsySM2];
%     end;
    % End of finalization 
end

