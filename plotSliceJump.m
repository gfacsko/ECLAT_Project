function [ error ] = plotSliceJump( resultFilename )
%plotSliceJump Plot the jump between slice.
%  Study jumps between the slices. Plots their distribution. 
%
%  Developed by Gabor Facsko (facsko.gabor@csfk.mta.hu)
%  Geodetic and Geophysical Institute, RCAES, HAS, 2014
% 
%-----------------------------------------------------------------
%
    error=0;
    % Data path    
    root_path='/home/gfacsko/Projects/Matlab/ECLAT/';

    % Read data
    r=load([root_path,'data/',resultFilename]);
    
    % Calculate jumps
    for i=1:numel(r(:,1))-1
        % Density
        r(i+1,1)=r(i+1,1)-r(i,2);   
        r(i+1,1)=r(i+1,1)/r(i+1,3)*100;
        r(i+1,4)=r(i+1,4)/r(i+1,3)*100;
        % Velocity
        r(i+1,5)=r(i+1,5)-r(i,6);   
        r(i+1,5)=r(i+1,5)/r(i+1,7)*100;
        r(i+1,8)=r(i+1,8)/r(i+1,7)*100;
        % Magnetic field
        r(i+1,9)=r(i+1,9)-r(i,10);   
        r(i+1,9)=r(i+1,9)/r(i+1,11)*100;
        r(i+1,12)=r(i+1,12)/r(i+1,11)*100;
    end;   
    
    % Process files
    Sv=(0:10)*10;
    % Density histogram
    Snj=histc(r(:,1),Sv);
    Snn=histc(r(:,4),Sv);
    % Velocity histogram
    Svj=histc(r(:,5),Sv);
    Svn=histc(r(:,8),Sv);
    % Magnetic field histogram
    Sbj=histc(r(:,9),Sv);
    Sbn=histc(r(:,12),Sv);
    
    % Figure in the background   
    p = figure('visible','off');   
    % Plot
    subplot(1,3,1);
    bar(Sv+5,floor(Snn/sum(Snn)*100),'FaceColor','r','EdgeColor','r');
    set(gca,'YLim',[0 60],'Layer','top');
    set(gca,'xlim',[0 100]);
    set(gca,'xtick',[0 20 40 60 80 100]);
    set(gca,'FontSize',15); 
    title('\fontsize{20}SW density');
    ylabel('\fontsize{20}Ratio [%]');
    text(70,55,'\fontsize{20}(a)','Color','k');  
    hold on;
    bar(Sv+5,floor(Snj/sum(Snj)*100),'k','BarWidth',0.25);    
    hold off;
    % Velocity
    subplot(1,3,2);
    bar(Sv+5,floor(Svn/sum(Svn)*100),'FaceColor','r','EdgeColor','r');
    set(gca,'YLim',[0 60],'Layer','top');
    set(gca,'xlim',[0 100]);
    set(gca,'xtick',[0 20 40 60 80 100]);
    set(gca,'FontSize',15); 
    title('\fontsize{20}SW speed');
    xlabel('\fontsize{20}Relative variance (red), Relative jump (black) [%]');
    text(70,55,'\fontsize{20}(b)','Color','k');  
    hold on;
    bar(Sv+5,floor(Svj/sum(Svj)*100),'k','BarWidth',0.25);    
    hold off;
    % Magnetic field
    subplot(1,3,3);
    bar(Sv+5,floor(Sbn/sum(Sbn)*100),'FaceColor','r','EdgeColor','r');
    set(gca,'YLim',[0 60],'Layer','top');
    set(gca,'xlim',[0 100]);
    set(gca,'xtick',[0 20 40 60 80 100]);
    set(gca,'FontSize',15); 
    title('\fontsize{20}B magnitude');
    text(20,45,'\fontsize{20}Variance','Color','r','EdgeColor','r') 
    text(20,39,'\fontsize{20}Jump','Color','k','EdgeColor','k');  
    text(70,55,'\fontsize{20}(c)','Color','k');  
    hold on;
    bar(Sv+5,floor(Sbj/sum(Sbj)*100),'k','BarWidth',0.25);    
    hold off
    % Construct epsfilename
    epsFilename=[root_path,'images/',...
        resultFilename(1:numel(resultFilename)-4),'.eps'];
    % Saving result in an eps file
%     set(p, 'PaperUnits','centimeters')
%     set(p, 'PaperSize',[30 10])
%     set(p, 'PaperPosition',[0 0 30 15])
%     set(p, 'PaperOrientation','portrait')
    print(p,'-depsc2',epsFilename);
    % Closing the plot box
    close;
end

