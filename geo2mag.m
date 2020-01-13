function [ mlat,mlon ] = geo2mag( incoord )
%geo2mag Convert geographycal coordinates to magnetic coordinate system
%   
%   gcoord    : Geographysical coordinates (array)
%   mlat, mlon: Magnetic latitude and longitude
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2013
%
% ------------------------------------------------------------------------
%
    % SOME 'constants'...
    Dlong=288.59;   % longitude (in degrees) of Earth's magnetic south pole
                    %(which is near the geographic north pole!) (1995)
    Dlat=79.6;   % Dlat=79.30;     % latitude (in degrees) of same (1995)
    R = 1;          % distance from planet center (value unimportant -- 
             %just need a length for conversion to rectangular coordinates)

    % Convert first to radians
    Dlong=Dlong*pi/180;
    Dlat=Dlat*pi/180;

    glat=incoord(1)*pi/180;
    glon=incoord(2)*pi/180;
    galt=glat*0+R;

    coord=[glat,glon,galt];

    % Convert to rectangular coordinates
    %       X-axis: defined by the vector going from Earth's center towards
    %            the intersection of the equator and Greenwitch's meridian.
    %       Z-axis: axis of the geographic poles
    %       Y-axis: defined by Y=Z^X
    x=coord(3)*cos(coord(1))*cos(coord(2));
    y=coord(3)*cos(coord(1))*sin(coord(2));
    z=coord(3)*sin(coord(1));

    % Compute 1st rotation matrix : rotation around plane of the equator,
    % from the Greenwich meridian to the meridian containing the magnetic
    % dipole pole.
    geolong2maglong=zeros(3,3);
    geolong2maglong(1,1)=cos(Dlong);
    geolong2maglong(1,2)=sin(Dlong);
    geolong2maglong(2,1)=-sin(Dlong);
    geolong2maglong(2,2)=cos(Dlong);
    geolong2maglong(3,3)=1.;
    out=transpose(geolong2maglong) * [x;y;z];

    % Second rotation : in the plane of the current meridian from geographic
    %                  pole to magnetic dipole pole.
    tomaglat=zeros(3,3);
    tomaglat(1,1)=cos(pi/2-Dlat);
    tomaglat(1,3)=-sin(pi/2-Dlat);
    tomaglat(3,1)=sin(pi/2-Dlat);
    tomaglat(3,3)=cos(pi/2-Dlat);
    tomaglat(2,2)=1.;
    out=transpose(tomaglat)*out;

    % Convert back to latitude, longitude and altitude
    mlat=atan(out(3)/sqrt(out(1,:)^2+out(2,:)^2));
    mlat=mlat*180./pi;
    mlon=atan(out(2)/out(1));
    mlon=mlon*180./pi;
    %malt=sqrt(out[0,*]^2+out[1,*]^2+out[2,*]^2)-R 
    %  I don't care about that one...just put it there for completeness' sake
end

