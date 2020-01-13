function [ error ] = year_launch( )
%year_launch Launch year runs
%   Call two functions and creates GUMICS script
%
%   Developed by Gabor Facsko (gabor.facsko@fmi.fi)
%   Finnish Meteorological Institute, 2012
% ------------------------------------------------------
%
    for o=246:257 % 308:412 % 
        o
        mkScripts([o],12,300);
    end;
end

