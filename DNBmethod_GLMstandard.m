function model = DNBmethod_GLMstandard(dataset,figuredir,hrf)

% function model = DNBmethod_GLMstandard(dataset,figuredir,hrf)
%
% <dataset>,<figuredir>,<hrf> are the inputs that a denoising method
%   is expected to accept.  Please see the README for details.
%
% Apply GLMdenoise to the data but do not use any noise regressors.
% Return an estimate of the task-related components using the output 
% format that a denoising method is expected to conform to.  
% Please see the README for details.
%
% Note that we do not use the supplied <hrf>.

% call GLMdenoisedata but do not use any PCs
results = GLMdenoisedata(dataset.design,dataset.data,dataset.stimdur,dataset.tr, ...
                         [],[], ...
                         struct('seed',0,'bootgroups',dataset.runtypes,'numpcstotry',0,'wantpercentbold',0), ...
                         figuredir);

% save the estimated HRF
hrf = results.modelmd{1};
save([figuredir '/hrf.mat'],'hrf');

% return the model
model = @(design) GLMpredictresponses(results.modelmd,design,dataset.tr,cellfun(@(x) size(x,1),design),3);
