function model = DNBmethod_GLMdenoiseblind(dataset,figuredir,hrf)

% function model = DNBmethod_GLMdenoiseblind(dataset,figuredir,hrf)
%
% <dataset>,<figuredir>,<hrf> are the inputs that a denoising method
%   is expected to accept.  Please see the README for details.
%
% Apply GLMdenoise to the data but do not prevent voxels related
% to the experiment from entering the noise pool.  In normal operation,
% voxels with cross-validated R^2 values above 0% are excluded from the
% noise pool, but here we allow them.  We return an estimate of the 
% task-related components using the output format that a denoising 
% method is expected to conform to.  Please see the README for details.
%
% Note that we do not use the supplied <hrf>.

% call GLMdenoisedata but do not attempt to exclude task-related voxels.
% this is achieved by stating that voxels with cross-validated R^2 values that
% are less than 110% are allowed (instead of the default 0%).  (the value of 
% 110% is arbitrary; anything above 100% is impossible.)
results = GLMdenoisedata(dataset.design,dataset.data,dataset.stimdur,dataset.tr, ...
                         [],[], ...
                         struct('seed',0,'bootgroups',dataset.runtypes,'brainR2',110,'wantpercentbold',0), ...
                         figuredir);

% save the estimated HRF
hrf = results.modelmd{1};
save([figuredir '/hrf.mat'],'hrf');

% return the model
model = @(design) GLMpredictresponses(results.modelmd,design,dataset.tr,cellfun(@(x) size(x,1),design),3);
