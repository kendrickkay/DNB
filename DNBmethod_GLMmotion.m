function model = DNBmethod_GLMmotion(dataset,figuredir,hrf)

% function model = DNBmethod_GLMmotion(dataset,figuredir,hrf)
%
% <dataset>,<figuredir>,<hrf> are the inputs that a denoising method
%   is expected to accept.  Please see the README for details.
%
% Apply GLMstandard to the data but include motion parameter estimates
% as additional regressors in the GLM.  Return an estimate of the task-
% related components using the output format that a denoising method is 
% expected to conform to.  Please see the README for details.
%
% To ensure a direct comparison against GLMdenoise and GLMstandard,
% we use the supplied <hrf>.

% z-score the motion parameters to avoid conditioning problems
mp = cellfun(@(x) calczscore(x,1),dataset.motionparameters,'UniformOutput',0);

% call GLMdenoisedata but do not use any PCs and use motion parameters as regressors
results = GLMdenoisedata(dataset.design,dataset.data,dataset.stimdur,dataset.tr, ...
                         'assume',hrf, ...
                         struct('extraregressors',{mp}, ...
                                'seed',0,'bootgroups',dataset.runtypes, ...
                                'numpcstotry',0,'wantpercentbold',0), ...
                         figuredir);

% return the model
model = @(design) GLMpredictresponses(results.modelmd,design,dataset.tr,cellfun(@(x) size(x,1),design),3);
