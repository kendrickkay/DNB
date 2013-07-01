function model = DNBmethod_GLMomnibus(dataset,figuredir,hrf)

% function model = DNBmethod_GLMomnibus(dataset,figuredir,hrf)
%
% <dataset>,<figuredir>,<hrf> are the inputs that a denoising method
%   is expected to accept.  Please see the README for details.
%
% Combine motion-parameter regressors (GLMmotion), global-signal
% regressor (GLMglobalsignal), and RETROICOR+RVHRCOR (GLMretro2)
% in a single denoising method.  Apply this method to the data.
% Return an estimate of the task-related components using the output
% format that a denoising method is expected to conform to.  
% Please see the README for details.
%
% To ensure a direct comparison against GLMdenoise and GLMstandard,
% we use the supplied <hrf>.

% compute the global signal (mean of each volume)
globalsignal = cellfun(@(x) mean(squish(x,3),1)',dataset.data,'UniformOutput',0);

% z-score the regressor to avoid conditioning problems
globalsignal = cellfun(@(x) calczscore(x,1),globalsignal,'UniformOutput',0);

% z-score the motion parameters to avoid conditioning problems
mp = cellfun(@(x) calczscore(x,1),dataset.motionparameters,'UniformOutput',0);

% combine global signal and motion parameters
combineregressors = cellfun(@(x,y) cat(2,x,y),globalsignal,mp,'UniformOutput',0);

% if physiological data were collected, obtain the version of the data that has 
% had the RETROICOR+RVHRCOR regressors removed.  otherwise, obtain the regular 
% version of the data.
if isfield(dataset,'dataRETRO2')
  datafield = 'dataRETRO2';
else
  datafield = 'data';
end

% call GLMdenoisedata on the data.  do not use any PCs.  however, use the global
% signal and motion parameters as additional regressors in the GLM.
results = GLMdenoisedata(dataset.design,dataset.(datafield),dataset.stimdur,dataset.tr, ...
                         'assume',hrf, ...
                         struct('extraregressors',{combineregressors}, ...
                                'seed',0,'bootgroups',dataset.runtypes, ...
                                'numpcstotry',0,'wantpercentbold',0), ...
                         figuredir);

% return the model
model = @(design) GLMpredictresponses(results.modelmd,design,dataset.tr,cellfun(@(x) size(x,1),design),3);
