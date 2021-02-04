function soconnect_tsnr_roi_TG_longitudinal
%% uses Marsbar Toolbox to extract tSNR of ROIs for each subject. Runs per wave.
% Marie van Buuren 2020,September
warning('off','all')

info.wave=1; %adjust for specific wave
dirs.home = fullfile('/data','lisa','SoConnect','DATA');

if info.wave==1,
    subjects = [1,2,3,4,6:1:20,22:1:86]; %all subjects
elseif info.wave==2,
    subjects = [1,2,6,9,12,13,14,15,18,20,22,23,24,25,26,27,28,29,30,32,33,34,35,38,39,41,42,43,45,46,47,48,50,52,54,55,57,58,60,62,63,64,65,66,67,70,71,72,73,74,75,76,77,78,79,81,83,84,85,86];%all subjects
elseif info.wave==3,
    subjects= [1,2,6,10,12,15,20,23,24,25,27,28,30,32,33,35,38,39,42,43,45,46,47,48,50,52,54,57,58,60,62,63,64,65,67,68,70,71,72,73,74,77,78,79,81,84,85,86];  %all subjects
end

wave=num2str(info.wave);
dirs.scripts=  fullfile('/data','lisa','SoConnect','scripts','MRI');
dirs.root = fullfile(dirs.home,'MRI');

cd(dirs.root)
dirs.tgroot = fullfile(dirs.root,'Experimental', 'data_group', 'TG');
addpath(genpath('/data/lisa/programmes/SPM/spm12/'))

dirs.masks=fullfile(dirs.tgroot,'masks'); %directory where rois (.nii) are located


mapname=['tsnrvalues_rois_',wave];
cd(dirs.root)
dirs.output = fullfile(dirs.tgroot, 'tsnr');

if ~exist(dirs.output,'dir'); mkdir(dirs.output); end
for isubject = 1:numel(subjects)
    subj=subjects(isubject);
    if subj<10,
        subjname = ['SoConnect_',wave,'_0',num2str(subj)];
    else
        subjname = ['SoConnect_',wave,'_',num2str(subj)];
    end
    
    datadir= fullfile(dirs.root,'Experimental', 'data_indiv',['w', wave], subjname, 'TG_w_qadir/');
    name{isubject}=subjname;
    masks = cellstr(spm_select('FPList',dirs.masks,'.nii'));
    for j=1: length(masks),
        mask=char(masks(j));
        [p n e v] = spm_fileparts(mask);
        maskname=n;
        masknames{j}=maskname;
        Hm = spm_vol(mask);
        mask = spm_read_vols(Hm);
        mask = round(mask);
        clear y_b;
        x  = find(mask(:) == 1 );
        image=spm_select('FPList',datadir,['^tsnr_waS','.*\.nii$']);
        v_b = spm_vol([image]);
        tsnr= spm_read_vols(v_b);
        mean_tsnr{j}(isubject) = nanmean(tsnr(x));
        clear x mask maskname
    end
end

fid = fopen(fullfile(dirs.output,[mapname,'.txt']),'w+');
fprintf(fid,'subjname \t');
for j=1: length(masks),
    fprintf(fid,['tsnr_',masknames{j}, '\t']);
end
fprintf(fid,'\n');


for i=1: numel(subjects)
    fprintf(fid, [char(name{i}),'\t'])
    for j=1: length(masks),
        fprintf(fid, [num2str(mean_tsnr{j}(i)),'\t']);
    end
    fprintf(fid,'\n');
end

clear fid

 