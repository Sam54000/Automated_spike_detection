%% Pick up the letters of the electrodes
nChannels = size(channelNames,1); %compte le nombre de contacts
for i = 1:nChannels
    tmp = channelNames{i,1}; % Met le nom du contact dans un variable temporaire
    ChanLettersOnly{i,1} = tmp(isstrprop(tmp,'alpha') | isstrprop(tmp,'punct')); % Prend uniquement les lettres de chaque contacts
end
[ElectrodeLetter,indexFirstContact,idx] = unique(ChanLettersOnly,'stable'); % Donne la lettre de chaque electrode (electrode A, electrode B etc...)
ElecAffiche(size(idx,1)) = [];
ElecAffiche(indexFirstContact) = ElectrodeLetter; %Donne le nom de l'electrode à la position souhaité pour l'affichage dans le XTick label

%########### Tu programme ta figure ici ##################
% Exemple : 
% plot(BigMean);
% errorbar(BigStd)

set(gca,'XTick',1:nChannels);
set(gca,'XTickLabel',ElecAffiche);
set(gca, 'fontsize', 12)
xlabel('Electrodes')