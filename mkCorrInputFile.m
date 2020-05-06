function [ error ] = mkCorrInputFile(tStart,tEnd,isOMNI,isBz,strSuffix)
%mkCorrInputFile Creates correlation input files from OMNIWeb or 
%   GUMICS data
%
%   Read OMNIWeb or GUMICS data and interpolates. Creates 
%   validation plots. 
% 
%   tStart   : Start
%   tEnd     : End
%   isOMNI   : OMNIWeb correlation file?
%   isBz     : Use Bz component only
%   strSuffix: Extra string to distinguish the results
%
%   Developed by Gabor Facsko (facsko.gabor@mta.csfk.hu), 2014-2017
%   Geodetic and Geophysical Institute, RCAES, Sopron, Hungary
%----------------------------------------------------------------------
%   
    % Initialisation
    error=0;
    if (isOMNI)
        Thalf=30.;
    else
%        Thalf=150.;
        Thalf=30.;  
    end;
    % Default directories
    root_path='/home/facskog/Projectek/Matlab/ECLAT/'; 
    omni_path='/home/facskog/OMNIWeb/';
    data_path='/home/facskog/QSAS/';
    product_path=[root_path,'products/orbitdump/'];
    
    % Saving the result in the right subdirectory 
    strSubDir='OMNI-ClusterSC3-SW/';
    if ((~isOMNI) & (strcmp(strSuffix,'-msh')))
        strSubDir='GUMICS-ClusterSC3-MSH/';
    end; 
    if ((~isOMNI) & (strcmp(strSuffix,'-sw')))
        strSubDir='GUMICS-ClusterSC3-SW/';
    end; 
    if ((~isOMNI) & (strcmp(strSuffix,'-msph')))
        strSubDir='GUMICS-ClusterSC3-MSPH/';
    end;  
    if ((~isOMNI) & ((strcmp(strSuffix,'-bs'))|(strcmp(strSuffix,'-mp'))...
            |(strcmp(strSuffix,'-ns'))))
        strSubDir='GUMICS-ClusterSC3-BS/';
    end;  
       
    % Temporary Correlation file
    [corrTempFilename,Nrow]=mkCorrTempFile(tStart,tEnd,isOMNI,isBz,...
        strSuffix);
    
    % Array declaration
    if (isOMNI)
        A=load([root_path,'data/',corrTempFilename]);
    else
        A=load([product_path,corrTempFilename]);  
        % Load time
        fid=fopen ([product_path,corrTempFilename], 'r');    
        for it=1:numel(A(:,1))
            strLine=fgetl(fid);
            t=datenum(strLine(1:22),'yyyy-mm-ddTHH:MM:SS.FFF');
            A(it,1)=t;               
        end;
        fclose(fid);
        t=A(:,1);
    end;
    
    z=zeros(length(A(:,1)),1);
    bfgmArray=z; % Save Cluster B
    vcisArray=z; % Save Cluster V
    ncisArray=z; % Save Cluster n
    nefwArray=z; % Save Cluster nEFW
    if (isOMNI),t=datenum([A(:,1) z A(:,2) A(:,3) A(:,4) z]);end;

    % Interpolation
    if (isOMNI)
        % Interpolation
        p=0;
        m=0;
        for i=1:numel(A(:,1))
            % Plasma data interpolation
            if (A(i,12)~=9999999 && p>0)
                if (i>p+1)
                    for k=1:p          
                        A(i-p-1+k,8:12)=A(i-p-1,8:12)+k/(p+1)*...
                            (A(i,8:12)-A(i-p-1,8:12));
                    end;
                else
                    for k=1:p          
                        A(i-p-1+k,8:12)=A(i,8:12);
                    end;
                end;
                p=0;
            end;
            if (A(i,12)==9999999),p=p+1;end;        
            % IMF
            if (A(i,5)~=9999.99 && m>0)
                if (i>m+1)
                    for k=1:m      
                        A(i-m-1+k,5:7)=A(i-m-1,5:7)+k/(m+1)*...
                            (A(i,5:7)-A(i-m-1,5:7));                    
                    end;
                else
                    for k=1:m           
                        A(i-m-1+k,5:7)=A(i,5:7);                    
                    end;
                end;
                m=0;
            end;
            if (A(i,5)==9999.99),m=m+1;end; 
        end;
        % Datagaps at the end
        if (A(i,5)==9999.99)
            for k=1:m      
                A(i-m+k,5:7)=A(i-m,5:7);
            end; 
        end;
        if (A(i,12)==9999999)
            for k=1:p      
                A(i-p+k,8:12)=A(i-p,8:12);
            end; 
        end;
    else
        % Interpolation
        m=0;      
        for i=1:numel(A(:,1))
            % IMF
            if (A(i,2)~=-1 && m>0)
                if (i>m+1)
                    for k=1:m      
                        A(i-m-1+k,2:4)=A(i-m-1,2:4)+k/(m+1)*...
                            (A(i,2:4)-A(i-m-1,2:4));
                    end;
                else
                    for k=1:m                     
                        A(i-m-1+k,2:4)=A(i,2:4);                    
                    end;
                end;
                m=0;
            end;
            if (A(i,2)==-1.0),m=m+1;end; 
        end;
        % Datagaps at the end
        if (A(i,2)==-1.0)
            for k=1:m      
                A(i-m+k,2:4)=A(i-m,2:4);
            end; 
        end;       
    end;
    
    % Read Cluster FGM, CIS HIA and EFW data   
    for id=floor(tStart):ceil(tEnd)-1
        fgmFilename=['C3_CP_FGM_SPIN__',datestr(id,'yyyymmdd_HHMMSS_'),...
             datestr(id+1,'yyyymmdd_HHMMSS'),'_V140305.cdf'];
        fullFgmFilename=[data_path,'C3_CP_FGM_SPIN/',fgmFilename];
        cisFilename=['C3_CP_CIS-HIA_ONBOARD_MOMENTS__',...
            datestr(id,'yyyymmdd_HHMMSS_'),...
            datestr(id+1,'yyyymmdd_HHMMSS'),'_V161018.cdf'];
        fullCisFilename=[data_path,'C3_CP_CIS-HIA_ONBOARD_MOMENTS/',...
            cisFilename];
        efwFilename=['C3_CP_EFW_L3_P__',datestr(id,'yyyymmdd_HHMMSS_'),...
             datestr(id+1,'yyyymmdd_HHMMSS'),'_V*.cdf'];
        [status,result]=unix(['ls ',data_path,'C3_CP_EFW_L3_P/',efwFilename]);
        fullEfwFilename=result(1:numel(result)-1);
        if (id==floor(tStart))
            fgmCell = cdfread(fullFgmFilename,'Variable',...
               {['time_tags__C3_CP_FGM_SPIN'],...
               ['B_mag__C3_CP_FGM_SPIN'],...
               ['B_vec_xyz_gse__C3_CP_FGM_SPIN'],...
               ['sc_pos_xyz_gse__C3_CP_FGM_SPIN']},...
               'ConvertEpochToDatenum',true);
            cisCell = cdfread(fullCisFilename,'Variable',...
               {['time_tags__C3_CP_CIS-HIA_ONBOARD_MOMENTS'],...
               ['velocity_gse__C3_CP_CIS-HIA_ONBOARD_MOMENTS'],...
               ['density__C3_CP_CIS-HIA_ONBOARD_MOMENTS']},...
               'ConvertEpochToDatenum',true);  
           % Different EFW read
            efwCell = cdfread(fullEfwFilename,'Variable',...
               {['time_tags__C3_CP_EFW_L3_P'],...
               ['Spacecraft_potential__C3_CP_EFW_L3_P']},...
               'ConvertEpochToDatenum',true); 
            % Open cdf file
            efwCdfId = cdflib.open(fullEfwFilename);
            % Get info (maxRecord)
            info = cdflib.inquire(efwCdfId);
            efwTime = zeros(info.maxRec,1,'double');
            for iec=0:info.maxRec-1
                % Read record
                efwTemp = cdflib.getVarRecordData(efwCdfId,0,iec);
                % Convert to vector
                vecTemp = cdflib.epoch16Breakdown(efwTemp);
                % Convert to matlab number
                efwTime(iec+1) = datenum([vecTemp(1) vecTemp(2)...
                    vecTemp(3) vecTemp(4) vecTemp(5) vecTemp(6)]);
            end;
            % Save result
            efwTimeArray=efwTime;
        else
            fgmCell = [fgmCell;cdfread(fullFgmFilename,'Variable',...
               {['time_tags__C3_CP_FGM_SPIN'],...
               ['B_mag__C3_CP_FGM_SPIN'],...
               ['B_vec_xyz_gse__C3_CP_FGM_SPIN'],...
               ['sc_pos_xyz_gse__C3_CP_FGM_SPIN']},...
               'ConvertEpochToDatenum',true)];
            cisCell = [cisCell;cdfread(fullCisFilename,'Variable',...
               {['time_tags__C3_CP_CIS-HIA_ONBOARD_MOMENTS'],...
               ['velocity_gse__C3_CP_CIS-HIA_ONBOARD_MOMENTS'],...
               ['density__C3_CP_CIS-HIA_ONBOARD_MOMENTS']},...
               'ConvertEpochToDatenum',true)];
            % Different EFW read
            efwCell = [efwCell;cdfread(fullEfwFilename,'Variable',...
               {['time_tags__C3_CP_EFW_L3_P'],...
               ['Spacecraft_potential__C3_CP_EFW_L3_P']},...
               'ConvertEpochToDatenum',false)]; 
            % Open cdf file
            efwCdfId = cdflib.open(fullEfwFilename);
            % Get info (maxRecord)
            info = cdflib.inquire(efwCdfId);
            efwTime = zeros(info.maxRec,1,'double');
            for iec=0:info.maxRec-1
                % Read record
                efwTemp = cdflib.getVarRecordData(efwCdfId,0,iec);
                % Convert to vector
                vecTemp = cdflib.epoch16Breakdown(efwTemp);
                % Convert to matlab number
                efwTime(iec+1) = datenum([vecTemp(1) vecTemp(2)...
                    vecTemp(3) vecTemp(4) vecTemp(5) vecTemp(6)]);
            end;
            % Save result
            efwTimeArray=[efwTimeArray;efwTime];
        end;
        clear efwTemp;
        clear vecTemp;
        clear efwTime;
        % Close cdf file
        cdflib.close(efwCdfId);
    end;
    % Converting cells to double --- FGM
    fgm = cell2struct(fgmCell,{'time','b','bvec','scpos'},2);
    cis = cell2struct(cisCell,{'time','vvec','n'},2);
    efw = cell2struct(efwCell,{'time','vsc'},2);    
    % Transform variables
    bvec=[fgm.bvec];
    scpos=[fgm.scpos];
    vvec=[cis.vvec];
    n=[cis.n];        
    % Calculating the density using empitrical formula
    nvsc=[efw.vsc];    
    for ie = 1:length(nvsc)
        nvsc(ie) = 200*(-nvsc(ie)).^(-1.85);
    end;
    if (~isBz)
        % B
        b=sqrt(sum(bvec(1:3,:).^2,1));
        v=sqrt(sum(vvec(1:3,:).^2,1));
    else
        % Bz 
        b=bvec(3,:);
        v=vvec(1,:);
    end;
    tfgm=[fgm.time];
    tcis=[cis.time];
    % Temporary solution
    %tefw=[efw.time];
    tefw=efwTimeArray;
    % Clear unnecessary variables
    clear efwTimeArray;
    clear fgmCell;
    clear cisCell;
    clear efwCell;
    clear fgmFilename;
    clear cisFilename;
    clear efwFilename;
    clear fullFgmFilename;
    clear fullCisFilename;
    clear fullEfwFilename;
                    
    % Inputfile ---------------------------------------------------            
    corrInputFilename=[corrTempFilename(1:numel(corrTempFilename)-9),...
        '.dat'];   
 
    % Save results
    fid=fopen([root_path,'data/',strSubDir,corrInputFilename], 'w');    
    % Input file
    for j=1:numel(A(:,1))
        % Cluster FGM average
        [mLowFGM,iLowFGM]=min(abs(tfgm-(t(j)-Thalf/86400.)));        
        [mHighFGM,iHighFGM]=min(abs(tfgm-(t(j)+Thalf/86400.)));  
        % Cluster CIS HIA average
        [mLowCIS,iLowCIS]=min(abs(tcis-(t(j)-Thalf/86400.)));        
        [mHighCIS,iHighCIS]=min(abs(tcis-(t(j)+Thalf/86400.)));          
         % Cluster EFW average
        if (numel(tefw))
            [mLowEFW,iLowEFW]=min(abs(tefw-(t(j)-Thalf/86400.)));        
            [mHighEFW,iHighEFW]=min(abs(tefw-(t(j)+Thalf/86400.)));   
        end;
        if ((iLowFGM<iHighFGM && mLowFGM<Thalf/86400 && ...
                mHighFGM<Thalf/86400) && (iLowCIS<iHighCIS && ...
                mLowCIS<Thalf/86400 && mHighCIS<Thalf/86400))
            bfgm=mean(b(iLowFGM:iHighFGM));
            %  Substrack dipole if possible
            if (strcmp(strSuffix,'-msph'))
                RE=6371.2;
                pos=[mean(scpos(1,iLowFGM:iHighFGM)),...
                    mean(scpos(2,iLowFGM:iHighFGM)),...
                    mean(scpos(3,iLowFGM:iHighFGM))]/RE;
                [doy,frac]=date2doy(t(j));
                %%% GEOPACK_RECALC(year, dofy, hour, min, sec);
                GEOPACK_RECALC(str2num(datestr(t(j),'yyyy')),floor(doy),...
                str2num(datestr(t(j),'hh')),str2num(datestr(t(j),'MM')), 0);
                [XGSM,YGSM,ZGSM] = GEOPACK_GSMGSE (pos(1),pos(2),pos(3),-1);
                [BXGSM,BYGSM,BZGSM] = GEOPACK_IGRF_GSM (XGSM,YGSM,ZGSM);
                [BXGSE,BYGSE,BZGSE] = GEOPACK_GSMGSE (BXGSM,BYGSM,BZGSM,1);
                bfgm=bfgm-BZGSE;
                A(j,2)=A(j,2)-BZGSE;
            end;
            % End of dipole calculations
            vcis=mean(v(iLowCIS:iHighCIS));
            ncis=mean(n(iLowCIS:iHighCIS));
            if (numel(tefw) && (iLowEFW<iHighEFW && ...
                mLowEFW<Thalf/86400 && mHighEFW<Thalf/86400)),               
                nefw=mean(nvsc(iLowEFW:iHighEFW)); % At kell szamolni
            end;
            % Save Cluster B
            bfgmArray(j)=bfgm;
            vcisArray(j)=vcis;
            ncisArray(j)=ncis;
            if (numel(tefw) && (iLowEFW<iHighEFW && mLowEFW<Thalf/86400 && ...
                    mHighEFW<Thalf/86400)),
                nefwArray(j)=nefw;
            end;
            % Save OMNIWeb/GUMICS data
            if (isOMNI)
                % OMNIWeb data
                if (~isBz)
                    % B, V, n
                    fprintf(fid,'%s\t%4.1f\t%4.1f\t%4.1f\t%4.1f\n',...
                        datestr(t(j),'yyyy-mm-ddTHH:MM:SS.000Z'),...
                        sqrt(sum(A(j,5:7).^2,2)),...
                        sqrt(sum(A(j,8:10).^2)),A(j,11),bfgm);   
                else
                    % Bz, Vx, n
                    fprintf(fid,'%s\t%4.1f\t%4.1f\t%4.1f\t%4.1f\n',...
                        datestr(t(j),'yyyy-mm-ddTHH:MM:SS.000Z'),...
                        A(j,7),A(j,8),A(j,11),bfgm);   
                end;
            else
                % GUMICS data
                if (~numel(tefw) || ~exist('nefw','var')),nefw=-1;end;
                fprintf(fid,'%s\t%4.1f\t%4.1f\t%4.1f\t%4.1f\t%4.1f\t%4.1f\t%4.1f\n',...
                    datestr(t(j),'yyyy-mm-ddTHH:MM:SS.000Z'),...
                    A(j,2),A(j,3),A(j,4),bfgm,vcis,ncis,nefw);
            end;
         end;
    end;
    fclose(fid);   

    % Purge garbage
    if (isOMNI)
        [status,result]=unix(['rm ',root_path,'data/',...
            corrTempFilename]);
    else
        [status,result]=unix(['rm ',product_path,...
            corrTempFilename]);
    end;
    
    % Interpolate data gap in Cluster data - B, V, n     
    bfgmArray = getInterpolatedData(bfgmArray);
    vcisArray = getInterpolatedData(vcisArray);
    ncisArray = getInterpolatedData(ncisArray);    
    if (numel(tefw) && (iLowEFW<iHighEFW && mLowEFW<Thalf/86400 && ...
        mHighEFW<Thalf/86400))
        nefwArray = getInterpolatedData(nefwArray);
    end;
    
    % Figure in the background   
    p = figure('visible','off');   
    % B plot
    subplot(3,1,1); 
    if (isOMNI)
        if (~isBz)
            plot(t,sqrt(sum(A(:,5:7).^2,2)),'-k');
        else
            plot(t,A(:,7),'-k');
        end;
    end;
    if (~isOMNI),plot(t,A(:,2),'-k');end;
    hold on;
    plot(t,bfgmArray,'-r');
    hold off;   
    datetick('x','HH:MM'); grid on;
    if (isOMNI)
        if (~isBz)
            axis([t(1) t(numel(t)) ...
                5*floor(min(sqrt(sum(A(:,5:7).^2,2)))/5) ...
                5*round(max(sqrt(sum(A(:,5:7).^2,2)))/5+1)]);  
            title(['B and V from OMNIWeb from ',...
                datestr(t(1),'yyyymmdd HH:MM'),' to ',...
                datestr(t(numel(t)),'yyyymmdd HH:MM')]);
        else
            axis([t(1) t(numel(t)) ...
                 5*floor(min(A(:,7))/5) ...
                 5*round(max(A(:,7))/5+1)]);   
            title(['B_z, V_x and n from OMNIWeb from ',...
                datestr(t(1),'yyyymmdd HH:MM'),' to ',...
                datestr(t(numel(t)),'yyyymmdd HH:MM')]);
        end;
    else
        if (~isBz)
            axis([t(1) t(numel(t)) ... 
                5*floor(min(A(:,2))/5) ...
                5*round(max(A(:,2))/5+1)]);    
            title(['B and V from GUMICS from ',...
                datestr(t(1),'yyyymmdd HH:MM'),' to ',...
                datestr(t(numel(t)),'yyyymmdd HH:MM')]);
        else
            axis([t(1) t(numel(t)) ...
                10*floor(min(min(bfgmArray),min(A(:,2)))/10) ...
                10*round(max(max(bfgmArray),max(A(:,2)))/10+1)]);  
            if (strcmp(strSuffix,'-sw')),
                axis([t(1) t(numel(t)) -10 15]);
            end; 
            if (strcmp(strSuffix,'-msh')),
                axis([t(1) t(numel(t)) -30 20]);
            end;             
            if (strcmp(strSuffix,'-ns')),
                axis([t(1) t(numel(t)) -10 10]);
            end;  
            title(['B_z, V_x and n from GUMICS from ',...
                datestr(t(1),'yyyymmdd HH:MM'),' to ',...
                datestr(t(numel(t)),'yyyymmdd HH:MM')]);
            text(0.0125,0.9,'(a)','Units','Normalized');
        end;
    end;   
%        xlabel('Time [HH:MM]');
    if (~isBz)
        ylabel('B [nT]');              
    else
        ylabel('B_z [nT]'); 
    end;
    % V plot
    subplot(3,1,2);     
    if (isOMNI)
        if (~isBz)
            plot(t,-sqrt(sum(A(:,8:10).^2,2)),'-k');
            datetick('x','HH:MM'); grid on;
            axis([t(1) t(numel(t))...
                -50*floor(max(sqrt(sum(A(:,8:10).^2,2)))/50+1) 0]);  
                % 50*round(max(A(minIndex:maxIndex,8))/50+1)
        else
            plot(t,A(:,8),'-k');
            datetick('x','HH:MM'); grid on;
            axis([t(1) t(numel(t)) 50*floor(min(A(:,8))/50) 0]);               
        end;
    else
        if (~isBz)
            plot(t,-A(:,3),'-k');
        else
            plot(t,A(:,3),'-k');
            hold on;
            plot(t,vcisArray,'-r');
            hold off;   
        end;
        datetick('x','HH:MM'); grid on;
        if (~isBz)
            axis([t(1) t(numel(t)) -50*floor(max(A(:,3))/50+1) 0]);         
        else
            axis([t(1) t(numel(t)) ...
                10*floor(min(min(vcisArray),min(A(:,3)))/10) ...
                10*round(max(max(vcisArray),max(A(:,3)))/10+1)]);  
            if (strcmp(strSuffix,'-sw')),
                axis([t(1) t(numel(t)) -800 0]);  
            end;
            if (strcmp(strSuffix,'-msh')),
                axis([t(1) t(numel(t)) -400 0]);  
            end;
            if (strcmp(strSuffix,'-ns')),
                axis([t(1) t(numel(t)) -200 400]);
            end; 
            text(0.0125,0.9,'(b)','Units','Normalized');
        end;
    end;        
    
%    xlabel('Time [HH:MM]');
    if (~isBz)
        ylabel('V [km/s]');     
    else  
        ylabel('V_x [km/s]');
    end;
    % n plot
    subplot(3,1,3); 
    if (isOMNI)
        plot(t,A(:,11),'-k');         
        datetick('x','HH:MM'); grid on;
        axis([t(1) t(numel(t)) 10*floor(min(A(:,11))/10) ...
            10*round(max(A(:,11))/10+1)]);
    else
        if (~isBz)
            plot(t,A(:,4),'-k');
        else
            plot(t,A(:,4),'-k');
            hold on;
            plot(t,ncisArray,'-r');
            if (numel(tefw))
                plot(t,nefwArray,'-b');
            end;
            hold off;   
        end;    
        datetick('x','HH:MM'); grid on;
        if (~isBz)
            axis([t(1) t(numel(t)) 10*floor(min(A(:,4))/10) ...
                10*round(max(A(:,4))/10+1)]);
        else
            axis([t(1) t(numel(t)) ...
                10*floor(min(min(min(ncisArray),min(nefwArray)),...
                min(A(:,4)))/10) 10*round(max(max(max(ncisArray),...
                max(nefwArray)),max(A(:,4)))/10+1)]);                                    
            text(0.0125,0.9,'(c)','Units','Normalized');
            if (strcmp(strSuffix,'-sw')), % Paper
                axis([t(1) t(numel(t)) 0 10]);    
            end;
            if (strcmp(strSuffix,'-msh')), % Paper
                axis([t(1) t(numel(t)) 0 30]);    
            end;
            if (strcmp(strSuffix,'-ns')), % Paper
                axis([t(1) t(numel(t)) 0 2]);
            end; 
        end;    
    end;
    xlabel('Time [HH:MM]');
    ylabel('n [nT]');    
    % Saving result in an eps file
    strTstart=datestr(t(1),'yyyymmdd_HHMMSS');
    strTend=datestr(t(numel(t)),'yyyymmdd_HHMMSS');   
    if (isOMNI)
        bzStr='';
        if (isBz),bzStr='-bz';end;
        print(p,'-depsc2',[root_path,'images/',strSubDir,'corr-',...
            strTstart,'_',strTend,bzStr,'.eps']);
    else
        bzStr='';
        if (isBz),bzStr='-bz';end;
        print(p,'-depsc2',[root_path,'images/',strSubDir,'corr-',...
            strTstart,'_',strTend,bzStr,'-gumics',strSuffix,'.eps']);
    end;   
    % Closing the plot box
    close;
end

