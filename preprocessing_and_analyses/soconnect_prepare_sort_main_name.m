function soconnect_prepare_sort_main_name(rawdirsubj,niidirsubj,info)

%% script to copy data from RAW directory to experimental/analysis directory- fMRI data of main project SoConnect
%% calls the following functions:
% - copy data from RAW to experimental folder
% - converts PAR/REC to niftii (3D)

%% version 1.0 12/04/2018 - Mariët van Buuren
% (dd/mm/yyyy)
% 12/04/2018 based on soconnect_prepare_sort_main: added help information,
% and added converting PAR/REC to .nii using dicm2nii of Xiangrui Li
% 18/09/2020 based on soconnect_prepare_sort_main version 1.0, uses name of
% task in .PAR/REC file instead of number of run to convert to .nii
run=info.run;
whatscans=info.whatscans;

for i = 1:numel(whatscans)
    cd(niidirsubj)
    clear newdir; newdir = fullfile(cd,run{whatscans(i)});
    clear pardir; pardir = fullfile(cd,'PR',run{whatscans(i)});
    if ~exist(newdir,'dir'); mkdir(newdir); end
    if ~exist(pardir,'dir'); mkdir(pardir); end
    
    cd(fullfile(rawdirsubj));
    clear runname; runname= run{whatscans(i)};
    clear filename; filename = dir(['*',runname,'*']);
    for l=1:2, %copy PAR and REC
        clear scanname; scanname=filename(l).name;
        unix(['cp ' scanname ' ' pardir]);
    end
    dicm2nii(pardir,newdir,'.nii 3D');    
    cd(niidirsubj)
    eval(['!rm -r ' pardir])   
  end

for i = 2:(numel(whatscans))
     cd(niidirsubj)
    clear T1dirnew; T1dirnew = fullfile(cd,['T1_',run{whatscans(i)}]);
    if ~exist(T1dirnew,'dir'); mkdir(T1dirnew); end
    cd (run{whatscans(1)})
    clear filename; filename = dir('*.nii');
    clear scanname; scanname=filename.name;
    unix(['cp ' scanname ' ' T1dirnew]);
end
  cd(niidirsubj)
  clear removedir; removedir= run{whatscans(1)};
  eval(['!rm -r ' removedir])
    
    
       