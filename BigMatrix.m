clear all
analysis_path = uigetdir(); %UI (user interface) get directory

    Directory = dir(analysis_path); %Put the directory in matlab
    file_names = {Directory.name}; 
    [Selection, OK] = listdlg('PromptString','Select files to analyse',...
                      'SelectionMode', 'multiple', ...
                       'ListString', file_names);
    [nb_files] = size(Selection);
    
    for n = 1:nb_files(1,2)
        %Load variables from file into workspace
        load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name)); %PostT file opening 
        C{n,1} = PostT.Amplitude.';
    end

% Création de la Matrice
    Matrice = cat(2,C{:,1}); %Concatenate arrays along specified dimension, cat(dim, C{:}) for concatenate a cell or structure array containing numeric matrices into a single matrix
    BigStd = std(Matrice,[],2,'omitnan');
    BigMean = mean(Matrice,2,'omitnan');
    
% Test cohérence matrice BigMean et BigStd
    Test = zeros(size(BigMean,1),1);
    Test1 = Test + double(isnan(BigMean));
    Test2 = Test + double(isnan(BigStd));
    Test3 = logical(Test1) & logical(Test2);
    verif1 = sum(double(Test3)-Test1);
    
% Supprimer les NaN
if verif1 == 0
    BigStd(isnan(BigStd),:)=[];
    BigMean(isnan(BigMean),:)=[];
    channelKeep = PostT.Label_Bipolar(~Test3,1);
else
    warndlg("attention c'est chelou")
end

% Répertoire traitement
BigPostT.Names_channel = channelKeep;
BigPostT.Big_matrice = Matrice;
BigPostT.Big_Mean = BigMean;
BigPostT.Big_Std = BigStd;
save(fullfile(analysis_path,'BigPostT'),'BigPostT');

% Pick up the letters of the electrodes
nChannels = size(channelKeep,1); %compte le nombre de contacts
for i = 1:nChannels
    tmp = channelKeep{i,1}; % Met le nom du contact dans un variable temporaire
    ChanLettersOnly{i,1} = tmp(isstrprop(tmp,'alpha')); % Prend uniquement les lettres de chaque contacts
end
[ElectrodeLetter,indexFirstContact,idx] = unique(ChanLettersOnly,'stable'); % Donne la lettre de chaque electrode (electrode A, electrode B etc...)
%ElecAffiche(size(idx,1)) = [];
ElecAffiche(indexFirstContact) = ElectrodeLetter; %Donne le nom de l'electrode Ã  la position souhaitÃ© pour l'affichage dans le XTick label

%Mise en forme
errorbar(BigMean,BigStd, 'color', [0 0 0]);
hold on
plot(BigMean,'r','LineWidth',3);
xlim([0, size(channelKeep,1)]);

legend('Standard deviation','Mean','Location','southwest');   %Légende
legend('boxoff');
title('Amplitude moyenne par session','fontsize', 20); %titre 
ylabel('Amplitude($\mu$V)','fontsize', 14);
xlabel('Electrodes','fontsize', 14);
xticks([0:1:size(channelKeep,1)]);
set(gca,'XTick',1:nChannels);
set(gca,'XTickLabel',ElecAffiche);
set(gca, 'fontsize', 12);


saveas(gcf,fullfile(analysis_path,'BigMatrix'),'fig');
saveas(gcf,fullfile(analysis_path,'BigMatrix'),'png');

close all