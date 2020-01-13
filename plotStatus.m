function [ error ] = plotStatus( filename )
%plotStatus Plots the current status of ECLAT year runs
%  Reads the status.txt file and create a plot and a table of ready, 
%  running and halted runs. 
% 
%  filename: Name and path of the status file
%
%  Developed by Gabor Facsko, Finish Meteorologycal Institute, 2012
%  gabor.facsko@fmi.fi
%
%------------------------------------------------------------------
%

    % Array declaration
    [status,result] = unix(['cat ',filename,'|grep orbit|wc -l']);
    N= 1860; % str2num(result);
    A=zeros(N,6);

    % Download status files
    [status,results]=unix('/home/facsko/bin/gumics_download.sh');
    
    % Prepocess / Concatenate status.txt and status2.txt files ----------
    fid0=fopen([filename(1:length(filename)-4),'_temp.txt'], 'w');
    fid=fopen(filename, 'r'); 
    % orbit258 - orbit307-12
    strLine=fgetl(fid);
    fprintf(fid0,'%s\n',strLine);
	while (feof(fid)==0 && length(strfind(strLine,'orbit307-12'))==0)
        strLine=fgetl(fid);
        fprintf(fid0,'%s\n',strLine);
    end;
    % There is mstate file here
    strLine=fgetl(fid);
    fprintf(fid0,'%s\n',strLine);
    % Read status2.txt until orbit312-11
    fid2=fopen([filename(1:length(filename)-4),'2.txt'], 'r');
    while (feof(fid2)==0 && length(strfind(strLine,'orbit312-11'))==0)
        strLine=fgetl(fid2);
        fprintf(fid0,'%s\n',strLine);
    end;    
    % If there is mstate file, write it
    lastLine=fgetl(fid2);
    if (length(strfind(lastLine,'orbit313-01'))==0)
        fprintf(fid0,'%s\n',lastLine);
    end;
    % orbit312
    strLine=fgetl(fid);
    fprintf(fid0,'%s\n',strLine);
    strLine=fgetl(fid);
    fprintf(fid0,'%s\n',strLine);
    % orbit313
    if (length(strfind(lastLine,'orbit313-01'))~=0)
        fprintf(fid0,'%s\n',lastLine);
    end;
    while (feof(fid2)==0 && length(strfind(strLine,'orbit313-12'))==0)
        strLine=fgetl(fid2);
        fprintf(fid0,'%s\n',strLine);
    end;   
    % If there is mstate file, write it
    lastLine=fgetl(fid2);
    if (length(strfind(lastLine,'orbit328-01'))==0)
        fprintf(fid0,'%s\n',lastLine);
    end;  
    % orbit314 -- orbit328
    while (feof(fid)==0 && length(strfind(strLine,'orbit327-12'))==0)
        strLine=fgetl(fid);
        fprintf(fid0,'%s\n',strLine);
    end;
    % There is mstate file here
    strLine=fgetl(fid);
    fprintf(fid0,'%s\n',strLine);
    % orbit328-01 -- 09
%    fprintf(fid0,'%s\n',lastLine);
    while (feof(fid2)==0 && length(strfind(strLine,'orbit328-09'))==0)
        strLine=fgetl(fid2);
        fprintf(fid0,'%s\n',strLine);
    end;   
    % mstate file?
    lastLine=fgetl(fid2);
    if (length(strfind(lastLine,'orbit329-01'))==0)
        fprintf(fid0,'%s\n',lastLine);
    end; 
    % orbit328-09 -- 12
    while (feof(fid)==0 && length(strfind(strLine,'orbit328-12'))==0)
        strLine=fgetl(fid);
        fprintf(fid0,'%s\n',strLine);
    end;  
    % mstate file?
    lastLine2=fgetl(fid);
    if (length(strfind(lastLine2,'orbit329-09'))==0)
        fprintf(fid0,'%s\n',lastLine2);
    end; 
    % orbit329-01 directory name?
    if (length(strfind(lastLine,'orbit329-01'))~=0)
        fprintf(fid0,'%s\n',lastLine);
    end; 
    % orbit329-01 -- 09
    while (feof(fid2)==0)
        strLine=fgetl(fid2);
        fprintf(fid0,'%s\n',strLine);
    end; 
    fclose(fid2);
    % orbit329-09 directory?
    if (length(strfind(lastLine2,'orbit329-09'))~=0)
        fprintf(fid0,'%s\n',lastLine2);
    end;     
    % orbit329-09 -- 376-12
    while (feof(fid)==0 && length(strfind(strLine,'orbit376-12'))==0)
        strLine=fgetl(fid);
        fprintf(fid0,'%s\n',strLine);
    end; 
    % There is mstate file here
    strLine=fgetl(fid);
    fprintf(fid0,'%s\n',strLine);
    % Open status3 file
    fid3=fopen([filename(1:length(filename)-4),'3.txt'], 'r');
    for o=377:399
        % orbit377-01 -- 08
        while (feof(fid3)==0 && length(strfind(strLine,['orbit',num2str(o),'-08']))==0)
            strLine=fgetl(fid3);
            fprintf(fid0,'%s\n',strLine);
        end;
        % mstate file?
        lastLine2=fgetl(fid3);
        if (length(strfind(lastLine2,['orbit',num2str(o+1),'-01']))==0)
            fprintf(fid0,'%s\n',lastLine2);
        end; 
        % orbit377-09 -- 377-12
        while (feof(fid)==0 && length(strfind(strLine,['orbit',num2str(o),'-12']))==0)
            strLine=fgetl(fid);
            fprintf(fid0,'%s\n',strLine);
        end; 
        % There is mstate file
        lastLine=fgetl(fid);
        fprintf(fid0,'%s\n',lastLine);
        if (length(strfind(lastLine2,['orbit',num2str(o+1),'-01']))~=0)
            fprintf(fid0,'%s\n',lastLine2); 
        end;
    end;
    % Until end of status3 file
    while (feof(fid3)==0)
        strLine=fgetl(fid3);
        fprintf(fid0,'%s\n',strLine);
    end; 
    fclose(fid3);
    % Until end of status file
    while (feof(fid)==0)
        strLine=fgetl(fid);
        fprintf(fid0,'%s\n',strLine);
    end; 
    fclose(fid);
    fclose(fid0);
    % -------------------------------------------------------------------
    
    % Read preprocessed status file        
    fid=fopen([filename(1:length(filename)-4),'_temp.txt'], 'r');   
    % Reading data
    i=0;   
	strLine=fgetl(fid);
	while (feof(fid)==0)
		if (strfind(strLine,'orbit')==1)
            i=i+1;  
            A(i,1)=str2num(strLine(6:8));
            A(i,2)=str2num(strLine(10:11));
            strD1=strLine(13:20);
            strT1=strLine(22:27);
            strD2=strLine(29:36);
            strT2=strLine(38:43);     
            A(i,3)=datenum([str2num(strD1(1:4)) str2num(strD1(5:6))...
                str2num(strD1(7:8)) str2num(strT1(1:2))...
                str2num(strT1(3:4)) str2num(strT1(5:6))]);
            A(i,4)=datenum([str2num(strD2(1:4)) str2num(strD2(5:6))...
                str2num(strD2(7:8)) str2num(strT2(1:2))...
                str2num(strT2(3:4)) str2num(strT2(5:6))]);
        end;
        mpos=strfind(strLine,'mstate');
        if (mpos>0)           
            strD=strLine(mpos+6:mpos+13);
            strT=strLine(mpos+15:mpos+20);         
            A(i,5)=datenum([str2num(strD(1:4)) str2num(strD(5:6))...
                str2num(strD(7:8)) str2num(strT(1:2))...
                str2num(strT(3:4)) str2num(strT(5:6))]);
        end;                 
        dpos=max([strfind(strLine,'2012-'),strfind(strLine,'2013-')]);
        if (dpos>0)    
            strD=strLine(dpos:dpos+9);
            strT=strLine(dpos+11:dpos+15);
            A(i,6)=datenum([str2num(strD(1:4)) str2num(strD(6:7))...
                str2num(strD(9:10)) str2num(strT(1:2))...
                str2num(strT(4:5)) 0]);
        end;
	    strLine=fgetl(fid);
    end;
    if (strfind(strLine,'orbit')==1)
        i=i+1;  
        A(i,1)=str2num(strLine(6:8));
        A(i,2)=str2num(strLine(10:11));
        strD1=strLine(13:20);
        strT1=strLine(22:27);
        strD2=strLine(29:36);
        strT2=strLine(38:43);     
        A(i,3)=datenum([str2num(strD1(1:4)) str2num(strD1(5:6))...
            str2num(strD1(7:8)) str2num(strT1(1:2))...
            str2num(strT1(3:4)) str2num(strT1(5:6))]);
        A(i,4)=datenum([str2num(strD2(1:4)) str2num(strD2(5:6))...
            str2num(strD2(7:8)) str2num(strT2(1:2))...
            str2num(strT2(3:4)) str2num(strT2(5:6))]);
    end;
    mpos=strfind(strLine,'mstate');
    if (mpos>0)           
        strD=strLine(mpos+6:mpos+13);
        strT=strLine(mpos+15:mpos+20);         
        A(i,5)=datenum([str2num(strD(1:4)) str2num(strD(5:6))...
            str2num(strD(7:8)) str2num(strT(1:2))...
            str2num(strT(3:4)) str2num(strT(5:6))]);     
    end;
    dpos=max([strfind(strLine,'2012-'),strfind(strLine,'2013-')]);
    if (dpos>0)    
        strD=strLine(dpos:dpos+9);
        strT=strLine(dpos+11:dpos+15);
        A(i,6)=datenum([str2num(strD(1:4)) str2num(strD(6:7))...
            str2num(strD(9:10)) str2num(strT(1:2))...
            str2num(strT(4:5)) 0]);
    end;
    fclose(fid);

    % Figure in the background   
    p = figure('visible','off');   
    k=31;
    Nruns=N; % 600;
    for j=1:k
%        subplot(k,1,j);
        subplot('Position',[0.01 (k-j+1)/(k+1) 0.7750 1/(k+1)]);
        plot([A((j-1)*Nruns/k+1,3),A(j*Nruns/k,3)],[0,5],'-w'); datetick('x','');
        datetick('y','');
        axis([A((j-1)*Nruns/k+1,3) A(j*Nruns/k,4) 0 5]);   
        set(gca,'XTick',A((j-1)*Nruns/k+1,3):57/24:A(j*Nruns/k,3));
        set(gca,'TickLength',[0 0]);
        %set(gca,'Position',[0.01 (k-j+1)/(k+1) 0.7750 1/(k+1)]);
        %title('ECLAT year run status');
        %if (j==k),xlabel('Orbit numbers');end;
        hold on;
        for i=((j-1)*Nruns/k+1):(j*Nruns/k)             
            % Status
            if (A(i,5)>0 && A(i,3)<A(i,5))
                cRec=[0.5 0.5 0.5];
                if ((now-A(i,6)) <1.),cRec=[0 1 0.5];end;
                if (abs(A(i,4)-A(i,5))*24*60<6),cRec=[0 0 1];end;
                % The Orbit 294/01 slice is constant
                if (A(i,1)==294 && A(i,2)==1),cRec=[0 0 1];A(i,5)=A(i,4);end;
                rectangle('Position',[A(i,3),0,abs(A(i,5)-A(i,3)),5],...
                    'FaceColor',cRec,'EdgeColor','none');
%               plot([A(i,5),A(i,5)],[0,4],'-k');
              end;
              % Separator lines
              if (A(i,2)==1)
                plot([A(i,3),A(i,3)],[0,5],'-r');
                 plot([A(i,4),A(i,4)],[0,5],'-b');
              end;
            if (A(i,2)>1||A(i,3)<123)
               plot([A(i,3),A(i,3)],[0,5],'-b');
               plot([A(i,4),A(i,4)],[0,5],'-b');               
            end;
            if (A(i,2)==12)
                plot([A(i,3),A(i,3)],[0,5],'-b');
                plot([A(i,4),A(i,4)],[0,5],'-r');               
                text((A(i-11,3)+A(i,4))/2,2,num2str(A(i,1)),'HorizontalAlignment','center');   
            end;
        end;
        hold off;
    end;
    % Saving result in an eps file
    print(p,'-depsc2','images/status.eps');
    print(p,'-dpng','images/status.png');
    % Closing the plot box
    close;
    
    % Delete trash   
    [status,result]=unix(['cd ',filename(1:length(filename)-10),...
        ';rm status_temp.txt']);
end

