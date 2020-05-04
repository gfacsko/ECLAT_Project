function [ error ] = plotOMNIHistograms(strSuffix) 
%plotOMNIHistograms Analysis of the upstream solar wind data. 
%   Histograms of the OMNI data to investigate when the GUMICS4 provides
%   wrong results.
%
%   strSuffix : Extra string to distinguish the results
%
%   Developed by Gabor Facsko (gabor.facsko@esa.int)
%   Rhea Systems GmbH for European Space Agency, 2014-2018
%
% -----------------------------------------------------------------
%    
    error=0;
    % Default directories
    root_path='/home/facskog/Projectek/Matlab/ECLAT/';
    
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
          
    % B figure in the background  --------------------------------------
    pb = figure('visible','off','PaperOrientation','portrait');   
    % Coefficiens histogram - Bx   
    subplot(4,3,1); 
    Svc=-10:5:10;    
    Snc=histc(omniBx(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}B_{x} from OMNIWeb');
    ylabel('\fontsize{10}B_{z}');
    text(-9, 80,'(a)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,2);    
    Snc=histc(omniBy(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}B_{y} from OMNIWeb');
    set(gca,'YLim',[0 100],'Layer','top');
    
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    text(-9, 80,'(b)');
    subplot(4,3,3);    
    Snc=histc(omniBz(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}B_{z} from OMNIWeb');
    text(-9, 80,'(c)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,4);
    Snc=histc(omniBx(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    text(-9, 80,'(d)');
    %title('\fontsize{10}V_{x} from OMNIWeb');
    ylabel('\fontsize{10}V_{x}');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,5);    
    Snc=histc(omniBy(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{y} from OMNIWeb');
    text(-9, 80,'(e)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,6);      
    Snc=histc(omniBz(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{z} from OMNIWeb');
    text(-9, 80,'(f)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,7);     
    Snc=histc(omniBx(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{x} from OMNIWeb');
    ylabel('\fontsize{10}n_{CIS}');
    text(-9, 80,'(g)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,8);    
    Snc=histc(omniBy(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{y} from OMNIWeb');
    text(-9, 80,'(h)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,9);      
    Snc=histc(omniBz(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{z} from OMNIWeb');
    text(-9, 80,'(i)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,10);    
    Snc=histc(omniBx(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{x} from OMNIWeb');    
    xlabel('\fontsize{10}B_{x} [nT]');
    ylabel('\fontsize{10}n_{EFW}');
    text(-9, 80,'(j)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,11);    
    Snc=histc(omniBy(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{y} from OMNIWeb');
    xlabel('\fontsize{10}B_{y} [nT]');
    text(-9, 80,'(k)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,12);     
    Snc=histc(omniBz(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{z} from OMNIWeb');
    xlabel('\fontsize{10}B_{z} [nT]');
    text(-9, 80,'(l)');
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
    % Coefficiens histogram - Bx   
    subplot(4,3,1); 
    Svc=-600:50:200;    
    Snc=histc(omniVx(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}V_{x} from OMNIWeb');
    ylabel('\fontsize{10}B_{z}');
    text(-550, 80,'(a)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,2);    
    Snc=histc(omniVy(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}V_{y} from OMNIWeb');
    text(-550, 80,'(b)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,3);    
    Snc=histc(omniVz(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}V_{z} from OMNIWeb');
    text(-550, 80,'(c)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,4);
    Snc=histc(omniVx(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{x} from OMNIWeb');
    ylabel('\fontsize{10}V_{x}');
    text(-550, 80,'(d)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,5);    
    Snc=histc(omniVy(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{y} from OMNIWeb');
    text(-550, 80,'(e)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,6);      
    Snc=histc(omniVz(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{z} from OMNIWeb');
    text(-550, 80,'(f)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,7);     
    Snc=histc(omniVx(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{x} from OMNIWeb');
    ylabel('\fontsize{10}n_{CIS}');
    text(-550, 80,'(g)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,8);    
    Snc=histc(omniVy(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{y} from OMNIWeb');
    text(-550, 80,'(h)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,9);      
    Snc=histc(omniVz(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{z} from OMNIWeb');
    text(-550, 80,'(i)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,10);    
    Snc=histc(omniVx(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{x} from OMNIWeb');
    xlabel('\fontsize{10}V_{x} [km/s]');
    ylabel('\fontsize{10}n_{EFW}');
    text(-550, 80,'(j)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10);   
    
    subplot(4,3,11);    
    Snc=histc(omniVy(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{y} from OMNIWeb');
    xlabel('\fontsize{10}V_{y} [km/s]');
    text(-550, 80,'(k)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10); 
    
    subplot(4,3,12);     
    Snc=histc(omniVz(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{z} from OMNIWeb');
    xlabel('\fontsize{10}V_{z} [km/s]');
    text(-550, 80,'(l)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10); 
    
    % Saving result in an eps file   ------------------
    print(pv,'-depsc2',[root_path,...
        'images/omni_parameters-gumics-bz-v-histograms',strSuffix,'.eps']);
    
    % Closing the plot box
    close;  
    
    % P figure in the background  --------------------------------------
    pp = figure('visible','off','PaperOrientation','portrait');   
    % Coefficiens histogram - Bx   
    subplot(2,2,1); 
    Svc=0:1:10;    
    Snc=histc(omniP(find(~boolBz)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}P from OMNIWeb');
    ylabel('\fontsize{10}B_{z}');
    text(0.75, 85,'(a)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[0 10]);    
    set(gca,'FontSize',10);   
    
    subplot(2,2,2);    
    Snc=histc(omniP(find(~boolVx)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}P from OMNIWeb');
    ylabel('\fontsize{10}V_{x}');
    text(0.75, 85,'(b)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[0 10]);    
    set(gca,'FontSize',10); 
    
    subplot(2,2,3);    
    Snc=histc(omniP(find(~boolNCIS)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    xlabel('\fontsize{10}P [nPa]');
    ylabel('\fontsize{10}n_{CIS}');
    text(0.75, 85,'(c)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[0 10]);    
    set(gca,'FontSize',10); 
    
    subplot(2,2,4);
    Snc=histc(omniP(find(~boolNEFW)),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    %title('\fontsize{10}V_{x} from OMNIWeb');
    xlabel('\fontsize{10}P [nPa]');
    ylabel('\fontsize{10}n_{EFW}');
    text(0.75, 85,'(d)');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[0 10]);    
    set(gca,'FontSize',10);
    
    % Saving result in an eps file   ------------------
    print(pp,'-depsc2',[root_path,...
        'images/omni_parameters-gumics-bz-p-histograms',strSuffix,'.eps']);
    
    % Closing the plot box
    close;  
end