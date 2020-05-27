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
%cvxFolder =    '';
biosigFolder = '/Volumes/Storage/Programs/Biosig';
functionsPackageFolder = '/Volumes/Storage/Programs/fun';
addpath('./MAIN_fun_standalone');
%addppath(cvxFolder);
addpath(biosigFolder);
addpath(functionsPackageFolder);
%% Question TRC or Matfile and choose sampling frequency
answer = questdlg('SEEG file type', ...
	'SEEG data filetype', ...
	'matlab (.mat)','micromed (.trc)','matlab (.mat)');
switch answer
    case 'matlab (.mat)'
        filetype = 1;
    case 'micromed (.trc)'
        filetype = 2;
end
%% loading a patient mat-file

if filetype == 1
    [file,path] = uigetfile('*.mat'); %browse mat-file
    sig=load([path file]);            %loading mat-file
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
end

%% loading a patient micromed trc-file
if filetype == 2
    [file,path] = uigetfile('.trc');
    [sig,output]  = icem_read_micromed_trc([path file], 0, 1);
    [signal,labels] = searchAndDestroy_bad_elec(sig{1,1},output.Names);
    data.fs = output.SR;
    data.d = transpose(signal);
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
        idx_elec,...
        qEEG,...
    ] = MAIN_fun_standalone2(data,'none',5,[path file]);
%% Data processing
matSpike = discharges.MA(discharges.MV == 1);
sigsizeBIP = size(labels_BIP);
for m = 1:sigsizeBIP(1,2)
    TEST{m,1} = matSpike(DE.chan == m);
    StatSP(m,1) = mean(TEST{m,1});
    StatSP(m,2) = std(TEST{m,1});
    StatSP(m,3) = max(TEST{m,1});
    StatSP(m,4) = min(TEST{m,1});
end
numSP = size(DE.chan);
[nb_elec,~] = size(idx_elec);
dat_irrit = d(:,idx_elec);
for n = 1:nb_elec
    elec{n,1} = labels_BIP{idx_elec(n,1),1};
end