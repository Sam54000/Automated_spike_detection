%% SEEG_IED_Analysis_pipeline
% Author : Samuel Louviot 
% samuel.louviot@univ-lorraine.fr
% date : Mars 2019
% CRAN UMR7039 CNRS Université de Lorraine 
% département BioSiS 
% Projet Neurosciences des systemes et de la cognition
%
        % This pipeline use the hilbert spike detector (Janca et al. 2015)
        % to analyze the inter-ictal epileptic discharges in SEEG, finding
        % the irritative zone, have the spatial distribution of the spiking
        % rate and the spatial distribution of the spikes' amplitudes.
        %
clear all; close all; clc;
%% Add paths
cvxFolder =    '';
%biosigFolder = 'Z:\Programs\GitHub\Biosig';
addpath('Z:\Programs\GitHub\Automated_spike_detection\MAIN_fun_standalone');
%addppath(cvxFolder);
addpath('Z:\Programs\GitHub\fun');

dirpath = uigetdir('Z:\Science\Analyse tDCS');
directory = dir(dirpath);
str = {directory.name};
[s,v] = listdlg('PromptString','Select files:',...
                      'SelectionMode','multiple',...
                      'ListString',str);
for j = 1:size(s,2)
%% Question TRC or Matfile
clearvars -except dirpath directory str s v j
FILE = fullfile(directory(s(j)).folder,directory(s(j)).name);
[FILEPATH,NAME,EXT] = fileparts(FILE);
switch EXT
    case '.mat'
        sig=load(FILE);            %loading mat-file
        [signal,labels] = searchAndDestroy_bad_elec(sig.avg,sig.elec.label); %searching bad elec and delete the signal corresponding to the bad elec
        prompt = {'Sampling frequency (Hz)'}; %Boite de dialogue où sont saisies les paramètres
        title = 'Sampling frequency';
        definput = {'1024'}; 
        answer = inputdlg(prompt,title,1,definput);
        data.fs = str2num(answer{1,1}); %sampling frequency
        data.d = transpose(signal);     
        sigsize = size(signal);
        data.labels = labels;
        clearvars 'labels';
        data.labels = transpose(data.labels);
        data.tabs(1:sigsize(1,1),1) = sig.time(1,2);
    case '.TRC'
        [sig,output]  = icem_read_micromed_trc(FILE, 0, 1);
        [signal,labels] = searchAndDestroy_bad_elec(sig{1,1},output.Names);
        data.fs = output.SR;
        if strcmp(NAME,'EEG_POST_NEG_ZO_TO_CROP')
            data.d = transpose(signal(:,(120*output.SR):(1200*output.SR)));
        else
            data.d = transpose(signal);
        end
        clearvars 'signal';
        data.labels = labels;
        clearvars 'labels';
        sigsize = size(data.d);
        data.tabs(1:sigsize(1,1),1) = 1/data.fs;
end  
%% Spike Analysis
    [...
        d, ...
        DE, ...
        discharges,... 
        d_decim, envelope,... 
        background,... 
        envelope_pdf,... 
        clustering,... 
        labels_BIP,... 
        idx_red,...
        qEEG,...
    ] = MAIN_fun_standalone2(data,5,FILE);
%% Extraction Raw Spikes' Values

    idx_elec = find(clustering.qAR(1,:) == 1);
    nb_elec = size(idx_elec,2);
    dat_irrit = d(:,idx_elec);
    for n = 1:nb_elec
        elec{n,1} = labels_BIP{idx_elec(n),1};
        clear window pos m
        [ValMinPos,idxMinPos] = min(discharges.MP,[],2);
        pos = round(discharges.MP(clustering.class == 1 & idxMinPos == idx_elec(n) & discharges.MV(:,idx_elec(n)) == 1,idx_elec(n)).*data.fs);
        win = 100;
        [x, ~, ~] = bst_bandpass_hfilter(d(:,idx_elec(n))',1024,6,0);
        for i = 1:size(pos,1)
            windowTemp= x(pos(i,1)-win:pos(i,1)+win)-mean(x);
            windowTemp = abs(windowTemp);
            [m(i,1),idx(i,1)] = max(windowTemp);
            idx(i,1) = idx(i,1)-20;
            window(i,:) = x(pos(i,1)-win+idx(i,1):pos(i,1)+win+idx(i,1)+100)-mean(x);
        end
        MAT_SPIKES{n,1} = window;
        VAL_SPIKES{n,1} = m;
        %% Stat
        StatSP.mean(n,1) = mean(VAL_SPIKES{n,1});
        StatSP.sd(n,1) = std(VAL_SPIKES{n,1});
        StatSP.max(n,1) = max(VAL_SPIKES{n,1});
        StatSP.min(n,1) = min(VAL_SPIKES{n,1});
        StatSP.elec = replace(elec,'p',char(39));
    end
    close all
    save([FILEPATH filesep 'Results_Spikes_' NAME '.mat'],'StatSP','MAT_SPIKES','VAL_SPIKES')
end