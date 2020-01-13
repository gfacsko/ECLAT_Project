function [ sm ] = readFootprints( )
%readFootprints Read the saved footprint file and converst to SM from GSE
%   
% Developed by Gabor Facsko (gabor.facsko@fmi.fi)
% Finnish Meteorological Institute, 2012
%
% -----------------------------------------------------------------


    root_path='/home/facsko/Projects/matlab/ECLAT/';

    % Counting lines of data
    %sm=zeros(332,4);
    % Read file
% 	fid=fopen([root_path,'data/footprintMap267_20020320_200000_20020323_040300.dat'], 'r');   
% 	for i=1:332
% 	    strLine=fgetl(fid);
%         strIndex=strfind(strLine,' ');
%         ['echo "',strLine(strIndex(1)+1:numel(strLine)),'" | gse2sm ',...
%             strLine(1:4),strLine(6:7),strLine(9:10),strLine(12:13),...
%             strLine(15:16)]     
% 	end;
% 	fclose (fid);

% 	fid=fopen([root_path,'data/sm267_20020320_200000_20020323_040300.dat'], 'r');   
% 	for i=1:332
% 	    strLine=fgetl(fid);
%         
%         strIndex=strfind(strLine,' ');
%         strLine(1:strIndex(1))
%         strLine(strIndex(1)+1:strIndex(2))
%         strLine(strIndex(2)+1:numel(strIndex)) 
% 	end;
%  	fclose (fid);


sm=load([root_path,'data/sm267_20020320_200000_20020323_040300.dat']);

%  sm=load([root_path,'data/footprintMap267_20020320_200000_20020323_040300.dat']);
%  sm=sm(:,2:4);
end

