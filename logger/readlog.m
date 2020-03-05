function [logDateTimes, dataDateTimes, routes, vehicles, lats, lons] = readlog(filename)
fid = fopen(filename);
C = textscan(fid,'%{yyyy-MM-dd''T''HH:mm:ss}D %{yyyy-MM-dd''T''HH:mm:ss}D %C %C %f %f');
fclose(fid);
logDateTimes = C{1};
dataDateTimes = C{2};
routes = C{3};
vehicles = C{4};
lats = C{5};
lons = C{6};
end