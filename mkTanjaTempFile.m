function [ tempFilename, Nrow ] = mkTanjaTempFile(tStart,tEnd,omni_path)
%mkTanjaTempFile Create orbit file from OMNIWeb file
%   Create orbit file for the given orbit number from OMNIWeb daily files.
%
%   tStart       : Orbit start
%   tEnd         : Orbit end
%   omni_path    : OMNIWeb file path
%   tempFilename : Created temp filename
%   Nrow         : Row number
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2012
%   Finnish Meteorologycal Institute, Helsinki
%----------------------------------------------------------------------
%
    % Create a temporary file from the three daily files
    [doyStart,fraction] = date2doy(tStart);
    [doyEnd,fraction] = date2doy(tEnd);
    doyStart=floor(doyStart);
    doyEnd=floor(doyEnd);
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
    [status,result]=unix(['cd ',omni_path,'; cat $(ls ',strSample,...
        ') > temp_input.dat' ]);

    % Array declaration
    [status,result]=unix(['wc -l ',omni_path,'/temp_input.dat']);
    Nrow=str2num(result(1:findstr(result,' ')));
    A=zeros(Nrow,12);
    t=(1:Nrow);
    % Read the temporary OMNIWeb file
    fid=fopen([omni_path,'/temp_input.dat'], 'r');   
    % Reading data
    i=1;   
	strLine=fgetl(fid);
	while (feof(fid)==0)
		A(i,:) = sscanf(strLine,'%i %i %i %i %f %f %f %f %f %f %f %f\n');
        t(i)=datenum([A(i,1) 0 A(i,2) A(i,3) A(i,4) 0]);
        i=i+1;           
	    strLine=fgetl(fid);
    end;
%     A(i,:) = sscanf(strLine,'%i %i %i %i %f %f %f %f %f %f %f %f\n');
%     t(i)=datenum([A(i,1) 0 A(i,2) A(i,3) A(i,4) 0]);
    fclose(fid);
    
    % Determine the first and last indexes
    [ts,tiStart]=min(abs(t-tStart)); 
    [te,tiEnd]=min(abs(t-tEnd));
    Nrow=tiEnd-tiStart+1;
    
    % Write orbit file
    strTstart=datestr(tStart,'yyyymmdd_hhMMss');
    strTend=datestr(tEnd,'yyyymmdd_hhMMss');
    tempFilename=['temp_',strTstart,'_',strTend,'.dat'];   
    fid=fopen([omni_path,tempFilename], 'w');   
    % Reading data
    for i=tiStart:tiEnd
		fprintf(fid,'%i %3i %2i %2i %7.2f %7.2f %7.2f %7.1f %7.1f %7.1f %6.2f %7.f.\n',A(i,1),A(i,2),...
            A(i,3), A(i,4),A(i,5), A(i,6),A(i,7),A(i,8),A(i,9),A(i,10),...
            A(i,11),A(i,12));
    end; 
    fclose(fid);    
    
    % Purge garbage
    [status,result]=unix(['rm ',omni_path,'temp_input.dat']);
end

