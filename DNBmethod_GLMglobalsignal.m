function model = DNBmethod_GLMglobalsignal(dataset,figuredir,hrf)

% function model = DNBmethod_GLMglobalsignal(dataset,figuredir,hrf)
%
% <dataset>,<figuredir>,<hrf> are the inputs that a denoising method
%   is expected to accept.  Please see the README for details.
%
% Apply GLMstandard to the data but include an extra regressor in the GLM,
% namely, one regressor per run containing the mean of the functional
% volume at each time point.  Return an estimate of the task-related 
% components using the output format that a denoising method is 
% expected to conform to.  Please see the README for details.
%
% To ensure a direct comparison against GLMdenoise and GLMstandard,
% we use the supplied <hrf>.

% compute the global signal (mean of each volume)
globalsignal = cellfun(@(x) mean(squish(x,3),1)',dataset.data,'UniformOutput',0);

% z-score the regressor to avoid conditioning problems
globalsignal = cellfun(@(x) calczscore(x,1),globalsignal,'UniformOutput',0);

% call GLMdenoisedata but do not use any PCs and use the global signal as an additional regressor
results = GLMdenoisedata(dataset.design,dataset.data,dataset.stimdur,dataset.tr, ...
                         'assume',hrf, ...
                         struct('extraregressors',{globalsignal}, ...
                                'seed',0,'bootgroups',dataset.runtypes, ...
                                'numpcstotry',0,'wantpercentbold',0), ...
                         figuredir);

% return the model
model = @(design) GLMpredictresponses(results.modelmd,design,dataset.tr,cellfun(@(x) size(x,1),design),3);
