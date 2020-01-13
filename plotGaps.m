function [ tGap, minGap ] = plotGaps( epsFilename )
%plotGaps Plot the number of gaps in OMNIWeb data
%   Read the /home/facsko/OMNIWeb/gaplist.dat file and calculate the 
%   gaps duration for 365 days. Plot the number as a function of time. 
% 
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2012-2015
%   Finnish Meteorologycal Institute, Helsinki, Finland
%   Geodetic and Geophysical Institute, RCAES, HAS, Sopron, Hungary
%----------------------------------------------------------------------
%   
    % Array length
    N=4007;
    % Read the file
    fid=fopen('/home/gfacsko/OMNIWeb/gaplist-Minna.dat', 'r');   
	% Skiping header
	strLine = fgetl(fid);   
    % Reading data
    i=1;
    gapT=(1:N);
    gapBx=(1:N);
    gapVx=(1:N);
%    gapN=(1:N);
%    gapH=(1:N);
    gapAny=(1:N);
	strLine=fgetl(fid);
	while (feof(fid)==0)
		indexLine=strfind(strLine,' ');
        gapT(i)=datenum(str2num(strLine(1:indexLine(1)-1)),0,...
            str2num(strLine(indexLine(1)+1:indexLine(2)-1)),0,0,0);
        gapBx(i)=str2double(strLine(indexLine(2)+1:indexLine(3)-1));
        gapVx(i)=str2double(strLine(indexLine(5)+1:indexLine(6)-1));
%       gapN(i)=str2double(strLine(indexLine(8)+1:indexLine(9)-1));        
%       gapH(i)=str2double(strLine(indexLine(9)+1:indexLine(10)-1));
        gapAny(i)=str2double(strLine(indexLine(10)+1:numel(strLine)));
		i=i+1;           
	    strLine=fgetl(fid);
    end;
    fclose(fid);
    
    % Figure in the background   
    p = figure('visible','off');   
    % B plot          
    for i=1:N-364 
        gapBx(i)=sum(gapBx(i:i+364));
        gapVx(i)=sum(gapVx(i:i+364));
%        gapN(i)=sum(gapN(i:i+364));
%        gapH(i)=sum(gapH(i:i+364));
        gapAny(i)=sum(gapAny(i:i+364));
    end;
    gapT=gapT(1:N-364);
    gapBx=gapBx(1:N-364)/60/24;
    gapVx=gapVx(1:N-364)/60/24;
%    gapN=gapN(1:N-364)/60/24;
%    gapH=gapH(1:N-364)/60/24;
    gapAny=gapAny(1:N-364)/60/24;
    plot(gapT,gapAny,'-k'); datetick('x','yyyy'); grid on;
   set(gca,'XTick',datenum('2001-01-01'):365:datenum('2012-01-01'));
   set(gca,'XTickLabel',{'2001','2002','2003','2004',...
       '2005','2006','2007','2008','2009','2010','2011','2012'});
    axis([datenum('2001-01-01') datenum('2011-12-31') 0 100]);     
    set(gca,'FontSize',15);
    title('\fontsize{18}Datagaps in OMNIWeb from 20010201 to 20110124');
    xlabel('\fontsize{20}Time [yyyy]');
    ylabel('\fontsize{20}Datagap length in 365 day intervall [day]');
    text(datenum(2001,4,1,0,0,0),95,'\fontsize{20}Total',...
        'HorizontalAlignment','left','Color',[0 0 0]);    
    text(datenum(2001,4,1,0,0,0),85,'\fontsize{20}B_x,B_y,B_z',...
        'HorizontalAlignment','left','Color',[0 0 1]);
    text(datenum(2001,4,1,0,0,0),75,'\fontsize{20}V_x,V_y,V_z,n,T',...
        'HorizontalAlignment','left','Color',[1 0 0]);
    hold on;
    plot(gapT,gapBx,'-b');
    plot(gapT,gapVx,'-r');
%    plot(gapT,gapN,'-g');    
%    plot(gapT,gapH,'-b');
    hold off;
    % Saving result in an eps file
    print(p,'-depsc2',epsFilename);
    % Closing the plot box
    close;
    
    % Result
    [minGap,iGap]=min(gapAny);        
    tGap=gapT(iGap);    
    % Dump
    fid=fopen('gaptable-Minna.txt', 'w');   
        fprintf(fid,'# yyyymmdd  Bx   Vx   any\n');
        for i=1:numel(gapT)
            fprintf(fid,'%s %4.1f %4.1f %4.1f\n',datestr(gapT(i),...
                'yyyy-mmm-dd'),gapBx(i),gapVx(i),gapAny(i));
        end;
    fclose(fid);
end

