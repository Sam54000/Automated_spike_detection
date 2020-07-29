clear all

analysis_path = uigetdir();

Directory = dir(analysis_path);
file_names = {Directory.name};
[Selection, OK] = listdlg('PromptString','Select files to analyse',...
                  'SelectionMode', 'multiple', ...
                   'ListString', file_names);
[nb_files] = size(Selection);

%%

for n = 1:nb_files(1,2)
        %Load variables from file into workspace
        load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name)); %PostT file opening 
        C{n,1} = PostT.Amplitude.';
end
    
% Cr�ation de la Matrice
    Matrice = cat(2,C{:,1}); %Concatenate arrays along specified dimension, cat(dim, C{:}) for concatenate a cell or structure array containing numeric matrices into a single matrix
    BigStd = std(Matrice,[],2,'omitnan');
    BigMean = mean(Matrice,2,'omitnan');
    
% Test coh�rence matrice BigMean et BigStd
    Test = zeros(size(BigMean,1),1);
    Test1 = Test + double(isnan(BigMean));
    Test2 = Test + double(isnan(BigStd));
    Test3 = logical(Test1) & logical(Test2);
    verif1 = sum(double(Test3)-Test1);
    
% Supprimer les NaN
if verif1 == 0
    channelKeep = PostT.Label_Bipolar(~Test3,1);
else
    warndlg("attention c'est chelou")
end

% R�pertoire traitement
BigPostT.Names_channel = channelKeep;

% Pick up the letters of the electrodes
nChannels = size(channelKeep,1); %compte le nombre de contacts
for i = 1:nChannels
    tmp = channelKeep{i,1}; % Met le nom du contact dans un variable temporaire
    ChanLettersOnly{i,1} = tmp(isstrprop(tmp,'alpha')); % Prend uniquement les lettres de chaque contacts
end
[ElectrodeLetter,indexFirstContact,idx] = unique(ChanLettersOnly,'stable'); % Donne la lettre de chaque electrode (electrode A, electrode B etc...)
ElecAffiche(indexFirstContact) = ElectrodeLetter; %Donne le nom de l'electrode à la position souhaité pour l'affichage dans le XTick label

%%

for n = 1:nb_files(1,2)
    load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name));
    Contacts{n,:} = PostT.Label_Bipolar(:,1);
end

for n = 1:nb_files(1,2)

    load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name));
    PostT.number_of_spikes(size(PostT.number_of_spikes):size(PostT.Label_Bipolar),1) = 0;
    PostT.number_of_spikes(PostT.number_of_spikes == 0) = NaN;
    x = 1:1:size(PostT.Label_Bipolar,1);
    scatter(x,PostT.number_of_spikes,'fill');
    hold on
    nbSpikeTotal(n,1) = sum(PostT.number_of_spikes,'omitnan');  
end

title('Distribution spatiale du nombre de pointes detectees','fontsize', 20);
xlabel('Electrodes');
xlim([0, size(channelKeep,1)]);
xticks([0:1:size(channelKeep,1)]);
set(gca,'XTick',1:nChannels);
set(gca,'XTickLabel',ElecAffiche);
set(gca, 'fontsize', 14)
ylabel('Nombre de pointe','fontsize', 14)
saveas(gcf,fullfile(analysis_path,'Distribution_spatial_nb_pointes'),'fig');
saveas(gcf,fullfile(analysis_path,'Distribution_spatial_nb_pointes'),'png');
close

%%



for n = 1:nb_files(1,2)
    load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name));
    PostT.number_of_spikes(size(PostT.number_of_spikes):size(PostT.Label_Bipolar),1) = 0;
    PostT.number_of_spikes(PostT.number_of_spikes == 0) = NaN;
    nbSpikeTotal(n,1) = sum(PostT.number_of_spikes,'omitnan');
    DayHour{n,1} = PostT.date;
end

figure
bar(nbSpikeTotal);
title('Nombre de pointe par session','fontsize', 20) %titre 
xlabel('Enregistrement (date, heure)','fontsize', 14)

xticks([1:size(nbSpikeTotal,1)]);
set(gca,'TickLabelInterpreter','none')
xticklabels(DayHour);
ylabel('Nombre de pointe','fontsize', 14);
saveas(gcf,fullfile(analysis_path,'nb_spike_inter_session'),'fig');
saveas(gcf,fullfile(analysis_path,'nb_spike_inter_session'),'png');

close all
% [a,b] = ismember(Contacts{1,1},Contacts{5,1});
% ContactsLast