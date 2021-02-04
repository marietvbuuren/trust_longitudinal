   
function soconnect_roi_analyzer_TG_longitudinal
%Mariet van Buuren 2019, June
%% uses Marsbar Toolbox to extract average contrast estimates per ROI for each subject. Runs per wave
warning('off','all')

info.wave=1; % adjust to run for specific wave

if info.wave==1,
    
    subjects = [1,2,3,4,6:1:15,17,18,20,22:1:25,27,30,33,34,36:1:54,56:1:60,63,65:1:70,72:1:80,82:1:82,85:1:86]; %subject after exclusion based on motion and brain abnormality
  
elseif info.wave==2,
    
    subjects = [1,2,6,9,13,14,15,18,20,22,23,24,25,26,27,29,30,33,34,35,38,39,41,42,43,45,46,47,48,50,52,54,55,57,58,60,63,64,65,66,67,70,71,72,73,74,75,77,78,79,81,85,86];% subjects after exclusion based on motion and brain abn
 
elseif info.wave==3,
    
    subjects= [1,2,6,10,15,20,23,24,25,27,28,30,32,33,35,39,42,43,46,47,48,52,54,57,58,62,63,65,67,68,70,71,72,73,74,77,78,79,81,84,85,86];% subjects after exclusion based on motion
end

dirs.home= fullfile('/data','lisa','SoConnect','DATA');  %home directory
dirs.scripts=  fullfile('/data','lisa','SoConnect','scripts','MRI'); % directory of scripts
dirs.root = fullfile(dirs.home,'MRI');
dirs.tgroot = fullfile(dirs.root,'Experimental', 'data_group', 'TG');
dirs.masks=fullfile(dirs.tgroot,'masks'); %directory where rois (.mat) are located

wave=num2str(info.wave);

description='ROIs_5_8mm_';  %%used for outputfile, description of ROIs
dirs.output = fullfile(dirs.tgroot, 'roi_analyses');
dirs.statsroot=fullfile(dirs.root,'Experimental', 'data_indiv');
if  ~exist([dirs.output,'dir']); mkdir(dirs.output); end

addpath(genpath('/data/lisa/programmes/SPM/spm12/'))  %% directory to spm 
addpath(genpath('/data/lisa/programmes/marsbar-0.44/'))

roi_mat = cellstr(spm_select('FPList',dirs.masks,'.mat'));
for j=1 : length(roi_mat),
    roiname_tmp=char(roi_mat(j));
    [p n e v] = spm_fileparts(roiname_tmp);
    roiname=n;
    
    for isubject = 1: numel(subjects)
        subj = subjects(isubject);   %subj
        if subj<10,
            subjname = ['SoConnect_',wave,'_0',num2str(subj)];
        else
            subjname = ['SoConnect_',wave,'_',num2str(subj)];
        end
        name{isubject}=subjname;
        dirs.stats= fullfile(dirs.statsroot,['w', wave],subjname,'TG_workdir/');
                
        marsbar('on');                                      % Initialise MarsBar
        
        spm_mat = fullfile(dirs.stats,'SPM.mat');
        
        D = mardo(spm_mat);                             % Make MarsBar design object
        R = maroi('load_cell',cellstr(roi_mat{j}));               % Make MarsBar ROI object
        Y = get_marsy(R{:},D,'mean');
        xCon = get_contrasts(D);
        E = estimate(D,Y);
        E = set_contrasts(E,xCon);
        b = betas(E);
        [rep_strs, marsS, marsD, changef] = stat_table(E, [1:length(xCon)]);
        
        for c=1:length(xCon),
            con_values(isubject,c)=marsS.con(c);
        end
        clear  spm_mat D R Y  E b rep_strs marsS marsD changef dirs_stats
    end
    
    fid = fopen(fullfile(dirs.output,['Group_mean_',roiname,'_',description, wave,'_.txt']),'w+');
    fprintf(fid,['Data from ',roiname,'\n','subjectname']);
    for v=1:length(xCon),
        fprintf(fid,['\t', xCon(v).name]);
    end
    fprintf(fid,'\n');
    
    for cv=1: size(con_values,1)
        fprintf(fid,[name{cv},'\t',num2str(con_values(cv,:))]);
        fprintf(fid,'\n');
    end
    clear outputfile con_values t_values p stats mean_values fid cv roiname_tmp p n e v  roiname xCon D R Y file spm_mat
end