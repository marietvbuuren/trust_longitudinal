# trust_longitudinal

Matlab code used to analyze longitudinal fMRI data in trust game study in adolescence project, manuscript: Learning whom not to trust across early adolescence: a longitudinal neuroimaging study to trusting behavior involving an uncooperative other- Schreuders E., van Buuren M. et al.
Preregistration of analyses, as well as R code, can be found at  https://osf.io/b9mdh/. 
Preprint available at https://psyarxiv.com/xp8jz/ 

Matlab scripts run in combination with packages mentioned in manuscript; SPM 12, and marsbar, version 0.44.

Directory preprocessing_and_analyses contains main code used to run analyses. Function soconnect_mri_input_main_TG_longitudinal.m is used to set the directories, subjects and wave to be analyzed, as well as which steps to perform (i.e. various preprocessing steps, first-level analysis). This function calls soconnect_mri_pipeline_main_TG_longitudinal.m which runs the various preprocessing and analyses steps, by calling other functions and spm batches.

Three functions are run outside of the main pipeline: soconnect_motion_calculation_longitudinal_TG.m calculates absolute motion (>3mm) and framewise displacement per subject; soconnect_roi_analyzer_TG_longitudinal.m calculates signal changes in ROIs using marsbar and soconnect_tsnr_TG_longitudinal.m calculates average tSNR in ROIs using marsbar.
