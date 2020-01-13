function [ error ] = plotGUMICS( )
%plotGaps Compare Bz from OMNIWeb data and GUMICS4 simulations
%   Read OMNIWeb data, Cluster positions and GUMICS simulation results. 
%   A plot of Bz created for comparision. 
% 
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi), 2012
%   Finnish Meteorologycal Institute, Helsinki
%----------------------------------------------------------------------
%   
    % Default directories
    root_path='/home/facsko/Projects/matlab/ECLAT/';
    fgm_path='/home/facsko/QSAS/C1_CP_FGM_SPIN/';
    cis_path='/home/facsko/QSAS/C1_CP_CIS-HIA_ONBOARD_MOMENTS/';
    data_path='/home/facsko/QSAS/C1_CP_AUX_POSGSE_1M/';
    omni_path='/home/facsko/OMNIWeb/';
    sim_path='/home/facsko/GUMICS-4/orbit267-nodiv/';
    sim2_path='/home/facsko/GUMICS-4/267-*/';
    % Orbit number
    Norb=267;
    % Slice number
%     Nslice=6;
    % Start and end time
    tStart=datenum(2002,3,20,20,0,0); % datenum(2002,3,21,3,0,0); % 
    tEnd=datenum(2002,3,23,5,3,0); % datenum(2002,3,21,12,3,0);  % 
    
    % Read Cluster FGM file
    fgm = readCefFGM(fgm_path,'','C1_CP_FGM_SPIN__20020320_000000_20020323_090000_V101201.cef',tStart,tEnd);
    % read Cluster CIS file
    cis = readCefCIS(cis_path,'','C1_CP_CIS-HIA_ONBOARD_MOMENTS__20020320_200000_20020323_050400_V100214.cef',tStart,tEnd);
    % Read orbit data ----------------------------------------------------
    pos=readCefPos(data_path,'','C1_CP_AUX_POSGSE_1M__20020320_000000_20020324_000000_V091203.cef',tStart,tEnd);    
    
%     % Couple orbit and orbit simulation data ---------------------------
%     [status,result]=unix(['rm ',root_path,'pointfiles/orbit',num2str(Norb),'-dump.dat']);
%     [status,result]=unix(['cd ',sim_path,';ls mstate20020320_2* mstate2002032[1-3]*|sort']);%     
%     fnStart=strfind(result,'mstate')+6;
%     fnEnd=strfind(result,'.hc')-1;
%     tGUMICS=(1:numel(fnStart));
%     bzGUMICS=(1:numel(fnStart));
%     for i=1:numel(fnStart)
%         timeStr=result(fnStart(i):fnEnd(i));
%         tcl=datenum([str2num(timeStr(1:4)) str2num(timeStr(5:6))...
%             str2num(timeStr(7:8)) str2num(timeStr(10:11))...
%             str2num(timeStr(12:13)) str2num(timeStr(14:15))]);
%         tGUMICS(i)=tcl;
%         [vmin,imin]=min(abs(pos.time-tcl));
%         [datestr(tcl),'  ',datestr(pos.time(imin))]      
%         % Create point file
%         fid=fopen([sim_path,'temp_pointfile.dat'], 'w');   
%             fprintf(fid,'%i\t%10i\t%10i\n',pos.x(imin)*1000,pos.y(imin)*1000,pos.z(imin)*1000);
%         fclose(fid);
%         [status,result2]=unix(['cd ',sim_path,'; echo ',datestr(tcl,'yyyy-mm-ddThh:MM:ss.000Z'),' $(hcintpol -n -v n,vx,Bz,B ',result(fnStart(i)-6:fnEnd(i)+3),' < temp_pointfile.dat) >> ',root_path,'pointfiles/orbit',num2str(Norb),'-dump.dat; rm temp_pointfile.dat']);
% %         indexLine=strfind(result2,' ');
% %         bzGUMICS(i)=str2num(result2(indexLine(numel(indexLine)):numel(result2)))*1000000000;
%     end;
    % Read dumped data on the orbit of Cluster SC1
    fid=fopen([root_path,'pointfiles/orbit',num2str(Norb),'-dump.dat'], 'r');       
    Ngumics=558;
    tGUMICS=(1:Ngumics);
    nGUMICS=(1:Ngumics);
    vxGUMICS=(1:Ngumics);
    bzGUMICS=(1:Ngumics); 
    bGUMICS=(1:Ngumics);
    for i=1:Ngumics
        strLine = fgetl(fid);
        indexLine=strfind(strLine,' ');       
        tGUMICS(i)=datenum(str2num(strLine(1:4)),str2num(strLine(6:7)),...
            str2num(strLine(9:10)),str2num(strLine(12:13)),...
            str2num(strLine(15:16)),0);
        nGUMICS(i)=str2num(strLine(indexLine(4):indexLine(5)))/10^6;
        vxGUMICS(i)=str2num(strLine(indexLine(5):indexLine(6)))/1000;
        bzGUMICS(i)=str2num(strLine(indexLine(6):indexLine(7)))*10^9;
        bGUMICS(i)=str2num(strLine(indexLine(7):numel(strLine)))*10^9;
    end;
    fclose(fid);    
    
%      % Couple orbit and sliced simulation data -------------------------
%     [status,result]=unix(['rm ',root_path,'pointfiles/slices',num2str(Norb),'-dump.dat']);
%     [status,result]=unix(['ls ',sim2_path,'mstate20020320_2* ',sim2_path,'mstate2002032[1-3]*|sort'])   
%     fnStart=strfind(result,'mstate')+6;
%     fnEnd=strfind(result,'.hc')-1;
%     tSLICE=(1:numel(fnStart));
%     bzSLICE=(1:numel(fnStart));
%     for i=1:numel(fnStart)
%         timeStr=result(fnStart(i):fnEnd(i));
%         tcl=datenum([str2num(timeStr(1:4)) str2num(timeStr(5:6))...
%             str2num(timeStr(7:8)) str2num(timeStr(10:11))...
%             str2num(timeStr(12:13)) str2num(timeStr(14:15))]);
%          tSLICE(i)=tcl;
%          [vmin,imin]=min(abs(pos.time-tcl));
%          [datestr(tcl),'  ',datestr(pos.time(imin))]      
%          % Create point file
%          fid=fopen([root_path,'pointfiles/temp_pointfile.dat'], 'w');   
%              fprintf(fid,'%i\t%10i\t%10i\n',pos.x(imin)*1000,pos.y(imin)*1000,pos.z(imin)*1000);
%          fclose(fid);
%          [status,result2]=unix(['cd ',root_path,'pointfiles;echo ',datestr(tcl,'yyyy-mm-ddThh:MM:ss.000Z'),' $(hcintpol -n -v n,vx,Bz,B ',result(fnStart(i)-6-60:fnEnd(i)+3),' < temp_pointfile.dat) >> ',root_path,'pointfiles/slices',num2str(Norb),'-dump.dat; rm temp_pointfile.dat']);
% % %         indexLine=strfind(result2,' ');
% % %         bzGUMICS(i)=str2num(result2(indexLine(numel(indexLine)):numel(result2)))*1000000000;
%     end;        
    
    % Read sliced dumped data on the orbit of Cluster SC1
    fid=fopen([root_path,'pointfiles/slices',num2str(Norb),'-dump.dat'], 'r');       
    Nslice=785;
    tSLICE=(1:Nslice);
    nSLICE=(1:Nslice);
    vxSLICE=(1:Nslice);
    bzSLICE=(1:Nslice); 
    bSLICE=(1:Nslice);
    for i=1:Nslice
        strLine = fgetl(fid);
        indexLine=strfind(strLine,' ');       
        tSLICE(i)=datenum(str2num(strLine(1:4)),str2num(strLine(6:7)),...
            str2num(strLine(9:10)),str2num(strLine(12:13)),...
            str2num(strLine(15:16)),0);
        nSLICE(i)=str2num(strLine(indexLine(4):indexLine(5)))/10^6;
        vxSLICE(i)=str2num(strLine(indexLine(5):indexLine(6)))/1000;
        bzSLICE(i)=str2num(strLine(indexLine(6):indexLine(7)))*10^9;
        bSLICE(i)=str2num(strLine(indexLine(7):numel(strLine)))*10^9;
    end;
    fclose(fid); 
    
    % Figure in the background --------------------------------------
    p = figure('visible','off');   
    % Bz plot         
    subplot(4,1,1); plot(fgm.time,fgm.bz,'.k','MarkerSize',1); datetick('x','HH:MM'); grid on;    
    axis([fgm.time(1) fgm.time(numel(fgm.time)) 5*floor(min([fgm.bz,bzGUMICS,bzSLICE])/5) ...
        5*round(max([fgm.bz,bzGUMICS,bzSLICE])/5+1)]);       
    title(['Cluster vs GUMICS-4 orbit simulations from ',...
        datestr(fgm.time(1),'yyyymmdd hh:MM'),' to ',...
        datestr(fgm.time(numel(fgm.time)),'yyyymmdd hh:MM')]);
%     xlabel('Time [HH:MM]');
    ylabel('B_z [nT]');
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.9,'B_z Cluster',...
%         'HorizontalAlignment','left','Color',[0 0 0]);    
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.8,...
%         'B_z orbit','HorizontalAlignment','left','Color',[1 0 0]);
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.7,...
%         'B_z slices','HorizontalAlignment','left','Color',[0 0 1]);
    hold on;
    plot(tGUMICS,bzGUMICS,'.r'); 
    plot(tSLICE,bzSLICE,'.b'); 
    hold off;
    % B plot         
    subplot(4,1,2); plot(fgm.time,sqrt(fgm.bx.^2+fgm.by.^2+fgm.bz.^2),'.k','MarkerSize',1); 
    datetick('x','HH:MM'); grid on;    
    axis([fgm.time(1) fgm.time(numel(fgm.time)) 5*floor(min([sqrt(fgm.bx.^2+fgm.by.^2+fgm.bz.^2),bGUMICS,bSLICE])/5) ...
        5*round(max([sqrt(fgm.bx.^2+fgm.by.^2+fgm.bz.^2),bGUMICS,bSLICE])/5+1)]);         
%     xlabel('Time [HH:MM]');
    ylabel('B [nT]');
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.9,'B_z Cluster',...
%         'HorizontalAlignment','left','Color',[0 0 0]);    
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.8,...
%         'B_z orbit','HorizontalAlignment','left','Color',[1 0 0]);
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.7,...
%         'B_z slices','HorizontalAlignment','left','Color',[0 0 1]);
    hold on;
    plot(tGUMICS,bGUMICS,'.r'); 
    plot(tSLICE,bSLICE,'.b'); 
    hold off;
    % CIS n plot         
    subplot(4,1,3); plot(cis.time,cis.n,'.k','MarkerSize',1); datetick('x','HH:MM'); grid on;    
    axis([cis.time(1) cis.time(numel(cis.time)) 5*floor(min([cis.n,nGUMICS,nSLICE])/5) ...
        5*round(max([cis.n,nGUMICS,nSLICE])/5+1)]);         
%     xlabel('Time [HH:MM]');
    ylabel('n [cm^{-3}]');
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.9,'B_z Cluster',...
%         'HorizontalAlignment','left','Color',[0 0 0]);    
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.8,...
%         'B_z orbit','HorizontalAlignment','left','Color',[1 0 0]);
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.7,...
%         'B_z slices','HorizontalAlignment','left','Color',[0 0 1]);
    hold on;
    plot(tGUMICS,nGUMICS,'.r'); 
    plot(tSLICE,nSLICE,'.b'); 
    hold off;
    % CIS n plot         
    subplot(4,1,4); plot(cis.time,cis.vx,'.k','MarkerSize',1); datetick('x','HH:MM'); grid on;    
    axis([cis.time(1) cis.time(numel(cis.time)) 5*floor(min([cis.vx,nGUMICS,nSLICE])/5) ...
        5*round(max([cis.vx,vxGUMICS,vxSLICE])/5+1)]);         
    xlabel('Time [HH:MM]');
    ylabel('V_x [km/s]');
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.9,'B_z Cluster',...
%         'HorizontalAlignment','left','Color',[0 0 0]);    
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.8,...
%         'B_z orbit','HorizontalAlignment','left','Color',[1 0 0]);
%     text(fgm.time(1)+2,5*round(max(fgm.bz)/5+1)*0.7,...
%         'B_z slices','HorizontalAlignment','left','Color',[0 0 1]);
    hold on;
    plot(tGUMICS,vxGUMICS,'.r'); 
    plot(tSLICE,vxSLICE,'.b'); 
    hold off;    
    % Saving result in an eps file
    strTstart=datestr(tGUMICS(1),'yyyymmdd_hhMMss');
    strTend=datestr(tGUMICS(numel(tGUMICS)),'yyyymmdd_hhMMss');
    print(p,'-depsc2',[root_path,'images/comparision-o',num2str(Norb),...
        '-',strTstart,'_',strTend,'.eps']);
    % Closing the plot box
    close;               
end

