 analysis_path = uigetdir();

    Directory = dir(analysis_path);
    file_names = {Directory.name};
    [Selection, OK] = listdlg('PromptString','Select files to analyse',...
                      'SelectionMode', 'multiple', ...
                       'ListString', file_names);
    [nb_files] = size(Selection);
    
    for n = 1:nb_files(1,2)
        %Load variables from file into workspace
        load(fullfile(Directory(Selection(1,n)).folder,Directory(Selection(1,n)).name) , 0, 1); %PostT file opening 
         = PostT.Amplitude_SessionX;
    end
    
    Matrice = cat( ); %Concatenate arrays along specified dimension
    Std = std(Matrice);
