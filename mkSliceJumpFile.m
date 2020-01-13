function [ error ] = mkSliceJumpFile( resultFilename )
%mkSliceJump Determine the jump between slices
%  Determine and study jumps between the slices. 
%
%  Developed by Gabor Facsko (facsko.gabor@csfk.mta.hu)
%  Geodetic and Geophysical Institute, RCAES, HAS, 2014
% 
%-----------------------------------------------------------------
%
    error=0;
    % Data path    
    root_path='/home/gfacsko/Projects/Matlab/ECLAT/';

    % Reading slice data
    t=zeros(1860,2);
    fid=fopen([root_path,'data/harri_list.txt'], 'r');    
    i=1;   
	strLine=fgetl(fid);
	while (feof(fid)==0)
		t(i,1)=datenum(strLine(13:25),'yyyymmdd_HHMM');
        t(i,2)=datenum(strLine(29:41),'yyyymmdd_HHMM');
        i=i+1;           
	    strLine=fgetl(fid);
    end;   
    t(i,1)=datenum(strLine(13:25),'yyyymmdd_HHMM');
    t(i,2)=datenum(strLine(29:41),'yyyymmdd_HHMM');
    fclose(fid);
    
    % Reading data dump
    d=load([root_path,'data/clo-full.dat']);
%   d=load([root_path,'data/clo-200202.dat']);
%   d=load([root_path,'products/orbitdump/clo-20020201-dump.dat']);
    d(:,6)=d(:,6)/10^6;
    d(:,10:12)=d(:,10:12)/10^3;
    d(:,15:17)=d(:,15:17)*10^9;
    % Load time
    fid=fopen([root_path,'data/clo-full.dat'], 'r');  
%    fid=fopen([root_path,'data/clo-200202.dat'], 'r');   
%    fid=fopen([root_path,'products/orbitdump/clo-20020201-dump.dat'], 'r');  
    i=1;   
	strLine=fgetl(fid);
	while (feof(fid)==0)
		d(i,1)=datenum(strLine(1:16),'yyyy-mm-ddTHH:MM');        
        i=i+1;           
	    strLine=fgetl(fid);
    end;   
    d(i,1)=datenum(strLine(1:16),'yyyy-mm-ddTHH:MM');  
    fclose(fid);
        
    % Couple slices and analysis    
    fid=fopen([root_path,'data/',resultFilename], 'w');
    for it=1:numel(t(:,1))
        % The search is if both of the values exist
        lLast=false;
        lFirst=false;
        % First value AFTER the slice starts
        [dvmin,dimin]=min(abs(d(:,1)-t(it,1)));
        if ((d(dimin,1)<t(it,1)) && (t(it,1)<d(numel(d(:,1)),1)))
            dimin=dimin+1;
            dvmin=abs(d(dimin,1)-t(it,1));           
        end;
        % Check whether the value appropriate
        if (dvmin*1440<6)
            % Save the first value
            iFirst=dimin;
            % Indicate its existence
            lFirst=true;
        end;
        % Last value BEFORE the slice ends
        [dvmin,dimin]=min(abs(d(:,1)-t(it,2)));
        if ((d(dimin,1)>t(it,2)) && (t(it,2)>d(1,1)))
            dimin=dimin-1;
            dvmin=abs(d(dimin,1)-t(it,2));           
        end;
        % Check whether the value appropriate
        if (dvmin*1440<6)
            % Save the last value
            iLast=dimin;
            % Indicated its existence
            lLast=true;
        end;
        % Save results if there are
        if (lFirst && lLast)
            % Density
            n=mean(d(iFirst:iLast,6));
            dn=sqrt(mean(d(iFirst:iLast,6).^2)-n^2);
            % Velocity
            d(iFirst:iLast,10)=sqrt(sum(d(iFirst:iLast,10:12).^2,2));
            v=mean(d(iFirst:iLast,10));
            dv=sqrt(mean(d(iFirst:iLast,10).^2)-v^2);
            % Magnetic field
            d(iFirst:iLast,15)=sqrt(sum(d(iFirst:iLast,15:17).^2,2));
            b=mean(d(iFirst:iLast,15));
            db=sqrt(mean(d(iFirst:iLast,15).^2)-b^2);
            error=fprintf(fid,...
                '%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\n',...
                d(iFirst,6),d(iLast,6),n,dn,...
                d(iFirst,10),d(iLast,10),v,dv,...
                d(iFirst,15),d(iLast,15),b,db);
        end;
    end;
    fclose(fid);
end

