function [ error ] = plotCorrelation_launch(isOMNI,isBz,is5min,strSuffix) 
%plotCorrelation_launch Comparation of Cluster and 
%   OMNIWeb/GUMICS measurements
%   Read all previously created OMNIWeb/GUMICS and Cluster 
%   files. Calculates the cross correlations and determines the time shift
%   distribution. Plots all functions and creates distributions. 
%
%   isBz     : Use B or Bz for correlation calculation
%   isOMNI   : OMNIWeb or GUMICS
%   is5min   : 5 min / 1 min average
%   strSuffix: Extra string to distinguish the results
%
%   Developed by Gabor Facsko (facsko.gabor@wigner.hu), Wigner Research
%   Centre for Physics, Budapest, Hungary, 2014-2021
%
% -----------------------------------------------------------------
%    
    error=0;
    % Default directories
    root_path='/home/facskog/Projectek/Matlab/ECLAT/';
    % Saving the result in the right subdirectory
    strSubDir='OMNI-ClusterSC3-SW/';
    if ((~isOMNI) &  (strcmp(strSuffix,'-msh')))
        strSubDir='GUMICS-ClusterSC3-MSH/';
    end; 
    if ((~isOMNI) &  (strcmp(strSuffix,'-sw')))
        strSubDir='GUMICS-ClusterSC3-SW/';
    end;
    if ((~isOMNI) &  (strcmp(strSuffix,'-msph')))
        strSubDir='GUMICS-ClusterSC3-MSPH/';
    end;
    
    % 5 min / 1 min average
    str5min='';
    if (is5min)
        % 5 min average       
        str5min='-5min';
    end;
    
    % Delete old files
    [status,result]=unix(['rm $(echo ',root_path,'data/results-*',...
        strSuffix,str5min,'.dat)']);
    [status,result]=unix(['rm $(echo ',root_path,'images/',strSubDir,...
        'corr-*-Cluster-*',strSuffix,str5min,'.eps)']);
    [status,result]=unix(['rm $(echo ',root_path,'images/',strSubDir,...
        'corr-*-Cluster-*',strSuffix,str5min,'-merged.png)']);
    
    % Read file
    if (isOMNI)
        bzStr='';
        if (isBz),bzStr='-bz';end;
        [status,result]=unix(['ls ',root_path,'data/',strSubDir,...
            'corr-*',bzStr,'.dat']);        
    else
        bzStr='';
        if (isBz),bzStr='-bz';end;
        [status,result]=unix(['ls ',root_path,'data/',strSubDir,...
            'corr-*',bzStr,'-gumics',strSuffix,str5min,'.dat']);  
    end;
    % Process result
    startIndex=strfind(result,'corr-');
    endIndex=strfind(result,'.dat');
    for i=1:numel(startIndex)
        corrFilename=result(startIndex(i):endIndex(i)+3)
        [mt,mv]=plotCorrelation(corrFilename,isOMNI,isBz,is5min,strSuffix);        
        output=[corrFilename(6:9),'-',corrFilename(10:11),...
            '-',corrFilename(12:13),'T',corrFilename(15:16),...
            ':',corrFilename(17:18),':',corrFilename(19:20),...
            '.000Z/',corrFilename(22:25),'-',...
            corrFilename(26:27),'-',corrFilename(28:29),'T',...
            corrFilename(31:32),':',corrFilename(33:34),...
            ':',corrFilename(35:36),'.000Z & ',num2str(mv(1)),...
            ' & ',num2str(mt(1)),' & ',num2str(mv(2)),' & ',...
            num2str(mt(2)),' & ',num2str(mv(3)),' & ',...
            num2str(mt(3)),' & ',num2str(mv(4)),' & ',...
            num2str(mt(4)),' \\\\'];
        % Save results
        strGUMICS='';
        if (~isOMNI),strGUMICS='-gumics';end;
        [status2,results2]=unix(['echo "',output,'" >> ',...
            root_path,'data/results',strGUMICS,'-bz',strSuffix,str5min,...
            '.dat']);
    end;   
    
    % Merge time series and correlation plots
    [status,result]=unix(['cd ',root_path,'images/',strSubDir,';',...
        'for f in $(ls corr-*-bz-gumics',strSuffix,str5min,'.eps); ',...
        'do echo $f; D=$(echo $f|cut -d- -f2); /usr/bin/convert +append ',...
        'corr-$(echo $D|cut -d_ -f1,2)*-omni',strSuffix,'.eps ',...
        'corr-$(echo $D|cut -d_ -f1,2)*-bz-gumics',strSuffix,str5min,...
        '.eps ','corr-GUMICS-Cluster-$(echo $D|cut -d_ -f1,2)*-bz',...
        strSuffix,str5min,'.eps corr-GUMICS-Cluster-$D-bz',strSuffix,...
        str5min,'-merged.png ;done']);
end