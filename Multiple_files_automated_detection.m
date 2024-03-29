%% Detection serie
%######################################### OLD ####################
% Author : Samuel Louviot
% date   : 02/04/2019
% Affiliation : CRAN UMR7039 CNRS Université de Lorraine
% Département : Biologie, Signaux et Systèmes en Cancérologie et Neurosciences
% Projet : Neuroscience des systèmes et de la cognition
%% Add paths
cvxFolder =    '';
biosigFOlder = '';
functionsPackageFolder = '';
addpath('./MAIN_fun_standalone');
addppath(cvxFolder);
addpath(biosigFOlder);
addpath(functionsPackageFolder);

%% File opening
analysis_path = uigetdir();

Directory = dir(analysis_path);
file_names = {Directory.name};
[Selection, OK] = listdlg('PromptString','Select files to analyse',...
                          'SelectionMode', 'multiple', ...
                           'ListString', file_names);
[nb_files] = size(Selection);
tic;
for n = 1:nb_files(1,2)
    %% file preparation and sorting
    tic;
    [sig,output] = icem_read_micromed_trc([Directory(Selection(1,n)).folder '\' Directory(Selection(1,n)).name] , 0, 1); %TRC file opening
    separator = findstr(output.Name, ' '); %find space character in order to separate patient's name and last name
    Pat_lastname = output.Name(1:separator - 1);
    Pat_name = output.Name(separator + 1 : end);
    Pat_folder = [Pat_lastname(1:3) '_' Pat_name(1:2) ' IED control analysis']; %name of the folder where the renamed data and the results will be saved
    if not(exist(Pat_folder)) %if the patient's folder doesn't exist
        mkdir([analysis_path '\' Pat_folder]); %create the folder
    end
    date = replace(output.Date,'/', '_'); %date of the recording
    sep_dot = findstr(output.Start,':'); %find the ":" in order to replace it in order to have a writable filename with start time recording
    output.Start(sep_dot(1,1)) = replace(output.Start(sep_dot(1,1)),':','h'); %replace the first ":" by h (hour)
    output.Start(sep_dot(1,2)) = replace(output.Start(sep_dot(1,2)),':','m'); %replace the second ":" by m (minutes)
    clear sep_dot 
    sep_dot = findstr(output.End,':'); %find the ":" in order to replace it in order to have a writable filename with end time recording
    output.End(sep_dot(1,1)) = replace(output.End(sep_dot(1,1)),':','h');
    output.End(sep_dot(1,2)) = replace(output.End(sep_dot(1,2)),':','m');
    data_name = [Pat_lastname(1:3) '_' Pat_name(1:2) '_' date '_' output.Start(1:end) '_' output.End(1:end-4)]; %name of the file which will be renamed
    saving_folder = [Directory(Selection(1,n)).folder '\' Pat_folder]; %path of the new folder created before
          
    movefile([Directory(Selection(1,n)).folder '\' Directory(Selection(1,n)).name],... %moving and renaming the SEEG recording file
             [Directory(Selection(1,n)).folder '\' Pat_folder '\SEEG_'...
              Pat_lastname(1:3) '_' Pat_name(1:2) '_' date '_' output.Start(1:end)...
              '_' output.End(1:end-4) '.TRC']); 
 %% Data organization
          
   [signal,labels] = searchAndDestroy_bad_elec(sig{1,1},output.Names); %function which search and remove the channel MKR, SPO2, BEAT, ECG etc...
    data.fs = output.SR; %Sampling frequency
    data.d = transpose(signal); %Transposing the raw data in order to be readable for the spike detector
    clearvars 'signal';
    data.labels = labels;
    clearvars 'labels';
    sigsize = size(data.d);
    data.tabs(1:sigsize(1,1),1) = 1/data.fs;
 %% spike detection
    [d, DE, discharges, d_decim, envelope,...
     background, envelope_pdf, clustering,...
     labels_BIP, idx_spikes, qEEG] = ...
     MAIN_fun_standalone3(data,data_name,saving_folder,date,output.Start,output.End,analysis_path);
 t2 = toc;
%% Statistics
numSP = size(DE.chan); %number of detected spikes
matSpike = discharges.MA(discharges.MV == 1); %Amplitudes of the spikes detected
[nb_elec,~] = size(labels_BIP);
    for m = 1:nb_elec
        [index,~] = find(DE.chan == m);
        [sizeMat,~] = size(matSpike);
        if not(isempty(index))
            if index(end,1) > sizeMat
                matSpike(index(end,1),1) = NaN;
            end
        end
        AMP{m,1} = matSpike(DE.chan == m); %Amplitude for each channels for each spikes
        if not(isempty(AMP{m,1}))
            StatSP(m,1) = mean(AMP{m,1}); %mean of the spikes amplitudes for each channels
            StatSP(m,2) = std(AMP{m,1});  %standard deviation of the amplitudes
            StatSP(m,3) = max(AMP{m,1});  %maximum values on each channels
            StatSP(m,4) = min(AMP{m,1});  %minimum values on each channels
        else
            StatSP(m,:) = NaN;
        end
        
    end

    PostT.Amplitude = AMP;
    PostT.Amplitude_moyenne = StatSP(:,1);
    PostT.Amplitude_std = StatSP(:,2);
    PostT.Valeurs_max = StatSP(:,3);
    PostT.Valeurs_min = StatSP(:,4);
    PostT.Spike_occurence = qEEG;
    PostT.Stat_evenement_individuel = DE;
    PostT.Stat_evenement_multichannel = discharges;
    PostT.number_of_spikes = numSP;
    tic;
    save([saving_folder '\STATS' data_name],'PostT');
    t3 = toc;
end
t1 = toc;