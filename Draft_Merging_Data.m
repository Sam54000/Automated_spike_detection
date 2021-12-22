
clear all; close all; clc;
%% Add paths

dirpath = pwd;
directory = dir(dirpath);
str = {directory.name};
[s,v] = listdlg('PromptString','Select files:',...
                      'SelectionMode','multiple',...
                      'ListString',str);
FILE = fullfile(directory(s(1)).folder,directory(s(1)).name);
load(FILE);
T = table(repmat({PatName},size(meanVal,1),1),ComonElec,meanVal,medVal,sdVal,p,double(h),nb_spike,maxVal,minVal,...
      'VariableNames',{'Patient','Contacts','Mean','Median','SD','p','h','number_of_spike','max','min'});
writetable(T,'Data_All.xlsx')

for j = 2:size(s,2)
    clearvars -except dirpath directory str s v j
    FILE = fullfile(directory(s(j)).folder,directory(s(j)).name);
    load(FILE);
    T = table(repmat({PatName},size(meanVal,1),1),ComonElec,meanVal,medVal,sdVal,p,double(h),nb_spike,maxVal,minVal,...
      'VariableNames',{'Patient','Contacts','Mean','Median','SD','p','h','number_of_spike','max','min'});
    writetable(T,'Data_All.xlsx','WriteMode','Append');
end

Results = readtable('Data_All.xlsx');
Results.Patient = categorical(Results.Patient);