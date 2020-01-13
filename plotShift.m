function [ error ] = plotShift( epsFilename )
%plotShift Plot the timeshift in OMNIWeb data
%   Read the /home/facsko/OMNIWeb/full.dat file and calculate the OMNIWeb
%   timeshift until the subsolar point. Plot the number as a function of
%   time. 
% 
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2012
%   Finnish Meteorologycal Institute, Helsinki
%----------------------------------------------------------------------
%   
    % Array length
    error=0;
    N=446412;
    A=zeros(N,12);
    t=(1:N);
    s=(1:N);
    d=(1:N-5);
    % Read the file
%    fid=fopen('/home/gfacsko/OMNIWeb/2002364.dat','r'); 
    fid=fopen('/home/gfacsko/OMNIWeb/full.dat','r');   
    % Reading data
    i=1;   
	strLine=fgetl(fid);
	while (feof(fid)==0 && i<N)  % 
		indexLine=strfind(strLine,' ');
        A(i,:) = sscanf(strLine,'%i %i %i %i %f %f %f %f %f %f %f %f\n');
        t(i)=datenum([A(i,1) 0 A(i,2) A(i,3) A(i,4) 0]);
%         s(i)=(getSubsolar(sqrt(A(i,5)^2+A(i,6)^2+A(i,7)^2),A(i,8),A(i,11))-32)/A(i,8)*6380;
        B=sqrt(A(i,5)^2+A(i,6)^2+A(i,7)^2);
        V=sqrt(A(i,8)^2+A(i,9)^2+A(i,10)^2);        
        costh=(A(i,5)*A(i,8)+A(i,6)*A(i,9)+A(i,7)*A(i,10))/B/V;
        Rt=getSubsolar2(B,A(i,7),V,costh,A(i,11),A(i,12));
        if (abs(Rt)>20),Rt=20;end;
        s(i)=(Rt-32)/A(i,8)*6380;
        if (i>5)
            d(i-5)=s(i)-s(i-5);
            if (24*3600*(t(i)-t(i-5))>300),d(i-5)=0;end;
        end;
		i=i+1;           
	    strLine=fgetl(fid);
    end;
    A(i,:) = sscanf(strLine,'%i %i %i %i %f %f %f %f %f %f %f %f\n');
    t(i)=datenum([A(i,1) 0 A(i,2) A(i,3) A(i,4) 0]);
%     s(i)=(getSubsolar(sqrt(A(i,5)^2+A(i,6)^2+A(i,7)^2),A(i,8),A(i,11))-32)/A(i,8)*6380;
    B=sqrt(A(i,5)^2+A(i,6)^2+A(i,7)^2);
    V=sqrt(A(i,8)^2+A(i,9)^2+A(i,10)^2);
    costh=(A(i,5)*A(i,8)+A(i,6)*A(i,9)+A(i,7)*A(i,10))/B/V;
    s(i)=(getSubsolar2(B,A(i,7),V,costh,A(i,11),A(i,12))-32)/A(i,8)*6380;
    d(i-5)=s(i)-s(i-5);
    fclose(fid); 
    
    % Figure in the background   
    p = figure('visible','off');   
    % Time shift plot          
    plot(t,s/60,'.k'); datetick('x','yyyymm');  set(gca,'FontSize',10); 
    grid on; 
    %set(axes_handle,'XGrid','on'); % Only X axis grid lines
    axis([datenum('2002-02-01') datenum('2003-01-31') -2 8]);     
    %set(gca,'XTick',datenum('2002-02-01'):60:datenum('2003-02-01'));
    %set(gca,'XTickLabel',{'200202','200204','200206','200208',...
    %   '200210','200212','200302'});   
    set(gca,'FontSize',15);
    title('\fontsize{16}Timeshift in OMNIWeb data from 2002-02-01 to 2003-01-31');
    xlabel('\fontsize{20}Time [yyyymm]');
    ylabel('\fontsize{20}Time shift [min]');
%     text(datenum(2002,3,1,0,0,0),7,'Timeshift','HorizontalAlignment','left','Color',[0 0 0]);    
%     text(datenum(2002,3,1,0,0,0),6,'Difference','HorizontalAlignment','left','Color',[0 0 1]);
    hold on;
    plot(t(6:numel(t)),d/60,'.b');
    hold off;
    % Saving result in an eps file
    print(p,'-depsc2',epsFilename);
    % Closing the plot box
    close;
end

