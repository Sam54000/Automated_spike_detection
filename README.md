# Automated_spike_detection
 Interictal epileptic discharges spike detection and pipelines for either a single file or multiple files. 
 To run the programs in this repositroy you need to have (if it's not downloaded yet)
 - <a href="https://github.com/Sam54000/Spike_Detector">Spike_Detector</a>
 - <a href="https://github.com/Sam54000/Biosig">Biosig</a>
 Once Biosig downloaded, install it by opening 'biosig_installer.m'
 - <a href="https://github.com/Sam54000/Function-package">Function package</a>
 
 ## Organizing data
 1. First of all, on your computer, creat a new folder named "DataFolder" and where you will put all your signals (.m file or micromed .TRC file).
 2. In this folder you can creat other folders to sort files by day of recording, it's up to you. Do not put anything else in the folders.
 There is no need to rename the file i.e: for a file named EEG_345.TRC, the program will automatically renames it like:
 LLL_FF_day_startingTime_endTime.TRC
 
 ## Data analysis
 To start the analysis:
 1. Open the program "Single_file_automated_detection.m". 
 2. Change the path at line 11 and 12 put your the path of the folder where you downloaded biosig and fuction package repositories.
 3. Run the program. 
 4. It will ask you where is your DataFolder (you created previously), once you found it press 'open'. 
 5. Then, another window will open showing all the file contained in your DataFolder.
 6. Select the file(s) you want to analyse. And press open
 
 ## Potential issues
 The analysis require a lot of memory and CPU ressource, it can takes a while
