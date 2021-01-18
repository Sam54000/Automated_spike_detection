%% Automated definition of irritative zone
% Author : Samuel Louviot
% date   : 02/04/2019
% Affiliation : CRAN UMR7039 CNRS Université de Lorraine
% Département : Biologie, Signaux et Systèmes en Cancérologie et Neurosciences
% Projet : Neuroscience des systèmes et de la cognition
%% Add paths
clear all
close all

%biosigFolder = '/Users/macbook/Desktop/ProgrammesSEEG/Biosig-master'; %Path where you downloaded biosig
%functionsPackageFolder = '/Users/macbook/Desktop/ProgrammesSEEG/Function-package-master'; %Path where you downloaded Function Package

addpath(fullfile(pwd,'nextname'));
addpath(fullfile(pwd,'MAIN_fun_standalone'));
%addpath(biosigFolder);
%addpath(functionsPackageFolder);

%% File opening
%[coord_elec_file,coord_elec_folder] = uigetfile('*xls', 'choose the coordinates Excel file');

ButtonName = questdlg('splitted files?', ...
                         'Qestion', ...
                         'Yes', 'No', 'No');
switch ButtonName
 case 'Yes'
  merging;
 case 'No'
    analysis_path = uigetdir();
    Directory = dir(analysis_path);
    file_names = {Directory.name};
    [Selection, OK] = listdlg('PromptString','Select files to analyse',...
                      'SelectionMode', 'multiple', ...
                       'ListString', file_names);
    [nb_files] = size(Selection);
    for n = 1:nb_files(1,2)
    %% file preparation and sorting
        clearvars -except ButtonName analysis_path file_names Selection Directory n nb_files
        [sig,output] = icem_read_micromed_trc(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name) , 0, 1); %TRC file opening
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
        saving_folder = Directory(Selection(1,n)).folder; %path of the new folder created before
        test_exist_file = exist([data_name '.TRC'],'file');
        Test_Renamed_File = strcmp(Directory(Selection(1,n)).name,[data_name '.TRC']);
%         newFname = nextname(fullfile(saving_folder,data_name),'_1','.TRC');
%         if Test_Renamed_File == 0            
%             movefile(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name),... %moving and renaming the SEEG recording file
%                     fullfile(Directory(Selection(1,n)).folder,...
%                     newFname));
%         end
%         newFname = newFname(1,1:end-4);
        %% Preparing and filtering
%       **********CHECKED*********
        [signal,labels] = searchAndDestroy_bad_elec(sig{1,1},output.Names); %function which search and remove the channel MKR, SPO2, BEAT, ECG etc...     
        for i=1:size(signal,1)
            FilteredSignal(i,:) = notchFilter(50,output.SR,signal(i,:));
            FilteredSignal(i,:) = notchFilter(50*2,output.SR,FilteredSignal(i,:));
        end
        
        f = [2 5];
        a = [0 1];
        dev = [0.01 0.05];
        [n1,Wn,beta,ftype] = kaiserord(f,a,dev,output.SR);
        b = fir1(n1,Wn,ftype); 
        parfor i=1:size(signal,1)
            FilteredSignal(i,:) = filter(b,1,FilteredSignal(i,:));
        end
        %%       
        data.fs = output.SR; %Sampling frequency
        data.d = FilteredSignal'; %Transposing the raw data in order to be readable for the spike detector
        clearvars 'signal';
        data.labels = labels;
        clearvars 'labels';
        sigsize = size(data.d);
        data.tabs(1:sigsize(1,1),1) = 1/data.fs;
        %% spike detection
        [d, DE, discharges, d_decim, envelope,...
        background, envelope_pdf, clustering,...
        labels_BIP, idx_spikes, qEEG, tab] = ...
        MAIN_fun_standalone3(data,data_name,saving_folder);
        %% Minimizing false positive detection
        pos = round(discharges.MP*output.SR);
        dur = 124;
        d = d.';
        fBar = waitbar(0,'1','Name','Processing...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        f2 = waitbar(0,'name','name','processing');
        for j = 1:size(pos,2)
            k = 0;
           clear MatTmp
           l=1;
            for i = 1:size(pos,1)
                if ~isnan(pos(i,j))
                    [LocalMaximum,idx] = max(d(j,pos(i,j)-30:pos(i,j)+50));
                    dif = idx-10;
                    pos2 = pos(i,j)+dif;
                    win = [pos2-30,pos2+dur];
                    signalStd = std(d(j,:));
                    waitbar(i/size(pos,1),f2);
                    if LocalMaximum > 3*signalStd && LocalMaximum > 100 % Si x est supérieur à 2x la std & si x est > à 100 alors
                        MatTmp(l,:) = d(j,win(1,1):win(1,2));
                        AmpTmp(l,1) = LocalMaximum;
                        l = l+1;
                    end
                end
            end
            if exist('MatTmp','var')
                Spikes{j,1} = MatTmp;
                Amplitudes{j,1} = AmpTmp;
                PostT.Amplitude_moyenne = mean(Amplitudes{j,1},'omitnan');
                PostT.Amplitude_std = std(Amplitudes{j,1},'omitnan');
                PostT.Valeurs_max = max(Amplitudes{j,1});
                PostT.Valeurs_min = min(Amplitudes{j,1});
                PostT.number_of_spikes = size(Amplitudes{j,1},1);
            end
            waitbar(j/size(pos,2),fBar);
        end
%% Statistics 2
%         numSP = size(DE.chan); %number of detected spikes
%         matSpike = discharges.MA(discharges.MV == 1); %Amplitudes of the spikes detected
%        [nb_elec,~] = size(labels_BIP);
%         for m = 1:nb_elec
%             [index,~] = find(DE.chan == m);
%             [sizeMat,~] = size(matSpike);
%             if not(isempty(index))
%                 if index(end,1) > sizeMat
%                     matSpike(index(end,1),1) = NaN;
%                 end
%             end
%             AMP{m,1} = matSpike(DE.chan == m); %Amplitude for each channels for each spikes
%             if not(isempty(AMP{m,1}))
%                 StatSP(m,1) = mean(AMP{m,1}); %mean of the spikes amplitudes for each channels
%                 StatSP(m,2) = std(AMP{m,1});  %standard deviation of the amplitudes
%                 StatSP(m,3) = max(AMP{m,1});  %maximum values on each channels
%                 StatSP(m,4) = min(AMP{m,1});  %minimum values on each channels
%             else
%                 StatSP(m,:) = NaN;
%             end
% 
%         end

        %     Long traitement
        
        PostT.Label_Bipolar = labels_BIP;
        PostT.Start = output.Start;
        PostT.End = output.End;
        PostT.date = date;
        PostT.Amplitude = Amplitudes;
        PostT.Spike_Matrix = Spikes;
        PostT.Spike_occurence = qEEG;
        PostT.Stat_evenement_individuel = DE;
        PostT.Stat_evenement_multichannel = discharges;
        %time = toc;
        %newStatsname = nextname(fullfile(saving_folder,data_name),'_1','.mat');
        save(fullfile(saving_folder,['STATS_' data_name]),'PostT');
        close all
    end
end
%% Intracerebral location (under development)
% for m = 1:nb_elec
%     irrit_zone(1,m) = mean(qEEG(:,m));
% end
% 
% [~,target_contact_numb] = max(irrit_zone);
% target_contact_label = labels_BIP{target_contact_numb,1};
% target_contact_label = target_contact_label(1:3);
% target_contact_label = replace(target_contact_label, 'p', '''');
% [coord, txt, all_xlsfile] = xlsread([coord_elec_folder coord_elec_file]);
% [raw_xls_file,col_xls_file] = size(all_xlsfile);
% 
% for n = 1:raw_xls_file
%     tmp(n,1) = strcmp(target_contact_label,all_xlsfile{n,1});
%     tmp(n,2) = strcmp('center',all_xlsfile{n,1});
% end
% rawpos_contact_label = find(tmp(:,1));
% rawpos_center = find(tmp(:,2));
% target_coordinates = [all_xlsfile{rawpos_contact_label,2} ...
%                       all_xlsfile{rawpos_contact_label,3} ...
%                       all_xlsfile{rawpos_contact_label,4}];
% center_coordinates = [all_xlsfile{rawpos_center,2} ...
%                       all_xlsfile{rawpos_center,3} ...
%                       all_xlsfile{rawpos_center,4}];
% %xlsread puis loaduntuchnii et convertion mm en voxel puis matcher
% %le numéro de contact avec les coordonnées,
