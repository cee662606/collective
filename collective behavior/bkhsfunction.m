function [v_data_th, Area_array]= bkhsfunction(T_data,v_data) 

% clc
% clear
% ReadPath = ['D:\bkhs draw', '\'];
% files=dir([ReadPath,'19.txt']);
% FileNum = length(files);
% for i = 1:FileNum
% fname = files(i).name;
% fid = fopen([ReadPath, fname]);
% formatSpec = '%s%s';
% C_head = textscan(fid, formatSpec, 1, 'delimiter', ' ');
% formatSpec = '%f%f';
% C_data = textscan(fid,formatSpec,'delimiter',',');
% fclose('all');
% 
% end
% 
% T_data =C_data{1}(3000:10000);
% v_data =C_data{2}(3000:10000);

th =10;
dt = T_data(2) - T_data(1);
N = length(v_data);
v_data_th = v_data - th;

for i = 1:N
    if v_data(i) < th
        v_data_th(i) = 0;
    end
end

figure
plot(T_data, v_data)

Init = 0;
for i = 1:N
    if v_data_th(i) == 0
        Init = i;
        break
    end
end

Location = [];
Area_array = [];
count = 1;
Peak_end = 0;
Area = 0;
for i = Init+1:N
    if Peak_end == 0
        Area = Area + dt*v_data_th(i);
        Area_array(count) = Area;
        Location(count) = i;
    end
    if v_data_th(i) == 0 && v_data_th(i-1) > 0
        Peak_end = 1;
        count = count + 1;
        Area = 0;
    elseif v_data_th(i) > 0 && v_data_th(i-1) == 0
        Peak_end = 0;
    end
end

% figure
% plot(T_data, v_data_th);
% hold on
% plot(T_data(Location), zeros(1,count - 1), 'o');

% figure
% stem(T_data(Location), Area_array)

% figure
% histogram(Area_array,12)
% set(gca,'xscale','log')
% set(gca,'yscale','log')

Area_array(find(Area_array==0))=[];
% Area2=sort(Area_array);

orderMax = log10(2*max(Area_array));
orderMin = log10(2*min(Area_array));
orderRange = logspace(orderMin, orderMax,30);
y = zeros(1,length(orderRange));
for i = 1:length(Area_array)
    test = Area_array(i);
    for j = 1:length(orderRange)
        if test <= orderRange(j)
            y(j) = y(j) + 1;
            break;
        end
    end
end

figure
loglog(orderRange, y, '-o')