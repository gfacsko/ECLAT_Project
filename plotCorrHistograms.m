function [ error ] = plotCorrHistograms(isOMNI,isBz,strSuffix) 
%plotCorrHistograms Analysis of the correlation calculation. 
%   Histograms of the time shif and correlation coefficients.
%
%   isOMNI    : OMNIWeb/GUMICS
%   isBz      : Use Bz or B for calculations
%   strSuffix : Extra string to distinguish the results
%
%   Developed by Gabor Facsko (facsko.gabor@csfk.mta.hu)
%   Geodetic and Geophysical Institute, RCAES, 2014-2017
%
% -----------------------------------------------------------------
%    
    error=0;
    % Default directories
    root_path='/home/facskog/Projectek/Matlab/ECLAT/';
    
    % Read and process file
    if (isOMNI)
        bzStr=''; 
        if (isBz),bzStr='-bz';end;
        [status,result]=unix(['echo $(cut -d\& -f2 ',...
            root_path,'data/results',bzStr,'.dat)']);
        ccFgm=str2num(result);
        [status,result]=unix(['echo $(cut -d\& -f3 ',...
            root_path,'data/results',bzStr,'.dat)']);
        ctFgm=str2num(result);
    else
        bzStr=''; 
        if (isBz),bzStr='-bz';end;
        % B FGM results
        [status,result]=unix(['echo $(cut -d\& -f2 ',...
            root_path,'data/results-gumics',bzStr,strSuffix,'.dat)']);
        ccFgm=str2num(result);
        [status,result]=unix(['echo $(cut -d\& -f3 ',...
            root_path,'data/results-gumics',bzStr,strSuffix,'.dat)']);
        ctFgm=str2num(result);
        % V CIS HIA results
        [status,result]=unix(['echo $(cut -d\& -f4 ',...
            root_path,'data/results-gumics',bzStr,strSuffix,'.dat)']);
        ccVCis=str2num(result);
        [status,result]=unix(['echo $(cut -d\& -f5 ',...
            root_path,'data/results-gumics',bzStr,strSuffix,'.dat)']);
        ctVCis=str2num(result);
         % n CIS HIA results
        [status,result]=unix(['echo $(cut -d\& -f6 ',...
            root_path,'data/results-gumics',bzStr,strSuffix,'.dat)']);
        ccNCis=str2num(result);
        [status,result]=unix(['echo $(cut -d\& -f7 ',...
            root_path,'data/results-gumics',bzStr,strSuffix,...
            '.dat|cut -d\\ -f1)']);
        ctNCis=str2num(result);
        % n EFW results
        [status,result]=unix(['echo $(cut -d\& -f8 ',...
            root_path,'data/results-gumics',bzStr,strSuffix,'.dat)']);
        ccNEfw=str2num(result);
        [status,result]=unix(['echo $(cut -d\& -f9 ',...
            root_path,'data/results-gumics',bzStr,strSuffix,...
            '.dat|cut -d\\ -f1)']);
        ctNEfw=str2num(result);
%         ccVCis=ccVCis(find(abs(ctVCis)<30));
%         ctVCis=ctVCis(find(abs(ctVCis)<30));
%         ccNCis=ccNCis(find(abs(ctNCis)<30));
%         ctNCis=ctNCis(find(abs(ctNCis)<30));
    end;
    
    % Figure in the background   
    p = figure('visible','off');   
    % Coefficiens histogram - B FGM   
    if (isOMNI)
        subplot(2,1,1); 
        Svc=0.6:0.1:1;
    else
        subplot(4,2,1); 
        Svc=0.6:0.1:1;
    end;
    Snc=histc(ccFgm,Svc);
    bar(Svc+0.05,floor(Snc/sum(Snc)*100),'FaceColor','k',...
        'EdgeColor','w');   
    if (isOMNI)
        title('\fontsize{10}B_{z} from OMNIWeb and Cluster SC3');
        set(gca,'YLim',[0 70],'Layer','top');
        set(gca,'Xlim',[0.97 1]);
    else
        title('\fontsize{10}B_{z}');
        %text(0.025,0.8,'(a)');
        text(0.025,0.8,'(a)','Units','Normalized');
        if (strcmp(strSuffix,'-sw')||strcmp(strSuffix,'-msh'))
            set(gca,'YLim',[0 100],'Layer','top');   
            set(gca,'YTick',0:50:100);           
            set(gca,'Xlim',[0.6 1]);
        end;
        if (strcmp(strSuffix,'-msh'))
            set(gca,'YLim',[0 100],'Layer','top');
            set(gca,'Xlim',[0.6 1]);
        end;
        if (strcmp(strSuffix,'-msph'))
            set(gca,'YLim',[0 100],'Layer','top');
            set(gca,'Xlim',[0.6 1]);
        end;
    end;   
    set(gca,'FontSize',10);
    %axis square;
    if (isOMNI),xlabel('\fontsize{10}Coefficient');end;
    ylabel('\fontsize{10}Ratio [%]');    
    % Time shift histogram   
    if (isOMNI) 
        subplot(2,1,2); 
        Svt=-20:5:15;%B        
    else
        subplot(4,2,2); 
        Svt=-20:5:15;
        if (strcmp(strSuffix,'-sw')), Svt=-60:5:60;end;       
    end;
    Snt=histc(ctFgm,Svt);   
    bar(Svt+2.5,floor(Snt/sum(Snt)*100),'FaceColor','k',...
        'EdgeColor','w');
    if (isOMNI)
        if (~isBz)
            title('\fontsize{10}B from OMNIWeb and Cluster SC3');
            set(gca,'YLim',[0 70],'Layer','top');
            set(gca,'Xlim',[-20 10]);    
        else
            title('\fontsize{10}B_z from OMNIWeb and Cluster SC3');           
            set(gca,'YLim',[0 100],'Layer','top');
            set(gca,'Xlim',[-5 15]);
        end;
    else
        if (~isBz)
            title('\fontsize{10}B from GUMICS and Cluster SC3');
            set(gca,'YLim',[0 45],'Layer','top');        
            set(gca,'Xlim',[-20 10]);
        else
            title('\fontsize{10}B_z');
            text(0.025,0.8,'(b)','Units','Normalized');
            if (strcmp(strSuffix,'-sw'))
                set(gca,'YLim',[0 100],'Layer','top');     
                set(gca,'YTick',0:50:100);                   
                set(gca,'Xlim',[-15 15]);                
            end;
            if (strcmp(strSuffix,'-msh'))
                 set(gca,'YLim',[0 100],'Layer','top');        
                 Set(gca,'YTick',0:50:100);     
                 set(gca,'Xlim',[-15 15]);                
            end;
            if (strcmp(strSuffix,'-msph'))
                 set(gca,'YLim',[0 100],'Layer','top');        
                 set(gca,'Xlim',[-10 5]);
            end;
        end;
    end;
    set(gca,'FontSize',10);
    %axis square;
    if(isOMNI)
        xlabel('\fontsize{10}Time shift [min]');
        ylabel('\fontsize{10}Ratio [%]');    
    end;
    
    % Histograms - CIS   
    if (~isOMNI)
        subplot(4,2,3); 
        % Coefficient histogram - V CIS
        Svc=0.6:0.1:1;            
        Snc=histc(ccVCis,Svc);
        bar(Svc+0.05,floor(Snc/sum(Snc)*100),'FaceColor','k',...
            'EdgeColor','w');           
        title('\fontsize{10}V_{x}');
        text(0.025,0.8,'(c)','Units','Normalized'); 
        if (strcmp(strSuffix,'-sw'))
             set(gca,'YLim',[0 100],'Layer','top');
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[0.6 1]);             
        end;
        if (strcmp(strSuffix,'-msh'))
             set(gca,'YLim',[0 100],'Layer','top');
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[0.6 1]);
        end;
        if (strcmp(strSuffix,'-msph'))
             set(gca,'YLim',[0 100],'Layer','top');
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[0.6 1]);
        end;
        set(gca,'FontSize',10);
        %axis square;
%        xlabel('\fontsize{10}Coefficient');
         ylabel('\fontsize{10}Ratio [%]');    
        
        % Time shift histogram - V CIS
        subplot(4,2,4);        
        Svt=-20:5:15;
        if (strcmp(strSuffix,'-sw')), Svt=-60:5:60;end;               
        Snt=histc(ctVCis,Svt);   
        bar(Svt+2.5,floor(Snt/sum(Snt)*100),'FaceColor','k',...
            'EdgeColor','w');                
        title('\fontsize{10}V_x');
        text(0.025,0.8,'(d)','Units','Normalized');
        if (strcmp(strSuffix,'-sw'))
             set(gca,'YLim',[0 100],'Layer','top');   
             set(gca,'YTick',0:50:100);          
             set(gca,'Xlim',[-15 15]);             
        end;
        if (strcmp(strSuffix,'-msh'))
             set(gca,'YLim',[0 100],'Layer','top');    
             set(gca,'YTick',0:50:100);         
             set(gca,'Xlim',[-15 15]);             
        end;
        if (strcmp(strSuffix,'-msph'))
             set(gca,'YLim',[0 100],'Layer','top');        
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[-10 5]);
        end;
        set(gca,'FontSize',10);
        %axis square;
%        xlabel('\fontsize{10}Time shift [min]');
%        ylabel('\fontsize{10}Ratio [%]');    
        
        % Coefficient histogram - n CIS
        subplot(4,2,5);        
        Svc=0.6:0.1:1;            
        Snc=histc(ccNCis,Svc);
        bar(Svc+0.05,floor(Snc/sum(Snc)*100),'FaceColor','k',...
            'EdgeColor','w');           
        title('\fontsize{10}n_{CIS}');
        text(0.025,0.8,'(e)','Units','Normalized');
        if (strcmp(strSuffix,'-sw'))
             set(gca,'YLim',[0 100],'Layer','top');
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[0.6 1]);              
        end;
        if (strcmp(strSuffix,'-msh'))
              set(gca,'YLim',[0 100],'Layer','top');
              set(gca,'YTick',0:50:100);     
              set(gca,'Xlim',[0.6 1]);  
        end;
        if (strcmp(strSuffix,'-msph'))
             set(gca,'YLim',[0 100],'Layer','top');
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[0.6 1]);  
        end;
        %xlabel('Correlation coefficients');
        ylabel('Ratio [%]');
        set(gca,'FontSize',10);
        %axis square;
        %xlabel('\fontsize{10}Coefficient');
        ylabel('\fontsize{10}Ratio [%]');    
        
        % Time shift histogram - n CIS
        subplot(4,2,6);        
        Svt=-20:5:15;
        if (strcmp(strSuffix,'-sw')), Svt=-60:5:60;end;               
        Snt=histc(ctNCis,Svt);   
        bar(Svt+2.5,floor(Snt/sum(Snt)*100),'FaceColor','k',...
            'EdgeColor','w');                
        title('\fontsize{10}n_{CIS}');
        text(0.025,0.8,'(f)','Units','Normalized');
        if (strcmp(strSuffix,'-sw'))
             set(gca,'YLim',[0 100],'Layer','top');        
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[-15 15]);
        end;
        if (strcmp(strSuffix,'-msh'))
             set(gca,'YLim',[0 100],'Layer','top');        
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[-15 15]);
        end;
        if (strcmp(strSuffix,'-msph'))
             set(gca,'YLim',[0 100],'Layer','top');       
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[-5 15]);
        end;
        set(gca,'FontSize',10);
        %axis square;
        %xlabel('\fontsize{10}Time shift [min]');
        %ylabel('\fontsize{10}Ratio [%]');   
        
        % Coefficient histogram - n EFW
        subplot(4,2,7);        
        Svc=0.6:0.1:1;            
        Snc=histc(ccNEfw,Svc);
        bar(Svc+0.05,floor(Snc/sum(Snc)*100),'FaceColor','k',...
            'EdgeColor','w');           
        title('\fontsize{10}n_{EFW}');
        text(0.025,0.8,'(g)','Units','Normalized');
        if (strcmp(strSuffix,'-sw'))
             set(gca,'YLim',[0 100],'Layer','top');
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[0.6 1]);             
        end;
        if (strcmp(strSuffix,'-msh'))
              set(gca,'YLim',[0 100],'Layer','top');
              set(gca,'YTick',0:50:100);     
              set(gca,'Xlim',[0.6 1]);  
        end;
        if (strcmp(strSuffix,'-msph'))
              set(gca,'YLim',[0 100],'Layer','top');
              set(gca,'YTick',0:50:100);     
              set(gca,'Xlim',[0.6 1]);  
        end;
        xlabel('Correlation coefficients');
        ylabel('Ratio [%]');
        set(gca,'FontSize',10);
        %axis square;
        xlabel('\fontsize{10}Coefficient');
        ylabel('\fontsize{10}Ratio [%]');    
        
        % Time shift histogram - n EFW
        subplot(4,2,8);        
        Svt=-20:5:15;
        if (strcmp(strSuffix,'-sw')), Svt=-60:5:60;end;               
        Snt=histc(ctNEfw,Svt);   
        bar(Svt+2.5,floor(Snt/sum(Snt)*100),'FaceColor','k',...
            'EdgeColor','w');                
        title('\fontsize{10}n_{EFW}');
        text(0.025,0.8,'(h)','Units','Normalized');
        if (strcmp(strSuffix,'-sw'))
             set(gca,'YLim',[0 100],'Layer','top');        
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[-15 15]);            
        end;
        if (strcmp(strSuffix,'-msh'))
             set(gca,'YLim',[0 100],'Layer','top');       
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[-15 15]);
        end;
        if (strcmp(strSuffix,'-msph'))
             set(gca,'YLim',[0 100],'Layer','top');        
             set(gca,'YTick',0:50:100);     
             set(gca,'Xlim',[-20 10]);
        end;
        set(gca,'FontSize',10);
        %axis square;
        xlabel('\fontsize{10}Time shift [min]');
        %ylabel('\fontsize{10}Ratio [%]'); 
    end;
    
    % Saving result in an eps file   ------------------
    if (isOMNI)
        print(p,'-depsc2',[root_path,...
            'images/results_histograms.eps']);
    else
        print(p,'-depsc2',[root_path,...
            'images/results_histograms-gumics',strSuffix,'.eps']);
    end;
    % Closing the plot box
    close;  
end