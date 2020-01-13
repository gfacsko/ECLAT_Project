function [ error ] = mkPointfile( step, degree )
%mkPointfile Create pointfiles for QuickLook plots
%   The ECLAT WP520 needs quicklook plots in the following intervalls:
%   
%   i.;  x=[-50,20], y=[-35,35], z=0
%   ii;  x=[-50,20], y=0, z=[-35,35]
%   iii; x=0, y=z=[-35,35]
%   
%   All units are in Earth radius and the density is ploted. This script
%   creates the pointfiles foor hcintpol. 
%
%   step  : resolution in RE
%   degree: resolution in degree
%
%   Developed by Gabor Facsko (facsko.gabor@csfk.mta.hu)
%   HAS RSEAS Geodetic and Geophysical Institute, 2016
%
% ------------------------------------------------------------------------
%
    error=0;
    xmin=-50;%-30.;
    xmax=20;%20.;
    x0=-50;%31;%-10.;
    ymin=-50;%-64;%-25.;
    ymax=50;%64;%25.;
    y0=0.;
    zmin=ymin;
    zmax=ymax;
    z0=y0;
    % Earth radius in m
    RE=6378000;
    % path
    root_path='/home/facskog/Projectek/Matlab/ECLAT/pointfiles/';
       
%     % XY Quicklook plot
%     fid=fopen([root_path,'xyPointfile-ECLAT-',num2str(step),'RE.dat'], 'w');                
%     for x=xmin:step:xmax
%         for y=ymin:step:ymax            
%             fprintf(fid,'%i\t%10i\t%10i\n',x*RE,y*RE,z0);
%         end;
%     end;
%     fclose(fid);
%     
%     % XZ Quicklook plot
%     fid=fopen([root_path,'xzPointfile-ECLAT-',num2str(step),'RE.dat'], 'w');                
%     for x=xmin:step:xmax
%         for z=zmin:step:zmax            
%             fprintf(fid,'%i\t%10i\t%10i\n',x*RE,y0,z*RE);
%         end;
%     end;
%     fclose(fid);
%     
    % YZ Quicklook plot
    fid=fopen([root_path,'xyzPointfile-Hyunju-',num2str(step),'RE.dat'], 'w');  
%     fid=fopen([root_path,'yzPointfile-ECLAT-',num2str(step),'RE.dat'], 'w');   
%     fid=fopen([root_path,'upstreamPointfile-ECLAT-',num2str(step),'RE.dat'], 'w');   

    for x=xmin:step:xmax
        for y=ymin:step:ymax
            for z=zmin:step:zmax            
                fprintf(fid,'%i\t%10i\t%10i\n',x*RE,y*RE,z*RE);
            end;
        end;
    end;
    fclose(fid);
    
%     % Ionospheric plot - North
%     fid=fopen([root_path,'nPointfile-ECLAT-',num2str(degree),'.dat'], 'w');
%     for long=0:degree:360
%         for lat=55:degree:88
%             fprintf(fid,'%i\t%10i\n',lat,long);
%         end;
%     end;
%     fclose(fid);
    
%     % Ionospheric plot - South
%     fid=fopen([root_path,'sPointfile-ECLAT-',num2str(degree),'.dat'], 'w');                
%     for long=0:step:360
%         for lat=-88:step:-55            
%             fprintf(fid,'%i\t%10i\n',lat,long);
%         end;
%     end;
%     fclose(fid);
end

