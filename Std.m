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
    PostT.number_of_spikes(size(PostT.number_of_spikes):size(PostT.Label_Bipolar),1) = 0;
    PostT.number_of_spikes(PostT.number_of_spikes == 0) = NaN;
    nbSpikeTotal(n,1) = sum(PostT.number_of_spikes,'omitnan');
end
Ecart = std(nbSpikeTotal);