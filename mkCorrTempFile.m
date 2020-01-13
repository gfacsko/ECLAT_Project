function [ corrFilename, Nrow ] = mkCorrTempFile(tStart,tEnd,isOMNI,isBz,strSuffix)
%mkCorrFile Create file for correlation calculation from OMNIWeb and 
%   Cluster magnetic field cdf files
%
%   tStart       : Correlation start
%   tEnd         : Correlation end
%   isBz         : GUMICS correlation using Bz
%   isOMNI       : OMNIWeb/GUMICS-4 correlation
%   corrFilename : Created correlation filename
%   strSuffix    : Extra string to distinguish the results
%
%   Developed by Gabor Facsko (facsko.gabor@mta.csfk.hu), 2014-2017
%   Geodetic and Geophysical Institute, RCAES, Sopron, Hungary
%----------------------------------------------------------------------
%
    % Initialisation
    omni_path='/home/facskog/OMNIWeb/';
    root_path='/home/facskog/Projectek/Matlab/ECLAT/';
    product_path=[root_path,'products/orbitdump/'];
    corrFilename='';
    Nrow=0;
    % Create a temporary file - OMNIWeb
    if (isOMNI)   
        [doyStart,fraction] = date2doy(tStart);
        [doyEnd,fraction] = date2doy(tEnd);
        doyStart=floor(doyStart);
        doyEnd=ceil(doyEnd);
        strSample='';
        % Special case: end of the year
        doyInterwall=[doyStart:doyEnd];
        if (doyStart>doyEnd),doyInterwall=[doyStart:365,1:doyEnd];end;
        secondYear=0;
        for doy=doyInterwall
            % DOY creation
            strDoy=num2str(doy);
            if (doy<10),strDoy=['0',strDoy];end;
            if (doy<100),strDoy=['0',strDoy];end;       
            % Year determination + 2nd year. The leap year was NOT
            % considered!!!
            if (doy<doyStart),secondYear=365;end;
            strYear=datestr(tStart+(doy-doyStart)+secondYear,'yyyy');      
            strSample=[strSample,strYear,strDoy,'.dat '];            
        end; 
    %     % GLIBCXX problem
    %     MatlabPath = getenv('LD_LIBRARY_PATH');
    %     setenv('LD_LIBRARY_PATH',getenv('PATH'));
        [status,result]=unix(['cd ',omni_path,'; cat $(ls ',...
            strSample,') > temp_corr.dat' ]);        
    %     % GLIBCXX problem            
    %     setenv('LD_LIBRARY_PATH',MatlabPath);
    end;
    
    if (~isOMNI)
        dateStart=floor(tStart);
        dateEnd=floor(tEnd);
        strSample='';
        for d=dateStart:dateEnd
            strSample=[strSample,'clo-',datestr(d,'yyyymmdd'),...
                '-dump.dat '];
        end;
        [status,result]=unix(['cd ',product_path,'; cat $(ls ',...
            strSample,') > orbit_temp_corr.dat' ]);
    end;
   
    % Read the temporary OMNIWeb or GUMICS file
    if (isOMNI)
        A=load([omni_path,'temp_corr.dat']);
        z=zeros(length(A(:,1)),1);
        t=datenum([A(:,1) z A(:,2) A(:,3) A(:,4) z]);
    else
        A=load([product_path,'orbit_temp_corr.dat']);  
        % Load time
        fid=fopen ([product_path,'orbit_temp_corr.dat'], 'r');    
        for it=1:numel(A(:,1))
            strLine=fgetl(fid);
            t=datenum(strLine(1:22),'yyyy-mm-ddTHH:MM:SS.FFF');
            A(it,1)=t;               
        end;
        fclose(fid);
        % Select n,vx,vy,vz,Bx,By,Bz        
        A=[A(:,1),A(:,6)/10^6,A(:,10:12)/1000,A(:,15:17)*10^9];        
        % Select n,v,B
        if (~isBz)
            % Select n,v,B
            A=[A(:,1),sqrt(A(:,6).^2+A(:,7).^2+A(:,8).^2),...
                sqrt(A(:,3).^2+A(:,4).^2+A(:,5).^2),A(:,2)];        
        else
            % Select vx,Bz,n
            A=[A(:,1),A(:,8),A(:,3),A(:,2)];
        end;
        % Intrapolation to one minut resolution
        B=zeros(5*numel(A(:,1)),4);
        ib=1;
        ia=1;
        while (ib<numel(B(:,1)) && ia<numel(A(:,1)))
            B(ib,:)=A(ia,:);
            % Step size
            dib=round((A(ia+1,1)-A(ia,1))*1440);           
            % Fill the subintervall
            for is=ib+1:ib+dib-1
                B(is,1)=A(ia,1)+(is-ib)/1440;
                B(is,2:4)=[-1,-1,-1];
            end;            
            ia=ia+1;
            ib=ib+dib;
        end;
        % Last elememt
        B(ib,:)=A(ia,:);      
        t=B(:,1);
    end;
    
     
    % Determine the first and last indexes  
    [ts,tiStart]=min(abs(t-tStart)); 
    [te,tiEnd]=min(abs(t-tEnd));    
    Nrow=tiEnd-tiStart+1;
    
    % Write correlation file
    strTstart=datestr(tStart,'yyyymmdd_HHMMSS');
    strTend=datestr(tEnd,'yyyymmdd_HHMMSS');
    if (isOMNI)
        bzStr='';
        if (isBz),bzStr='-bz';end;        
        corrFilename=['corr-',strTstart,'_',strTend,bzStr,'-temp.dat'];   
        fid=fopen([root_path,'data/',corrFilename], 'w');   
    else
        bzStr='';
        if (isBz),bzStr='-bz';end;
        corrFilename=['corr-',strTstart,'_',strTend,...
            bzStr,'-gumics',strSuffix,'-temp.dat'];                     
        fid=fopen([product_path,corrFilename], 'w');   
    end;
    
    % Writing data
    for i=tiStart:tiEnd
        if (isOMNI)
            fprintf(fid,'%i %3i %2i %2i %7.2f %7.2f %7.2f %7.1f %7.1f %7.1f %6.2f %7.f.\n',...
                A(i,1),A(i,2),A(i,3),A(i,4),A(i,5),A(i,6),A(i,7),...
                A(i,8),A(i,9),A(i,10),A(i,11),A(i,12));
        else
            strDate=[datestr(B(i,1),'yyyy-mm-ddTHH:MM:SS.FFF'),'Z'];
            fprintf(fid,'%s %7.2f %7.2f %7.2f\n',...
                strDate,B(i,2),B(i,3),B(i,4));
        end;
    end; 
    fclose(fid);    
    
    % Purge garbage
    if (isOMNI)
        [status,result]=unix(['rm ',omni_path,...
            '/temp_corr.dat']);
    else
        [status,result]=unix(['rm ',product_path,...
            '/orbit_temp_corr.dat']);
    end;
end

