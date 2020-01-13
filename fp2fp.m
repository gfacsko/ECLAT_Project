function [ error ] = fp2fp( fpDate1, fpDate2 )
%fp2fp Correct the quality factor of Tsyganenko model. 
%   The Tsyganenko tracing termination was determined badly. The quality
%   factor and the coordinates must be corrected in each files. 
%
%   fpDate1, fpDate2: dates
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2013
%
% -----------------------------------------------------------------
%
    error=0;    
    % Inospheric domain
    Niono=3.7;
    % Footprint filelength
    Nfp=290;
    
    % Paths
    root_path='/home/facsko/Projects/matlab/ECLAT/';
    
    % Preparing for launching    
    fpDate=[];
    for d=str2num(fpDate1(7:8)):str2num(fpDate2(7:8))
        strD=num2str(d);
        if (d<10),strD=['0',strD];end;
        fpDate=[fpDate;[fpDate1(1:6),strD]];
    end;
   
    % Read footprint file  
    for in=1:numel(fpDate(:,1))
        % Create/Reset array    
        Bfp=zeros(Nfp,38);   
        % Read footprint data
        fpFilename=[root_path,'products/footprints/footprint-',fpDate(in,:),'.dat'];
        Bfp=load(fpFilename);
        % Time :(
        fid=fopen (fpFilename, 'r'); 
        strLine=fgetl(fid);
        % Time index variable
        it=1;
        while (feof(fid)==0)
            t=datenum(str2num(strLine(1:4)),str2num(strLine(5:6)),...
                str2num(strLine(7:8)),str2num(strLine(10:11)),...
                str2num(strLine(13:14)),str2num(strLine(16:21)));       
            Bfp(it,1)=t;       
            strLine=fgetl(fid);
            it=it+1;
        end;
        % Last row
        t=datenum(str2num(strLine(1:4)),str2num(strLine(5:6)),...
            str2num(strLine(7:8)),str2num(strLine(10:11)),...
            str2num(strLine(13:14)),str2num(strLine(16:21)));       
        Bfp(it,1)=t;   
        fclose(fid);   

        % Status correction
        for is=1:it
            fpTsyStatus=0;
            % Northward correction
            if (sqrt(sum(Bfp(is,33:35).^2,2))<Niono)
                fpTsyStatus=fpTsyStatus+1;
            else
                Bfp(is,27:29)=[-1,-1,-1];
                Bfp(is,33:35)=[-1,-1,-1];
            end;
            % Southward correction
            if (sqrt(sum(Bfp(is,36:38).^2,2))<Niono)
                fpTsyStatus=fpTsyStatus+2;
            else
                Bfp(is,30:32)=[-1,-1,-1];
                Bfp(is,36:38)=[-1,-1,-1];
            end;
            Bfp(is,26)=fpTsyStatus;
           % Save results                        
           [status,result]=unix(['echo ',datestr(Bfp(is,1),'yyyymmddThh:MM:ss.000Z'),...
               ' ',num2str(Bfp(is,2:38)),' >> ',root_path,'data/footprint-',...
               fpDate(in,:),'-temp.new']);
        end;    

        % Formated output for each file
        [status,result]=unix(['cd ',root_path,...
            'data; ./footprint-filter.sh footprint-',fpDate(in,:),...
            '-temp.new ../products/footprint-',fpDate(in,:),'.new;rm ',root_path,...
            'data/footprint-',fpDate(in,:),'-temp.new']);
    end;
end

