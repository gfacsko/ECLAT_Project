function [ error ] = plotOMNIDist()
%plotOMNIDist plot the solar wind parameters distributions
%
% The function plot the distribution of the Bx, By, Bz, Vx, Vy, Vz and P of
% the solar wind form the OMNI database form January 29, 2002 to February
% 2, 2003 during the 1-year run. 
%
% error: error message
%
% Developed by Gabor FACSKO (gabor.i.facsko@gmail.com), Rhea System
% GmbH, Darmstad, Germany, 2020
% -----------------------------------------------------------------------
%
    error=0;
    % OMNI data files path
    omni_path='/home/facskog/OMNIWeb/';
    % Root path
    root_path='/home/facskog/Projectek/Matlab/ECLAT/';
    % Input file
    omniFilename='omni_min_20020129_20030202.dat';
    
    A=load([omni_path,omniFilename]);
    
    % Figure in the background  --------------------------------------
    p = figure('visible','off','PaperOrientation','portrait');   
    
    % Bx histogram
    subplot(3,3,1); 
    Svc=-10:5:10;    
    Snc=histc(A(:,5),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}B_{x} from OMNIWeb');
    ylabel('Ratio [%]');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10);   
    
    % By histogram
    subplot(3,3,2); 
    Svc=-10:5:10;    
    Snc=histc(A(:,6),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}B_{y} from OMNIWeb');
    %ylabel('Ratio [%]');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10); 
    
    % Bz histogram
    subplot(3,3,3); 
    Svc=-10:5:10;    
    Snc=histc(A(:,7),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}B_{z} from OMNIWeb');
    %ylabel('Ratio [%]');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-10 10]);    
    set(gca,'FontSize',10);  
    
    % Vx histogram
    subplot(3,3,4); 
    Svc=-600:50:200;    
    Snc=histc(A(:,8),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}V_{x} from OMNIWeb');
    ylabel('Ratio [%]');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10);   
    
    % Vy histogram
    subplot(3,3,5); 
    Snc=histc(A(:,9),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}V_{y} from OMNIWeb');
    %ylabel('Ratio [%]');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10); 
    
    % Vz histogram
    subplot(3,3,6);  
    Snc=histc(A(:,10),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}V_{z} from OMNIWeb');
    %ylabel('Ratio [%]');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[-600 200]);    
    set(gca,'FontSize',10);  
    
    % P histogram
    subplot(3,3,8);  
    Svc=0:1:10;
    Snc=histc(A(:,11),Svc);
    bar(Svc+2.5,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');       
    title('\fontsize{10}V_{z} from OMNIWeb');
    ylabel('Ratio [%]');
    set(gca,'YLim',[0 100],'Layer','top');
    set(gca,'Xlim',[0 10]);    
    set(gca,'FontSize',10);  
    
    % Saving result in an eps file   ------------------
    print(p,'-depsc2',[root_path,...
       'images/omni_min_20020129_20030202_distributions.eps']);
    
    % Closing the plot box
    close;  
    
end

