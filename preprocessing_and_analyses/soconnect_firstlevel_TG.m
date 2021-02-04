function soconnect_firstlevel_TG(whattodo, workdir,logfile,funcfiles,rpfile,symlinkdir_stat,subjname)

global dirs subj info

clear matlabbatch jobfilename 
% calculate onsets of the relevant conditions
[onset_invest_exp, onset_feedback_exp, onset_invest_ct, onset_feedback_ct,onset_nointerest_tot,durations_nointerest_tot, RT_ct, RT_exp]=soconnect_onsets_TG(logfile);

jobfile = fullfile(dirs.scripts,['soconnect_firstlevel_batch_TG.mat']);
load (jobfile)

matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(workdir);
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = funcfiles;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = onset_invest_exp;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = RT_exp;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = onset_invest_ct;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = RT_ct;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = onset_feedback_exp;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = onset_feedback_ct;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = onset_nointerest_tot;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration =durations_nointerest_tot;
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = rpfile;


jobfilename = [whattodo,'_RTsl_',subjname,'.mat'];
eval(['save ',dirs.reports,'/',jobfilename,' matlabbatch']);
%job = [dirs.reports,'/',jobfilename];
spm_jobman('initcfg')
spm_jobman('run', matlabbatch);

soconnect_copydata(workdir,symlinkdir_stat,subjname);