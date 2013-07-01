function model = DNBmethod_GLMretro1(dataset,figuredir,hrf)

% function model = DNBmethod_GLMretro1(dataset,figuredir,hrf)
%
% <dataset>,<figuredir>,<hrf> are the inputs that a denoising method
%   is expected to accept.  Please see the README for details.
%
% Apply GLMstandard to a version of the data that have already had the
% RETROICOR regressors removed.  Return an estimate of the task-related 
% components using the output format that a denoising method is expected 
% to conform to.  Please see the README for details.
%
% To ensure a direct comparison against GLMdenoise and GLMstandard,
% we use the supplied <hrf>.

% obtain the version of the data that has had the RETROICOR regressors 
% removed.  call GLMdenoisedata on these data, but do not use any PCs.
results = GLMdenoisedata(dataset.design,dataset.dataRETRO1,dataset.stimdur,dataset.tr, ...
                         'assume',hrf, ...
                         struct('seed',0,'bootgroups',dataset.runtypes,'numpcstotry',0,'wantpercentbold',0), ...
                         figuredir);

% return the model
model = @(design) GLMpredictresponses(results.modelmd,design,dataset.tr,cellfun(@(x) size(x,1),design),3);
