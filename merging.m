%% Automated definition of irritative zone
% Author : Samuel Louviot
% date   : 02/04/2019
% Affiliation : CRAN UMR7039 CNRS Université de Lorraine
% Département : Biologie, Signaux et Systèmes en Cancérologie et Neurosciences
% Projet : Neuroscience des systèmes et de la cognition
%% File opening
function merging()
%[coord_elec_file,coord_elec_folder] = uigetfile('*xls', 'choose the coordinates Excel file');
analysis_path = uigetdir();

Directory = dir(analysis_path);
file_names = {Directory.name};
[Selection1, ~] = listdlg('PromptString','Select file 1',...
                          'SelectionMode', 'single', ...
                           'ListString', file_names);
[Selection2, ~] = listdlg('PromptString','Select file 2',...
                          'SelectionMode', 'single', ...
                           'ListString', file_names);
    %% file preparation and sorting
    [sig1,~] = icem_read_micromed_trc(fullfile(Directory(Selection1).folder,Directory(Selection1).name) , 0, 1); %TRC file opening
    [sig2,output] = icem_read_micromed_trc(fullfile(Directory(Selection2).folder,Directory(Selection2).name) , 0, 1); %TRC file opening
    sig{1,1} = cat(2,sig1{1,1},sig2{1,1});
    
    Pat_Name = split(output.Name, " "); %find space character in order to separate patient's name and last name
    Pat_lastname = Pat_Name(1,1);
    Pat_firstname = Pat_Name(2,1);
    date = replace(output.Date,'/', '_'); %date of the recording
    sep_dot = findstr(output.Start,':'); %find the ":" in order to have a writable filename with start time recording
    output.Start(sep_dot(1,1)) = replace(output.Start(sep_dot(1,1)),':','h'); %replace the first ":" by h (hour)
    output.Start(sep_dot(1,2)) = replace(output.Start(sep_dot(1,2)),':','m'); %replace the second ":" by m (minutes)
    clear sep_dot 
    sep_dot = findstr(output.End,':'); %find the ":" in order to replace it in order to have a writable filename with end time recording
    output.End(sep_dot(1,1)) = replace(output.End(sep_dot(1,1)),':','h');
    output.End(sep_dot(1,2)) = replace(output.End(sep_dot(1,2)),':','m');
    data_name = [Pat_lastname{1:1}(1:3) '_' Pat_firstname{1:1}(1:2) '_' date '_' output.Start(1:end) '_' output.End(1:end-4)]; %name of the file which will be renamed
    saving_folder = analysis_path; %path of the new folder created before
    Selection = [Selection1 Selection2];
    for n=1:2
        Test_Renamed_File = strcmp(Directory(Selection(1,n)).name,[data_name '.TRC']);
        if Test_Renamed_File == 0
            movefile(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name),... %moving and renaming the SEEG recording file
                    fullfile(Directory(Selection(1,n)).folder,...
                    [Pat_lastname{1:1}(1:3) '_' Pat_firstname{1:1}(1:2) '_' date '_' output.Start(1:end)...
                    '_' output.End(1:end-4) '_PART_' num2str(n) '.TRC']));
        end
    end
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
     labels_BIP, idx_spikes, qEEG(n,:)] = ...
     MAIN_fun_standalone3(data,data_name,saving_folder);
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

%     Long traitement
    tic
    PostT.Amplitude = AMP;
    PostT.Amplitude_moyenne = StatSP(:,1);
    PostT.Amplitude_std = StatSP(:,2);
    PostT.Valeurs_max = StatSP(:,3);
    PostT.Valeurs_min = StatSP(:,4);
    PostT.Spike_occurence = qEEG;
    PostT.Stat_evenement_individuel = DE;
    PostT.Stat_evenement_multichannel = discharges;
    PostT.number_of_spikes = numSP;
    time = toc;
    save(fullfile(saving_folder,['STATS_' data_name]));
end