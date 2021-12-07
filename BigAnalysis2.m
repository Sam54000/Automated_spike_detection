analysis_path = uigetdir();
Directory = dir(analysis_path);
file_names = {Directory.name};
[Selection, OK] = listdlg('PromptString','Select files to analyse',...
                      'SelectionMode', 'multiple', ...
                       'ListString', file_names);
[nb_files] = size(Selection);
for n = 1:nb_files(1,2)
    load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name));
    AmplitudesMatAll{n,1} = PostT.Amplitudes;
end

BigMatrix = cat(2,C{:,1});
BigStd = std(BigMatrix,[],2);
BigMean = mean(BigMatrix,2);
