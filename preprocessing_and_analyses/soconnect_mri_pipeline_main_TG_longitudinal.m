function soconnect_mri_pipeline_main_TG_longitudinal(jobinputs)

%% script to preprocess & analyze longitudinal fMRI task data project SoConnect
%% calls the following functions:
% - copy data from RAW to experimental folder & converts PAR/REC to niftii (3D)
% - preprocess data; 1 batch for all steps & using samplespecific tissuepriors
%   created with CerebroMatic- M. Wilke
% - runs data quality check on normalized data
% - runs first level analyses


%% version 1.0 18/09/2020 - Mariët van Buuren 
% (dd/mm/yyyy)
% 18/09/2020 based on soconnect_mri_pipeline_main_task: removed MT task-analyses
% 18/09/2020 created longitudinal pipeline, using name of files of
% conversion to .nii and does not perform QA before normalization - uses
% two batched to perform preprocessing; 1) realignment 2)all other steps 

global dirs subj info

subj = cell2mat(jobinputs(1));
todo.sort = cell2mat(jobinputs(2));
todo.real = cell2mat(jobinputs(3));
todo.preproc = cell2mat(jobinputs(4));
todo.wtsnr= cell2mat(jobinputs(5));
todo.firstlevel= cell2mat(jobinputs(6));

wave=num2str(info.wave);
%%relevant directories % subjectname
rawdirroot=fullfile(dirs.rootraw, 'RAW');
cd(rawdirroot);

if subj<10,
    niidirsubj= fullfile(dirs.root,'Experimental', 'data_indiv',['w',wave'],['SoConnect_',wave,'_0',num2str(subj)]);
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    t=dir(['SoConnect_',wave,'_0',num2str(subj), '*']);
    rawdirsubj= fullfile(dirs.rootraw, 'RAW',t.name);
    subjname = ['SoConnect_',wave,'_0',num2str(subj)];
else
    niidirsubj= fullfile(dirs.root,'Experimental', 'data_indiv',['w',wave'],['SoConnect_',wave,'_',num2str(subj)]);
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    t=dir(['SoConnect_',wave,'_',num2str(subj), '*']);
    rawdirsubj= fullfile(dirs.rootraw, 'RAW',t.name);
    subjname = ['SoConnect_',wave,'_',num2str(subj)];
end
clear t;

symlinkdir_stat=fullfile(dirs.root,'Experimental','data_group','TG','TG_firstlevel');


whatscans=info.whatscans;
run=info.run;
cd(dirs.reports);
% settings
description=[];
hpf_qa=128;
isi_qa=2;

%% sort raw data
if todo.sort == true
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    soconnect_prepare_sort_main_name(rawdirsubj,niidirsubj,info)
end

%% preprocessing 1
%(-)reallign functional data
if todo.real == true
     for i = 2:numel(whatscans)
            whattodo= ['preprocess_real_', run{whatscans(i)}];
            nrun = 1; % enter the number of runs here
            clear jobfile jobs inputs matlabbatch mbatch;
            jobfile =cellstr(fullfile(dirs.scripts,'soconnect_preprocess_real_batch_job.m'));
                       
            jobs = repmat(jobfile, 1, nrun);
            inputs = cell(1, nrun);
            reallign_input= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['.*\.nii$']));
          
            for crun = 1:nrun
                inputs{1, crun} = reallign_input; % Realign: Estimate & Reslice: Session - cfg_files
            end
            spm('defaults', 'FMRI');
            
            jobfilename = [whattodo,subjname, '.mat'];
            
            mbatch=spm_jobman('serial', jobs, '', inputs{:});
            eval(['save ',dirs.reports,'/',jobfilename,' mbatch']);
            cd ([niidirsubj,'/',run{whatscans(i)}]);
      end
end
    
%% preprocessing 2
%(-)coregister T1 to mean functional
%(-)slice time correction for TG
%(-)segment T1 using priors created by CerebroMatic (based on 84 adolescents)
%(-)use deformation maps to normalize T1 & functional images
%(-)smoothing with 6 6 6 mm smoothing kernel

if todo.preproc == true
    for i = 2:numel(whatscans)
            whattodo= ['preprocess_after_real_', run{whatscans(i)}];
            nrun = 1; % enter the number of runs here
            clear jobfile jobs inputs matlabbatch mbatch;
            jobfile =cellstr(fullfile(dirs.scripts,'soconnect_preprocess_after_real_batch_job.m'));
                       
            jobs = repmat(jobfile, 1, nrun);
            inputs = cell(3, nrun);
            slicetime_input= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['.*\.nii$']));
            coreg_inputref= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^mean.*\.nii$']));
            coreg_inputsrc= cellstr(spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['.*\.nii$']));
            
            for crun = 1:nrun
                inputs{1, crun} = slicetime_input; % Realign: Estimate & Reslice: Session - cfg_files
                inputs{2, crun} = coreg_inputref; % Coregister: Estimate: Reference Image - cfg_files
                inputs{3, crun} = coreg_inputsrc; % Coregister: Estimate: Source Image - cfg_files
            end
            spm('defaults', 'FMRI');
            
            jobfilename = [whattodo,subjname, '.mat'];
            
            mbatch=spm_jobman('serial', jobs, '', inputs{:});
            eval(['save ',dirs.reports,'/',jobfilename,' mbatch']);
            cd ([niidirsubj,'/',run{whatscans(i)}]);
            eval(['!rm aSoConnect*']);
            eval(['!rm SoConnect*']);
         end
end


%% perform signal to noise (QA) analysis on normalized data
% perform quality check on realigned data (creates mask of resliced normalized T1) including signal change per scan, motion and tsnr
% maps, uses scripts following bzbtx, see https://github.com/bramzandbelt/fmri_preprocessing_and_qa_code
% and see for scripts adjusted for current project 'SoConnect': https://github.com/marietvbuuren/self_other_2020

if todo.wtsnr == true
    whatscans=info.whatscans;
    run=info.run;
    for i = 2:numel(whatscans)
        clear qadir srcimgs rpfile t1img
        qadir=fullfile(niidirsubj,[run{whatscans(i)},'_w_qadir']);
        if ~exist(qadir,'dir'); mkdir(qadir); end
        srcimgs= spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^waS','.*\.nii$']);
        rpfile=spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^rp_','.*\.txt$']);
        jobfile =cellstr(fullfile(dirs.scripts,'soconnect_reslic_anat_job.m'));
        nrun=1;
        jobs = repmat(jobfile, 1, nrun);
        inputs = cell(2, nrun);
        for crun = 1:nrun
            inputs{1, crun} = cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^waS','.*\.nii$']));  % Coregister: Reslice: Image Defining Space - cfg_files
            inputs{2, crun} =   cellstr(spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['^wSo','.*\.nii$'])); % Coregister: Reslice: Images to Reslice - cfg_files
        end
        spm('defaults', 'FMRI');
        
        jobfilename = ['reslanat_', subjname, '.mat'];
        
        mbatch=spm_jobman('serial', jobs, '', inputs{:});
        eval(['save ',dirs.reports,'/',jobfilename,' mbatch']);
        
        t1img=spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['^rwSo','.*.nii$']);
        hpf = hpf_qa;
        isi = isi_qa;
        cd (qadir)
        mvb_qa_fast('preproc',srcimgs,t1img,rpfile,isi,hpf,qadir)
        cd ([niidirsubj,'/',run{whatscans(i)}]);
        %else
        %end
    end
end


%% First-level analysis task
if todo.firstlevel == true
    for i = 2:numel(whatscans)
            clear workdir whattodo rpfile funcfiles
            whattodo= ['firstlevel_', run{whatscans(i)}];
            
            %set directories & scans & logfile
            workdir= fullfile(niidirsubj,[run{whatscans(i)},'_workdir']);
            if ~exist(workdir,'dir'); mkdir(workdir); end
            datadirbeh=fullfile(dirs.behav,['w',wave],run{whatscans(i)},'outputfiles');
            funcfiles= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^swaS','.*\.nii$']));
            rpfile=cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^rp_','.*\.txt$']));
            
            logfile=[datadirbeh,'/','SC', wave,'_',num2str(subj),'_trustgame_run1.csv'];
            
            if ~exist(symlinkdir_stat,'dir'); mkdir(symlinkdir_stat); end
            
            %create onsetfiles & run firstlevel analyses
            soconnect_firstlevel_TG(whattodo,workdir,logfile,funcfiles,rpfile,symlinkdir_stat,subjname);
         
    end
end
