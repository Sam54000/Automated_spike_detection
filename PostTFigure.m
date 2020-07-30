clear all
close all

%% Add paths
analysis_path = uigetdir();

Directory = dir(analysis_path);
file_names = {Directory.name};
[Selection, OK] = listdlg('PromptString','Select files to analyse',...
                  'SelectionMode', 'multiple', ...
                   'ListString', file_names);
[nb_files] = size(Selection);

%% Common channel recovery

for n = 1:nb_files(1,2)
        %Load variables from file into workspace
        load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name)); %PostT file opening 
        C{n,1} = PostT.Amplitude.';
end
    
%Matrix creation
    Matrice = cat(2,C{:,1}); %Concatenate arrays along specified dimension, cat(dim, C{:}) for concatenate a cell or structure array containing numeric matrices into a single matrix
    BigStd = std(Matrice,[],2,'omitnan');
    BigMean = mean(Matrice,2,'omitnan');
    
%BigMean and BigStd matrix consistency test
    Test = zeros(size(BigMean,1),1);
    Test1 = Test + double(isnan(BigMean));
    Test2 = Test + double(isnan(BigStd));
    Test3 = logical(Test1) & logical(Test2);
    verif1 = sum(double(Test3)-Test1);
    
%Removing NaN
if verif1 == 0
    channelKeep = PostT.Label_Bipolar(~Test3,1);
else
    warndlg("attention c'est chelou")
end

%Processing directory
BigPostT.Names_channel = channelKeep;

%Pick up the letters of the electrodes
nChannels = size(channelKeep,1); %Counts the number of contacts
for i = 1:nChannels
    tmp = channelKeep{i,1}; %Put the name of the contact in a temporary variable
    ChanLettersOnly{i,1} = tmp(isstrprop(tmp,'alpha')); %Takes only letters from each contact
end
[ElectrodeLetter,indexFirstContact,idx] = unique(ChanLettersOnly,'stable'); %Give the letter of each electrode (electrode A, electrode B etc...)
ElecAffiche(indexFirstContact) = ElectrodeLetter; %Gives the name of the electrode at the desired position for display in the XTick label

%% Spatial distribution

for n = 1:nb_files(1,2)
    load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name));
    Contacts{n,:} = PostT.Label_Bipolar(:,1);
end

for n = 1:nb_files(1,2)
    load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name));
    PostT.number_of_spikes(size(PostT.number_of_spikes):size(PostT.Label_Bipolar),1) = 0;
    PostT.number_of_spikes(PostT.number_of_spikes == 0) = NaN; %Replacement of 0 by Nan
    x = 1:1:size(PostT.Label_Bipolar,1);
    scatter(x,PostT.number_of_spikes,'fill'); %Scatter figure
    hold on
    nbSpikeTotal(n,1) = sum(PostT.number_of_spikes,'omitnan'); %Total sum of PostT.number_of_spikes without NaN
end

%Legend 
title('Distribution spatiale du nombre de pointes detectees','fontsize', 20);
xlabel('Electrodes');
xlim([0, size(channelKeep,1)]);
xticks([0:1:size(channelKeep,1)]);
set(gca,'XTick',1:nChannels);
set(gca,'XTickLabel',ElecAffiche);
set(gca, 'fontsize', 14)
ylabel('Nombre de pointe','fontsize', 14)

%Save to the desired directory
saveas(gcf,fullfile(analysis_path,'Distribution_spatial_nb_pointes'),'fig');
saveas(gcf,fullfile(analysis_path,'Distribution_spatial_nb_pointes'),'png');

close

%% Creation the number of spikes graph

for n = 1:nb_files(1,2)
    load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name));
    PostT.number_of_spikes(size(PostT.number_of_spikes):size(PostT.Label_Bipolar),1) = 0;
    PostT.number_of_spikes(PostT.number_of_spikes == 0) = NaN; %Replacement of 0 by Nan
    nbSpikeTotal(n,1) = sum(PostT.number_of_spikes,'omitnan'); %Total sum of PostT.number_of_spikes without NaN
    DayHour{n,1} = PostT.date; %Collection of the session date
end

%Figure
figure
bar(nbSpikeTotal);

%Legend
title('Nombre de pointe par session','fontsize', 20)  
xlabel('Enregistrement (date, heure)','fontsize', 14)
xticks([1:size(nbSpikeTotal,1)]);
xticklabels(DayHour);
set(gca,'TickLabelInterpreter','none')
ylabel('Nombre de pointe','fontsize', 14);

%Save to the desired directory
saveas(gcf,fullfile(analysis_path,'nb_spike_inter_session'),'fig');
saveas(gcf,fullfile(analysis_path,'nb_spike_inter_session'),'png');

close all