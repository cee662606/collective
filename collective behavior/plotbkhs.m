clc;
close all;
clear;

file=dir('D:\new bkhs data\run240707\run--2e-7-3000-50.out\run-2e-7-3000-50.xlsx')
filename={file.name}'
filefolder={file.folder}';

A=importdata([filefolder{1},'\',filename{1}]);
Data1=A.data.table(5000:180000,:); Data1(:,2:4)=[];

%fullPath = fullfile(filefolder{1}, filename{1});
%A_numeric = readmatrix(fullPath,'Sheet','table');
%Data1 = A_numeric(5000:400000, :);
%Data1(:, 2:4) = [];

% Data3=A.data.x1054(3000:13800,:); Data3(:,2:4)=[];
% Data4=A.data.x1055(3000:13800,:); Data4(:,2:4)=[];


[v_data_th1, Area_array1]=bkhsfunction(Data1(:,1),Data1(:,2));
% [v_data_th2, Area_array2]=XXX(Data2(:,1),Data2(:,2));
% [v_data_th3, Area_array3]=XXX(Data3(:,1),Data3(:,2));
% [v_data_th4, Area_array4]=XXX(Data4(:,1),Data4(:,2));

Area_array=[Area_array1];
% 
% figure(1111)
% histogram(Area_array,20)
% set(gca,'xscale','log')
% set(gca,'yscale','log')

Area_array(find(Area_array==0))=[];
% Area2=sort(Area_array);

orderMax = log10(2*max(Area_array));
orderMin = log10(2*min(Area_array));
orderRange = logspace(orderMin, orderMax,60);
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

figure(222)
loglog(orderRange, y, '-o')

