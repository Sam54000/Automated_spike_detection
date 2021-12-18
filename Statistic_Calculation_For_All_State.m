clear all; close all; clc;

dirpath = uigetdir('Z:\Science\Analyse tDCS');
directory = dir(dirpath);
str = {directory.name};
[s,v] = listdlg('PromptString','Select files Only Before tDCS:',...
                      'SelectionMode','multiple',...
                      'ListString',str);
for j = 1:size(s,2)
    clearvars -except dirpath directory str s v j
    FILE = fullfile(directory(s(j)).folder,directory(s(j)).name);
    [FILEPATH,NAMEbefore,EXT] = fileparts(FILE);
    NAMEduring = replace(NAMEbefore,'BEFORE','DURING');
    PatName = NAMEbefore(end-5:end);
    if strcmp(PatName,'NEG_ZO')
        NAMEpost = 'Results_Spikes_EEG_POST_NEG_ZO_TO_CROP';
    else
        NAMEpost   = replace(NAMEbefore,'BEFORE','POST');
    end

    Before = load(FILE);
    During = load([FILEPATH filesep NAMEduring EXT]);
    Post = load([FILEPATH filesep NAMEpost EXT]);
    
    

    %%
    ComonElec = intersect(intersect(During.StatSP.elec,Before.StatSP.elec),Post.StatSP.elec);
    [~,idxElecBefore] = ismember(ComonElec,Before.StatSP.elec);
    [~,idxElecDuring] = ismember(ComonElec,During.StatSP.elec);
    [~,idxElecPost] = ismember(ComonElec,Post.StatSP.elec);
    
    Comparisons = ['BeforeVDuring','BeforeVPost','DuringVPost'];
    for i = 1:size(ComonElec,1)
        [p(i,1),h(i,1)] = ranksum(Before.VAL_SPIKES{idxElecBefore(i),1},During.VAL_SPIKES{idxElecDuring(i),1});
        [p(i,2),h(i,2)] = ranksum(Before.VAL_SPIKES{idxElecBefore(i),1},Post.VAL_SPIKES{idxElecPost(i),1});
        [p(i,3),h(i,3)] = ranksum(During.VAL_SPIKES{idxElecDuring(i),1},Post.VAL_SPIKES{idxElecPost(i),1});
        
        nb_spike(i,1) = size(Before.VAL_SPIKES{idxElecBefore(i),1},1);
        nb_spike(i,2) = size(During.VAL_SPIKES{idxElecDuring(i),1},1);
        nb_spike(i,3) = size(Post.VAL_SPIKES{idxElecPost(i),1},1);
        
        meanVal(i,1) = Before.StatSP.mean(idxElecBefore(i));
        meanVal(i,2) = During.StatSP.mean(idxElecDuring(i));
        meanVal(i,3) = Post.StatSP.mean(idxElecPost(i));
        
        medVal(i,1) = median(Before.VAL_SPIKES{idxElecBefore(i),1}); %med
        medVal(i,2) = median(During.VAL_SPIKES{idxElecDuring(i),1});
        medVal(i,3) = median(Post.VAL_SPIKES{idxElecPost(i),1});
        
        sdVal(i,1) = Before.StatSP.sd(idxElecBefore(i)); %sd
        sdVal(i,2) = During.StatSP.sd(idxElecDuring(i));
        sdVal(i,3) = Post.StatSP.sd(idxElecPost(i));
        
        maxVal(i,1) = Before.StatSP.max(idxElecBefore(i)); %max
        maxVal(i,2) = During.StatSP.max(idxElecDuring(i));
        maxVal(i,3) = Post.StatSP.max(idxElecPost(i));
        
        minVal(i,1) = Before.StatSP.min(idxElecBefore(i)); %min
        minVal(i,2) = During.StatSP.min(idxElecDuring(i));
        minVal(i,3) = Post.StatSP.min(idxElecPost(i));
    end
save([FILEPATH filesep 'Statistic_Comparison' PatName '.mat'],'PatName','ComonElec','Comparisons','p','h','nb_spike','meanVal','medVal','sdVal','maxVal','minVal')
end
    
