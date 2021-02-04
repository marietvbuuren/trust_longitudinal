function soconnect_motion_calculation_longitudinal_TG

%% to calculate scan to scan motion, or framewise displacement (FD) & absolute motion per subject. Runs per wave.
% Mariet van Buuren 2018 v3
% based on Power et al. 2012 and DPARSFA_run by YAN Chao-Gan
% v3.0 24/02/2020 added wave

info.wave=1; % change to run for a specific wave
dirs.home = fullfile('/data','lisa','SoConnect','DATA');

if info.wave==1,
    subjects = [1,2,3,4,6:1:20,22:1:86]; %all subjects
elseif info.wave==2,
    subjects = [1,2,6,9,12,13,14,15,18,20,22,23,24,25,26,27,28,29,30,32,33,34,35,38,39,41,42,43,45,46,47,48,50,52,54,55,57,58,60,62,63,64,65,66,67,70,71,72,73,74,75,76,77,78,79,81,83,84,85,86];; %all subjects
elseif info.wave==3,
    subjects= [1,2,6,10,12,15,20,23,24,25,27,28,30,32,33,35,38,39,42,43,45,46,47,48,50,52,54,57,58,60,62,63,64,65,67,68,70,71,72,73,74,77,78,79,81,84,85,86];  ; %all subjects
end

wave=num2str(info.wave);
dirs.scripts=  fullfile('/data','lisa','SoConnect','scripts','MRI');
dirs.root = fullfile(dirs.home,'MRI');

cd(dirs.root)
dirs.output = fullfile(dirs.root,'Experimental', 'data_group', 'TG', 'motion');
addpath(genpath('/data/lisa/programmes/SPM/spm12/'))
addpath(genpath(dirs.scripts))

if ~exist(dirs.output,'dir'); mkdir(dirs.output); end
for isubject = 1:numel(subjects)
 subj=subjects(isubject);       
 if subj<10,
     niidirsubj= fullfile(dirs.root,'Experimental', 'data_indiv',['w',wave],['SoConnect_',wave,'_0',num2str(subj)],'TG');
     subjname = ['SoConnect_',wave,'_0',num2str(subj)];
else
    niidirsubj= fullfile(dirs.root,'Experimental', 'data_indiv',['w',wave],['SoConnect_',wave,'_',num2str(subj)], 'TG');
    subjname = ['SoConnect_',wave,'_',num2str(subj)];
end
 
    name{isubject}=subjname;
    % SUBJECT LOOP
    rpfile = spm_select('FPList',[ niidirsubj,'/'],['^rp_','.*\.txt$']);
    rpmat = load(rpfile);
    rpmm=rpmat;
    rpmm(:,4:6)=rpmat(:,4:6)*50;
    rpmmabs=abs(rpmm);
    m=find(rpmmabs>3);
    if length(m)==0,
        mot=0;
    else mot=1;
    end
    RPDiff=diff(rpmat);
    RPDiff=[zeros(1,6);RPDiff];
    RPDiffSphere=RPDiff;
    RPDiffSphere(:,4:6)=RPDiffSphere(:,4:6)*50;% radius (i.e. distance between cortex and center of brain, in mm previously 65 mm, now 50 mm following Power et al. 2012)
    FD_Power=sum(abs(RPDiffSphere),2);
      
    MeanFD_Power(isubject) = mean(FD_Power);
    NumberFD_Power_05(isubject) = length(find(FD_Power>0.5));
    PercentFD_Power_05(isubject) = length(find(FD_Power>0.5)) / length(FD_Power);
    Motion_above_3mm(isubject)= mot;
    clear FD_Power RPDiff RPDiffSphere rpfile rpmat m mot
    
end

fid = fopen(fullfile(dirs.output,['FD_TG_w',wave,'.txt']),'w+');
fprintf(fid,'subject \t MeanFD_power \t NumberFD_Power_05 \t PercentFD_Power_05 \t AbsMotionAbove3mm  \n');

for i=1: numel(subjects)
    fprintf(fid, [char(name{i}),'\t', num2str(MeanFD_Power(i)),'\t',num2str(NumberFD_Power_05(i)),'\t', num2str(PercentFD_Power_05(i)), '\t', num2str(Motion_above_3mm(i)),'\n']);
end

clear fid
