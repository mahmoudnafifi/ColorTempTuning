function [map_temp_xyz] = LoadTempXyzMap()

csvals = csvread('temp_xyz_rgb.csv');
map_temp_xyz = containers.Map;
for i = 1 : size(csvals, 1)
    map_temp_xyz(num2str(csvals(i, 1))) = csvals(i, 2:4);
end

end