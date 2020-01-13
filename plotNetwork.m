function [ error ] = plotNetwork( hem )
%plotNetwork Create the longitude-latitude network
%   Create the longitude-latitude network and labels. 
%   
%   longiture: 0-360/10 degree
%   latitude : 80-70-60 degree
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2013
%
% ------------------------------------------------------------------------


    error = 0;
    % Coordinate network - longitude
    angleArrayPhi=pi/6;
    angleArrayTheta=0:pi/12:35*pi/18;
    [angleArrayTheta,angleArrayPhi]=pol2cart(pi/2+angleArrayTheta,angleArrayPhi);     
    for ia=1:numel(angleArrayTheta)
        % Plot until 85^o
        plot([angleArrayPhi(ia),pi/36*angleArrayPhi(ia)],...
            [angleArrayTheta(ia),pi/36*angleArrayTheta(ia)],'--k');        
    end;
    % Coordinate network - latitude - 80 degree
    angleArrayPhi=pi/18;
    angleArrayTheta=0:pi/18:35*pi/18;
    [angleArrayTheta,angleArrayPhi]=pol2cart(pi/2+angleArrayTheta,angleArrayPhi);  
    plot(angleArrayPhi,angleArrayTheta,'--k');
    % Coordinate network - latitude - 70 degree
    angleArrayPhi=pi/9;
    angleArrayTheta=0:pi/18:35*pi/18;
    [angleArrayTheta,angleArrayPhi]=pol2cart(pi/2+angleArrayTheta,angleArrayPhi);  
    plot(angleArrayPhi,angleArrayTheta,'--k');
    % Coordinate network - latitude - 60 degree
    angleArrayPhi=pi/6;
    angleArrayTheta=0:pi/18:35*pi/18;
    [angleArrayTheta,angleArrayPhi]=pol2cart(pi/2+angleArrayTheta,angleArrayPhi);  
    plot(angleArrayPhi,angleArrayTheta,'--k');
    
    % Labels - longitude
    text(0,-0.56,'00 MLT','Rotation',0,'HorizontalAlignment','Center',...
        'VerticalAlignment','Middle');
    text(-0.56,0,'18 MLT','Rotation',90,'HorizontalAlignment','Center',...
        'VerticalAlignment','Middle');
    text(0,0.56,'12 MLT','Rotation',0,'HorizontalAlignment','Center',...
        'VerticalAlignment','Middle');
    text(0.56,0,'6 MLT','Rotation',270,'HorizontalAlignment','Center',...
        'VerticalAlignment','Middle');       
    
    % Labels - latitude
    prefix='+';
    if (hem=='s'),prefix='-';end;
    text(0,-pi/18-0.025,[prefix,'80^o'],'Rotation',0,'HorizontalAlignment','Center',...
        'VerticalAlignment','Middle');
    text(0,-pi/9-0.025,[prefix,'70^o'],'Rotation',0,'HorizontalAlignment','Center',...
        'VerticalAlignment','Middle');
end

