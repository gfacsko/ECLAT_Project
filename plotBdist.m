function [ error ] = plotBdist(isBz)
%plotBdist Plot the distribution of B or Bzalong the Cluster SC3 orbit
%   Read all previously created GUMICS and Cluster files. 
%   Plot the distributions of B or Bz. 
%
%   isBz : Distribution of B or Bz
%
%   Developed by Gabor Facsko (facsko.gabor@csfk.mta.hu)
%   Geodetic and Geophysical Institute, RCAES, 2014-2015
%
% -----------------------------------------------------------------
%    
    error=0;
    % Default directories
    root_path='/home/gfacsko/Projects/Matlab/ECLAT/';
    
    % Read file
    bzStr='';
    if (isBz),bzStr='-bz';end;
    [status,result]=unix(['ls ',root_path,'data/corr-*',bzStr,...
        '-gumics.dat']);   
    % Process result
    startIndex=strfind(result,'corr-');
    endIndex=strfind(result,'.dat');
    for i=1:numel(startIndex)
        corrFilename=result(startIndex(i):endIndex(i)+3)
        A=load([root_path,'data/',corrFilename]);  
        if (i==1)
            B=A;
        else
            B=[B;A];
        end;
    end;    
    
    % Plot histograms
    Sv=(0:20);
    if (isBz),Sv=(-20:20);
    % Magnetic field histogram    
    Snbg=histc(B(:,2),Sv);
    Snbc=histc(B(:,5),Sv);
   
    % Figure in the background   
    p = figure('visible','off');   
    % Magnetic field plot
    bar(Sv+0.5,floor(Snbg/sum(Snbg)*100),'FaceColor','r','EdgeColor','r');   
    %B or Bz plot
    bzStr='';
    if (~isBz)
        set(gca,'xlim',[2 14]);    
        set(gca,'yLim',[0 20],'Layer','top');
        set(gca,'xtick',[2 3 4 5 6 7 8 9 10 11 12 13 14]);
        set(gca,'ytick',[0 5 10 15 20]);
        text(10,18,'\fontsize{20}Cluster SC3','Color','k','EdgeColor','k');
        text(10,16,'\fontsize{20}GUMICS-4 ','Color','r','EdgeColor','r')
    else
        bzStr='_z';
        set(gca,'xlim',[-8 9]);    
        set(gca,'yLim',[0 12],'Layer','top');
        set(gca,'xtick',[-8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9]);
        set(gca,'ytick',[0 1 2 3 4 5 6 7 8 9 10 11 12]);
        text(3,11,'\fontsize{20}Cluster SC3','Color','k','EdgeColor','k');
        text(3,9.5,'\fontsize{20}GUMICS-4 ','Color','r','EdgeColor','r')
    end;
    set(gca,'FontSize',20); 
    title(['\fontsize{20}B',bzStr,' distribution']);
    xlabel(['\fontsize{20}B',bzStr,'[nT]']);
    ylabel('\fontsize{20}Ratio [%]');   
    hold on;
    bar(Sv+0.5,floor(Snbc/sum(Snbc)*100),'k','BarWidth',0.25);    
    hold off
    % Construct epsfilename
    bzStr='';
    if (isBz),bzStr='z';end;
    epsFilename=[root_path,'images/b',bzStr,'Dist.eps'];
    % Saving result in an eps file
    print(p,'-depsc2',epsFilename);
    % Closing the plot box
    close;
end