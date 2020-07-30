clear all
analysis_path = uigetdir(); %UI (user interface) get directory

    Directory = dir(analysis_path); %Put the directory in matlab
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
    BigStd(isnan(BigStd),:)=[];
    BigMean(isnan(BigMean),:)=[];
    channelKeep = PostT.Label_Bipolar(~Test3,1);
else
    warndlg("attention")
end

%Processing directory
BigPostT.Names_channel = channelKeep;
BigPostT.Big_matrice = Matrice;
BigPostT.Big_Mean = BigMean;
BigPostT.Big_Std = BigStd;
save(fullfile(analysis_path,'BigPostT'),'BigPostT');

%Pick up the letters of the electrodes
nChannels = size(channelKeep,1); %Counts the number of contacts
for i = 1:nChannels
    tmp = channelKeep{i,1}; %Put the name of the contact in a temporary variable
    ChanLettersOnly{i,1} = tmp(isstrprop(tmp,'alpha')); %Takes only letters from each contact
end
[ElectrodeLetter,indexFirstContact,idx] = unique(ChanLettersOnly,'stable'); %Give the letter of each electrode (electrode A, electrode B etc...)
%ElecAffiche(size(idx,1)) = [];
ElecAffiche(indexFirstContact) = ElectrodeLetter; %Gives the name of the electrode at the desired position for display in the XTick label.

%% Figure
errorbar(BigMean,BigStd, 'color', [0 0 0]);
hold on
plot(BigMean,'r','LineWidth',3);

%Legend
xlim([0, size(channelKeep,1)]);
xticks([0:1:size(channelKeep,1)]);
legend('Standard deviation','Mean','Location','southwest');   
legend('boxoff');
ylabel('Amplitude(µV)','fontsize', 14);%$\mu$V
xlabel('Electrodes','fontsize', 14);
set(gca,'XTick',1:nChannels);
set(gca,'XTickLabel',ElecAffiche);
set(gca, 'fontsize', 14);
title('Amplitude moyenne sur toutes les sessions','fontsize', 20); 

% Save to the desired directory
saveas(gcf,fullfile(analysis_path,'BigMatrix'),'fig');
saveas(gcf,fullfile(analysis_path,'BigMatrix'),'png');

close all