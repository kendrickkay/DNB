function model = DNBmethod_GLMmelodicliberal(dataset,figuredir,hrf)

% function model = DNBmethod_GLMmelodicliberal(dataset,figuredir,hrf)
%
% <dataset>,<figuredir>,<hrf> are the inputs that a denoising method
%   is expected to accept.  Please see the README for details.
%
% Apply the ICA-based denoising with a liberal threshold (3) for
% which component timecourses are noise (i.e. we throw out a component
% if the R^2 value for the design matrix is less than 3 standard
% deviations away from the mean of randomly obtained R^2 values).  
% For more details, please see DNBmethod_GLMmelodic.m.

model = DNBmethod_GLMmelodic(dataset,figuredir,hrf,3);
