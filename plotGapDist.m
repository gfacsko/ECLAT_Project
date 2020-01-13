function [ tGap, minGap ] = plotGapDist( epsFilename )
%plotGapDist Plot the distribution of gaps in OMNIWeb data
%   Read the /home/facsko/OMNIWeb/gapdist.dat file and calculate the 
%   gap distribution. Plot the distribution, the 365 days sum of 
%   distribution, and this sum again considering only gaps with a
%   threshold. 
% 
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2012
%   Finnish Meteorologycal Institute, Helsinki
%----------------------------------------------------------------------
%     
    % Array length
    N=4007;
    % Read the file
    fid=fopen('/home/facsko/OMNIWeb/gapdist-Minna.dat', 'r');   	
    % Reading data
    i=1;
    gapT=(1:N); 
    gapAny=(1:N);
    gapAny1=(1:N);
    gapAny2=(1:N);
    gapAny3=(1:N);
    gapAny4=(1:N); 
    gapAny5=(1:N);      
    gapAny10=(1:N);   
    gapAny30=(1:N);
    gapAny60=(1:N);
	strLine=fgetl(fid);
	while (feof(fid)==0)		
        gapT(i)=datenum(str2double(strLine(1:4)),0,str2double(strLine(6:8)),0,0,0);        
        for k=1:9,strLine=fgetl(fid);end;
        strLine=strLine(6:numel(strLine));
        s=0;      
        s2=0;
        s3=0;
        s4=0;
        s5=0;
        s10=0;
        s30=0;
        s60=0;
        if (numel(strLine)~=0)
            indexLine=[strfind(strLine,' '),numel(strLine)+1];           
            j=1;
            while j<=numel(indexLine)      
                if (j~=1)
                    dnIndex1=indexLine(j-1);
                else
                    dnIndex1=0;
                end;                            
                dn=str2double(strLine(dnIndex1+1:indexLine(j)-1));
                dv=str2double(strLine(indexLine(j)+1:indexLine(j+1)-1));
                s=s+dn*dv;               
                if (dv>=2),s2=s2+dn*dv;end;
                if (dv>=3),s3=s3+dn*dv;end;
                if (dv>=4),s4=s4+dn*dv;end;
                if (dv>=5),s5=s5+dn*dv;end;
                if (dv>=10),s10=s10+dn*dv;end;
                if (dv>=30),s30=s30+dn*dv;end;
                if (dv>=60),s60=s60+dn*dv;end;
                j=j+2;
             end;             
        end;     
        gapAny(i)=s;      
        gapAny2(i)=s2;
        gapAny3(i)=s3;
        gapAny4(i)=s4;
        gapAny5(i)=s5;
        gapAny10(i)=s10;
        gapAny30(i)=s30;
        gapAny60(i)=s60;
		i=i+1;           
	    strLine=fgetl(fid);
    end;
    fclose(fid);
     
     % Figure in the background   
     p = figure('visible','off');   
     % B plot          
     for i=1:N-364  
         gapAny(i)=sum(gapAny(i:i+364));        
         gapAny2(i)=sum(gapAny2(i:i+364));
         gapAny3(i)=sum(gapAny3(i:i+364));
         gapAny4(i)=sum(gapAny4(i:i+364));
         gapAny5(i)=sum(gapAny5(i:i+364));
         gapAny10(i)=sum(gapAny10(i:i+364));
         gapAny30(i)=sum(gapAny30(i:i+364));
         gapAny60(i)=sum(gapAny60(i:i+364));
     end;
     gapT=gapT(1:N-364);
     gapAny=gapAny(1:N-364)/60/24;  
     gapAny2=gapAny2(1:N-364)/60/24;
     gapAny3=gapAny3(1:N-364)/60/24;
     gapAny4=gapAny4(1:N-364)/60/24;
     gapAny5=gapAny5(1:N-364)/60/24;      
     gapAny10=gapAny10(1:N-364)/60/24;
     gapAny30=gapAny30(1:N-364)/60/24;
     gapAny60=gapAny60(1:N-364)/60/24;
    plot(gapT,gapAny,'-k'); datetick('x','yyyy'); grid on;
    set(gca,'XTick',datenum('2001-01-01'):365:datenum('2011-12-31'));
%    set(gca,'XTickLabel',{'2001','2002','2003','2004',...
%        '2005','2006','2007','2008','2009',...
%        '2010','2011'});
    axis([datenum('2001-01-01') datenum('2012-01-01') 0 100]);       
    title('Datagaps in OMNIWeb from 2001-02-01 to 2011-01-24');
    xlabel('Time [yyyy]');
    ylabel('Datagap length in 365 day intervall [day]');
    text(datenum(2001,4,1,0,0,0),95,'All/1 min','HorizontalAlignment','left','Color',[0 0 0]);    
    text(datenum(2001,4,1,0,0,0),90,'2 min','HorizontalAlignment','left','Color',[1 0 0]);
    text(datenum(2001,4,1,0,0,0),85,'3 min','HorizontalAlignment','left','Color',[0 1 0]);
    text(datenum(2001,4,1,0,0,0),80,'4 min','HorizontalAlignment','left','Color',[1 0 1]);
    text(datenum(2001,4,1,0,0,0),75,'5 min','HorizontalAlignment','left','Color',[0 0 1]);  
    text(datenum(2001,4,1,0,0,0),70,'10,30,60 min','HorizontalAlignment','left','Color',[0 0 0])
    hold on;
    plot(gapT,gapAny2,'-r');
    plot(gapT,gapAny3,'-g');
    plot(gapT,gapAny4,'-m');
    plot(gapT,gapAny5,'-b');
    plot(gapT,gapAny10,'--k');
    plot(gapT,gapAny30,'--k');    
    plot(gapT,gapAny60,'--k');
    hold off;
    % Saving result in an eps file
    print(p,'-depsc2',epsFilename);
    % Closing the plot box
    close;
    
    % Result
    [minGapAll,iGapAll]=min(gapAny); tGapAll=gapT(iGapAll);    
    [minGap2,iGap2]=min(gapAny2); tGap2=gapT(iGap2);    
    [minGap3,iGap3]=min(gapAny3); tGap3=gapT(iGap3);          
    [minGap4,iGap4]=min(gapAny4); tGap4=gapT(iGap4);    
    [minGap5,iGap5]=min(gapAny5); tGap5=gapT(iGap5);    
    [minGap10,iGap10]=min(gapAny10); tGap10=gapT(iGap10);    
    [minGap30,iGap30]=min(gapAny30); tGap30=gapT(iGap30);    
    [minGap60,iGap60]=min(gapAny60); tGap60=gapT(iGap60);        
    tGap=[tGapAll,tGap2,tGap3,tGap4,tGap5,tGap10,tGap30,tGap60];
    minGap=[minGapAll,minGap2,minGap3,minGap4,minGap5,minGap10,...
        minGap30,minGap60];     
    % Dump
    fid=fopen('gapdisttable-Minna.txt', 'w');   
        fprintf(fid,'# yyyymmdd  All  2min 3min 4min 5min 10min 30min 60min\n');
        for i=1:numel(gapT)
            fprintf(fid,'%s %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f  %4.1f  %4.1f\n',...
                datestr(gapT(i),'yyyy-mmm-dd'),gapAny(i),gapAny2(i),...
                gapAny3(i),gapAny4(i),gapAny5(i),gapAny10(i),gapAny30(i),...
                gapAny60(i));
        end;
    fclose(fid);
end

