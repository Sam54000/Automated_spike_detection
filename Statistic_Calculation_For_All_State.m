clear all; close all; clc;

dirpath = uigetdir('Z:\Science\Analyse tDCS');
directory = dir(dirpath);
str = {directory.name};
[s,v] = listdlg('PromptString','Select files Only Before tDCS:',...
                      'SelectionMode','multiple',...
                      'ListString',str);
for j = 1:size(s,2)
    clearvars -except dirpath directory str s v j 'MEAN' 'MEDIAN' 'SD' 'MAX' 'MIN' 'PVAL' 'PAT' 'NBTOTAL' NBCONTACTS
    FILE = fullfile(directory(s(j)).folder,directory(s(j)).name);
    [FILEPATH,NAMEbefore,EXT] = fileparts(FILE);
    NAMEduring = replace(NAMEbefore,'BEFORE','DURING');
    PatName = NAMEbefore(end-5:end);
%     if strcmp(PatName,'NEG_ZO')
%         NAMEpost = 'Results_Spikes_EEG_POST_NEG_ZO_TO_CROP';
%     else
    NAMEpost   = replace(NAMEbefore,'BEFORE','POST');
%     end

    Before = load(FILE);
    During = load([FILEPATH filesep NAMEduring EXT]);
    Post = load([FILEPATH filesep NAMEpost EXT]);
    
    

    %%
    ComonElec = intersect(intersect(During.StatSP.elec,Before.StatSP.elec),Post.StatSP.elec);
    [idLogBefore,idxElecBefore] = ismember(ComonElec,Before.StatSP.elec);
    [idLogDuring,idxElecDuring] = ismember(ComonElec,During.StatSP.elec);
    [idLogAfter,idxElecPost] = ismember(ComonElec,Post.StatSP.elec);
    
    Comparisons = ['BeforeVDuring','BeforeVPost','DuringVPost'];
    for i = 1:size(ComonElec,1)
        
        Val_Before(i,1) = Before.VAL_SPIKES(idxElecBefore(i),1);
        Val_During(i,1) = During.VAL_SPIKES(idxElecDuring(i),1);
        Val_Post(i,1) = Post.VAL_SPIKES(idxElecPost(i),1);
        
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
drawBoxplots(size(ComonElec,1),Val_Before,Val_During,Val_Post,h,ComonElec)

pause(5)
exportgraphics(gcf,[FILEPATH filesep 'Figures_Statistic_Comparison' PatName '.png'],'resolution',512);
saveas(gcf,[FILEPATH filesep 'Figures_Statistic_Comparison' PatName],'fig')
close
save([FILEPATH filesep 'Statistic_Comparison' PatName '.mat'],'PatName',...
    'ComonElec','Comparisons','p','h','nb_spike','meanVal','medVal',...
    'sdVal','maxVal','minVal','Val_Before','Val_During','Val_Post')
%%
TotalValSpikesBefore = cell2mat(Val_Before(idLogBefore,1));
TotalValSpikesDuring = cell2mat(Val_During(idLogDuring,1));
TotalValSpikesPost = cell2mat(Val_Post(idLogAfter,1));

[pVal(1,1),Pstat(1,1)] = ranksum(TotalValSpikesBefore,TotalValSpikesDuring);
[pVal(1,2),Pstat(1,2)] = ranksum(TotalValSpikesBefore,TotalValSpikesPost);
[pVal(1,3),Pstat(1,3)] = ranksum(TotalValSpikesDuring,TotalValSpikesPost);

BigMeanVal = [mean(TotalValSpikesBefore),mean(TotalValSpikesDuring),...
              mean(TotalValSpikesPost)];

BigMedVal = [median(TotalValSpikesBefore),median(TotalValSpikesDuring),...
              median(TotalValSpikesPost)];

BigSDVal = [std(TotalValSpikesBefore),std(TotalValSpikesDuring),...
              std(TotalValSpikesPost)];
          
BigMaxVal = [max(TotalValSpikesBefore),max(TotalValSpikesDuring),...
              max(TotalValSpikesPost)];
         
BigMinVal = [min(TotalValSpikesBefore),min(TotalValSpikesDuring),...
              min(TotalValSpikesPost)];
MEAN(j,:) = BigMeanVal;
MEDIAN(j,:) = BigMedVal;
SD(j,:) = BigSDVal;
MAX(j,:) = BigMaxVal;
MIN(j,:) = BigMinVal;
PVAL(j,:) = pVal;
PAT(j,:) = {string(PatName)};
NBTOTAL(j,:) = [numel(TotalValSpikesBefore),numel(TotalValSpikesDuring),...
                numel(TotalValSpikesPost)];
NBCONTACTS(j,:) = size(ComonElec,1);
% 
drawBoxplots2(TotalValSpikesBefore,TotalValSpikesDuring,TotalValSpikesPost,Pstat)
pause(5)
exportgraphics(gcf,[FILEPATH filesep 'Figures_Total_Statistic_Comparison' PatName '.png'],'resolution',512);
saveas(gcf,[FILEPATH filesep 'Figures_Total_Statistic_Comparison' PatName],'fig')
save([FILEPATH filesep 'Statistic_Comparison' PatName '.mat'],'PatName',...
    'ComonElec','Comparisons','p','h','pVal','Pstat','nb_spike','meanVal','medVal',...
    'sdVal','maxVal','minVal','Val_Before','Val_During','Val_Post','BigMeanVal',...
    'BigMedVal','BigSDVal','BigMaxVal','BigMinVal')
close
end
save([FILEPATH filesep 'Overall_Statistic_Comparison.mat'],'MEAN','MEDIAN','SD','MAX','MIN',...
     'PVAL','PAT','NBTOTAL','NBCONTACTS')
    
