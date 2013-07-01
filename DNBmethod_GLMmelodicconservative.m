function model = DNBmethod_GLMmelodicconservative(dataset,figuredir,hrf)

% function model = DNBmethod_GLMmelodicconservative(dataset,figuredir,hrf)
%
% <dataset>,<figuredir>,<hrf> are the inputs that a denoising method
%   is expected to accept.  Please see the README for details.
%
% Apply the ICA-based denoising with a conservative threshold (0) for
% which component timecourses are noise (i.e. we throw out a component
% only if the R^2 value for the design matrix is less than the mean
% of randomly obtained R^2 values).  For more details, please see
% DNBmethod_GLMmelodic.m.

model = DNBmethod_GLMmelodic(dataset,figuredir,hrf,0);
