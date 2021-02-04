%% soconnect_mri_input_main_TG_longitudinal.m 
%% input script for preproccessing and analyses of task-fMRI data SoConnect project longitudinal - Mariet van Buuren

%% Using this script:
% 1)change paths to correct directories
% 2)fill in the subjectcodes (numbers only) of the to-be-processed subjects
% 3)series: fill in the number of scan of the task/period of interest and place a 0 for scans not of interest or missing
% 4)change info.whatscans so it holds the number of the scans of interest.  
% 5)jobinput: fill in 1 and 0 indicating which steps you want to run (1) or want to skip (0)

%% version 1.0 18/09/2020 - Mariet van Buuren 
% (dd/mm/yyyy)
%18/09/2020 based on soconnect_mri_input_main_task
% 18/09/2020 specified for TG longitudinal


clear all
close all
clc

global dirs info
%% first set paths and directories
info.wave=1;   %% ADJUST TO ANALYZE PARTICULAR WAVE

if info.wave==1,
    dirs.rootraw = fullfile('/data','mariet','SoConnect','DATA','MRI');
elseif info.wave==2,
    dirs.rootraw = fullfile('/data','mariet','SoConnect','DATA_w2', 'MRI');
elseif info.wave==3,
    dirs.rootraw = fullfile('/data','mariet','SoConnect','DATA_w3', 'MRI');
   
end 

dirs.home= fullfile('/data','lisa','SoConnect','DATA');  %home directory
dirs.scripts=  fullfile('/data','lisa','SoConnect','scripts','MRI'); % directory of scripts
dirs.root = fullfile(dirs.home,'MRI');

cd(dirs.root)
dirs.reports = fullfile(dirs.root, 'Experimental','jobreports');

dirs.behav=fullfile(dirs.home,'behavioral'); % directory of behavioral data
if ~exist(char(dirs.reports),'dir'); mkdir(char(dirs.reports)); end

addpath(genpath('/data/lisa/programmes/SPM/spm12/'))  %% directory to spm 
addpath([dirs.scripts,'/']);
addpath(fullfile(dirs.scripts,'data_quality/'));
addpath (fullfile(dirs.scripts,'dicm2nii/'));


%% then specify subjects and scans
if info.wave==1,
    
    %subjects = [1,2,3,4,6:1:20,22:1:86]; %%% all sucbjects
    subjects = [1,2,3,4,6:1:15,17,18,20,22:1:25,27,30,33,34,36:1:54,56:1:60,63,65:1:70,72:1:80,82:1:82,85:1:86]; %first level: exclusion based on motion and brain abnormality
    info.run = {'T1','RS','MT','TG'};
    info.whatscans=[1,4];  %% numbers refer to series so 1 refers to series{1} ie T1. Remove the number of the scans you are not interested in
    
elseif info.wave==2,
    
    %subjects = [1,2,6,9,12,13,14,15,18,20,22,23,24,25,26,27,28,29,30,32,33,34,35,38,39,41,42,43,45,46,47,48,50,52,54,55,57,58,60,62,63,64,65,66,67,70,71,72,73,74,75,76,77,78,79,81,83,84,85,86];%%% all subjects
    subjects = [1,2,6,9,13,14,15,18,20,22,23,24,25,26,27,29,30,33,34,35,38,39,41,42,43,45,46,47,48,50,52,54,55,57,58,60,63,64,65,66,67,70,71,72,73,74,75,77,78,79,81,85,86];% First level: exclusion based on motion and brain abnormality
    info.run = {'T1','RS','MT','TG'};
    info.whatscans=[1,4];  %% numbers refer to which runs you want to analyze
    
elseif info.wave==3,
    
    %subjects=[1,2,6,10,12,15,20,23,24,25,27,28,30,32,33,35,38,39,42,43,45,46,47,48,50,52,54,57,58,60,62,63,64,65,67,68,70,71,72,73,74,77,78,79,81,84,85,86];  %all subjects
    subjects= [1,2,6,10,15,20,23,24,25,27,28,30,32,33,35,39,42,43,46,47,48,52,54,57,58,62,63,65,67,68,70,71,72,73,74,77,78,79,81,84,85,86]; %Subjects first level: exclusion based on motion 
    info.run = {'T1','RS','MT','TG'};
    info.whatscans=[1,4];  %% numbers refer to which runs you want to analyze
end
    
%% specify which jobs need to run/inputs 0=skip, 1= perform
clear jobinputs
for i =1:numel(subjects)
                jobinputs{i,1} = subjects(i);   %subj
                jobinputs{i,2} = 0;             %sort data --> uses dicm2nii package of Xiangrui Li
                jobinputs{i,3} = 0;             %realignment
                jobinputs{i,4} = 0;             %preprocessing after realignment
                jobinputs{i,5} = 0;             %tsnr check normalized data
                jobinputs{i,6} = 0;             %first level analysis
end
for i = 1:size(jobinputs,1)
          soconnect_mri_pipeline_main_TG_longitudinal(jobinputs(i,:))
end