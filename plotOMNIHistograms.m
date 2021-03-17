function [ error ] = plotOMNIHistograms(strSuffix) 
%plotOMNIHistograms Analysis of the upstream solar wind data. 
%   Histograms of the OMNI data to investigate when the GUMICS4 provides
%   wrong results. The histogram of the original OMNI solar wind data for
%   the simulated year is overplotted these plot.
%
%   strSuffix : Extra string to distinguish the results
%
%   Developed by Gabor Facsko (facsko.gabor@wigner.hu)
%   Rhea Systems GmbH for European Space Agency, 2014-2021
%
% -----------------------------------------------------------------
%    
    error=0;
    % Default directories
    root_path='/home/facskog/Projectek/Matlab/ECLAT/';
    % OMNI data files path
    omni_path='/home/facskog/OMNIWeb/';
    % Input file
    omniFilename='omni_min_20020129_20030202.dat';
    
    % Read OMNI solar wind data for the 1-year
    A=load([omni_path,omniFilename]);
    
    % Read and process file    
    [status,result]=unix(['echo $(cut -d\& -f2 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);
    omniBx=str2num(result);
    [status,result]=unix(['echo $(cut -d\& -f3 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);
    omniBy=str2num(result);
    [status,result]=unix(['echo $(cut -d\& -f4 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);
    omniBz=str2num(result);
    
    [status,result]=unix(['echo $(cut -d\& -f5 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);
    omniVx=str2num(result);
    [status,result]=unix(['echo $(cut -d\& -f6 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);
    omniVy=str2num(result);
    [status,result]=unix(['echo $(cut -d\& -f7 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);
    omniVz=str2num(result);
    
    [status,result]=unix(['echo $(cut -d\& -f8 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);
    omniP=str2num(result);
    
    [status,result]=unix(['echo $(cut -d\& -f9 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);    
    boolBz=(result(sort([strfind(result,'y'),strfind(result,'n')]))=='y');
    [status,result]=unix(['echo $(cut -d\& -f10 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);    
    boolVx=(result(sort([strfind(result,'y'),strfind(result,'n')]))=='y');    
    [status,result]=unix(['echo $(cut -d\& -f11 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);    
    boolNCIS=(result(sort([strfind(result,'y'),strfind(result,'n')]))=='y');
    [status,result]=unix(['echo $(cut -d\& -f12 ',root_path,...
        'data/omni_parameters-gumics-bz',strSuffix,'.dat)']);    
    boolNEFW=(result(sort([strfind(result,'y'),strfind(result,'n')]))=='y');
    
    % The width of the bars
    barWidth = 1;
    % The width of the OMNI bars is cBarWidth * barWidth
    cBarWidth = 0.8;
          
    % B figure in the background  --------------------------------------
    pb = figure('visible','off','PaperOrientation','portrait');   
    % Coefficiens histogram - Bx   
    subplot(4,3,1); 
    Svc=-10:5:10;    
    Snc=histc(omniBx(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');         
    % Bx OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,5),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');    
    hold off;
    title('\rm\fontsize{10}B_{x} from OMNIWeb');
    ylabel('\fontsize{10}B_{z}');   
    text(0.05,0.8,'(a)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,2);    
    Snc=histc(omniBy(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');    
    % By OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,6),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');   
    hold off;
    title('\rm\fontsize{10}B_{y} from OMNIWeb');
    set(gca,'YLim',[0 100],'Layer','top');    
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    text(0.05,0.8,'(b)','Units','Normalized');
    
    subplot(4,3,3);    
    Snc=histc(omniBz(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');  
    % Bz OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,7),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');      
    hold off;
    title('\rm\fontsize{10}B_{z} from OMNIWeb');
    text(0.05,0.8,'(c)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,4);
    Snc=histc(omniBx(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');    
    % Bx OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,5),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');    
    hold off;
    text(0.05,0.8,'(d)','Units','Normalized');
    %title('\fontsize{10}V_{x} from OMNIWeb');
    ylabel('\fontsize{10}V_{x}');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,5);    
    Snc=histc(omniBy(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w'); 
    % By OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,6),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');   
    hold off;
    %title('\fontsize{10}V_{y} from OMNIWeb');
    text(0.05,0.8,'(e)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,6);      
    Snc=histc(omniBz(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');       
    % Bz OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,7),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');      
    hold off;
    %title('\fontsize{10}V_{z} from OMNIWeb');
    text(0.05,0.8,'(f)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,7);     
    Snc=histc(omniBx(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');
    % Bx OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,5),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');    
    hold off;
    %title('\fontsize{10}V_{x} from OMNIWeb');
    ylabel('\fontsize{10}n_{CIS}');
    text(0.05,0.8,'(g)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,8);    
    Snc=histc(omniBy(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');       
    % By OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,6),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');   
    hold off;
    %title('\fontsize{10}V_{y} from OMNIWeb');
    text(0.05,0.8,'(h)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,9);      
    Snc=histc(omniBz(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');       
    % Bz OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,7),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');      
    hold off;
    %title('\fontsize{10}V_{z} from OMNIWeb');
    text(0.05,0.8,'(i)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,10);    
    Snc=histc(omniBx(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');  
    % Bx OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,5),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');    
    hold off;
    %title('\fontsize{10}V_{x} from OMNIWeb');    
    xlabel('\fontsize{10}B_{x} [nT]');
    ylabel('\fontsize{10}n_{EFW}');
    text(0.05,0.8,'(j)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,11);    
    Snc=histc(omniBy(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');     
    % By OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,6),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');   
    hold off;
    %title('\fontsize{10}V_{y} from OMNIWeb');
    xlabel('\fontsize{10}B_{y} [nT]');
    text(0.05,0.8,'(k)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,12);     
    Snc=histc(omniBz(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');       
    % Bz OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,7),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');      
    hold off;
    %title('\fontsize{10}V_{z} from OMNIWeb');
    xlabel('\fontsize{10}B_{z} [nT]');
    text(0.05,0.8,'(l)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    % Saving result in an eps file   ------------------
    print(pb,'-depsc2',[root_path,...
        'images/omni_parameters-gumics-bz_b-histograms',strSuffix,'.eps']);
    
    % Closing the plot box
    close;  
    
    % V figure in the background  --------------------------------------
    pv = figure('visible','off','PaperOrientation','portrait');   
    
    % The width of the OMNI 1-year bars
    cBarWidth = 0.4;
    
    % Coefficiens histogram - Bx   
    subplot(4,3,1); 
    Svc=-600:50:200;    
    Snc=histc(omniVx(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');  
    % Vx OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,8),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r'); 
    hold off;
    title('\rm\fontsize{10}V_{x} from OMNIWeb');
    ylabel('\fontsize{10}B_{z}');
    text(0.05,0.8,'(a)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10);   
    
    subplot(4,3,2);    
    Snc=histc(omniVy(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');   
    % Vy OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,9),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');       
    hold off;
    title('\rm\fontsize{10}V_{y} from OMNIWeb');
    text(0.05,0.8,'(b)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10); 
    
    subplot(4,3,3);    
    Snc=histc(omniVz(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');       
    % Vz OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,10),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');     
    hold off;
    title('\rm\fontsize{10}V_{z} from OMNIWeb');
    text(0.05,0.8,'(c)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10); 
    
    subplot(4,3,4);
    Snc=histc(omniVx(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');       
    % Vx OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,8),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r'); 
    hold off;
    %title('\fontsize{10}V_{x} from OMNIWeb');
    ylabel('\fontsize{10}V_{x}');
    text(0.05,0.8,'(d)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10);   
    
    subplot(4,3,5);    
    Snc=histc(omniVy(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');           
    % Vy OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,9),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');       
    hold off;
    %title('\fontsize{10}V_{y} from OMNIWeb');
    text(-550, 80,'(e)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10); 
    
    subplot(4,3,6);      
    Snc=histc(omniVz(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');       
    % Vz OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,10),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');     
    hold off;
    %title('\fontsize{10}V_{z} from OMNIWeb');
    text(0.05,0.8,'(f)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10); 
    
    subplot(4,3,7);     
    Snc=histc(omniVx(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');    
    % Vx OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,8),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r'); 
    hold off;
    %title('\fontsize{10}V_{x} from OMNIWeb');
    ylabel('\fontsize{10}n_{CIS}');
    text(0.05,0.8,'(g)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10);   
    
    subplot(4,3,8);    
    Snc=histc(omniVy(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');        
    % Vy OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,9),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');       
    hold off;
    %title('\fontsize{10}V_{y} from OMNIWeb');
    text(0.05,0.8,'(h)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10); 
    
    subplot(4,3,9);      
    Snc=histc(omniVz(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');     
    % Vz OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,10),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');     
    hold off;
    %title('\fontsize{10}V_{z} from OMNIWeb');
    text(0.05,0.8,'(i)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10); 
    
    subplot(4,3,10);    
    Snc=histc(omniVx(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');  
    % Vx OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,8),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r'); 
    hold off;
    %title('\fontsize{10}V_{x} from OMNIWeb');
    xlabel('\fontsize{10}V_{x} [km/s]');
    ylabel('\fontsize{10}n_{EFW}');
    text(0.05,0.8,'(j)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10);   
    
    subplot(4,3,11);    
    Snc=histc(omniVy(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');       
    % Vy OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,9),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');       
    hold off;
    %title('\fontsize{10}V_{y} from OMNIWeb');
    xlabel('\fontsize{10}V_{y} [km/s]');
    text(0.05,0.8,'(k)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10); 
    
    subplot(4,3,12);     
    Snc=histc(omniVz(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');     
    % Vz OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,10),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');     
    hold off;
    %title('\fontsize{10}V_{z} from OMNIWeb');
    xlabel('\fontsize{10}V_{z} [km/s]');
    text(0.05,0.8,'(l)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    xticklabels([-600,-400,-200,0,200]);
    set(gca,'FontSize',10); 
    
    % Saving result in an eps file   ------------------
    print(pv,'-depsc2',[root_path,...
        'images/omni_parameters-gumics-bz-v-histograms',strSuffix,'.eps']);
    
    % Closing the plot box
    close;  
    
    % P figure in the background  --------------------------------------
    pp = figure('visible','off','PaperOrientation','portrait');   
    
     % The width of the OMNI 1-year bars
    cBarWidth = 0.6;
    
    % Coefficiens histogram - Bx   
    subplot(2,2,1); 
    Svc=0:1:10;    
    Snc=histc(omniP(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');    
    % P OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,11),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');  
    hold off;
    title('\fontsize{10}P from OMNIWeb');
    ylabel('\fontsize{10}B_{z}');
    text(0.05,0.9,'(a)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[0 10]);    
    set(gca,'FontSize',10);   
    
    subplot(2,2,2);    
    Snc=histc(omniP(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');    
    % P OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,11),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');  
    hold off;
    title('\fontsize{10}P from OMNIWeb');
    ylabel('\fontsize{10}V_{x}');
    text(0.05,0.9,'(b)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[0 10]);    
    set(gca,'FontSize',10); 
    
    subplot(2,2,3);    
    Snc=histc(omniP(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');  
    % P OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,11),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');  
    hold off;
    xlabel('\fontsize{10}P [nPa]');
    ylabel('\fontsize{10}n_{CIS}');
    text(0.05,0.9,'(c)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[0 10]);    
    set(gca,'FontSize',10); 
    
    subplot(2,2,4);
    Snc=histc(omniP(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth,'FaceColor','k',...
        'EdgeColor','w');       
    % P OMNI 1-year histogram
    hold on;
    Snc=histc(A(:,11),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),barWidth*cBarWidth,...
        'FaceColor','r','EdgeColor','r');  
    hold off;
    %title('\fontsize{10}V_{x} from OMNIWeb');
    xlabel('\fontsize{10}P [nPa]');
    ylabel('\fontsize{10}n_{EFW}');
    text(0.05,0.9,'(d)','Units','Normalized');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[0 10]);    
    set(gca,'FontSize',10);
    
    % Saving result in an eps file   ------------------
    print(pp,'-depsc2',[root_path,...
        'images/omni_parameters-gumics-bz-p-histograms',strSuffix,'.eps']);
    
    % Closing the plot box
    close;  
end