function model = DNBmethod_GLMdenoisescramble(dataset,figuredir,hrf)

% function model = DNBmethod_GLMdenoisescramble(dataset,figuredir,hrf)
%
% <dataset>,<figuredir>,<hrf> are the inputs that a denoising method
%   is expected to accept.  Please see the README for details.
%
% Apply GLMdenoise to the data but with the following modification:
% after noise regressors are derived, scramble the phase spectra of the
% regressors, and then proceed as usual.  This modification serves
% as a control and demonstrates that the noise regressors that are
% derived are specific and necessary to achieve improvements in
% cross-validation accuracy.  We return an estimate of the task-related 
% components using the output format that a denoising method is expected
% to conform to.  Please see the README for details.
%
% Note that we do not use the supplied <hrf>.

% call GLMdenoisedata using opt.pccontrolmode set to 1 (this causes the
% noise regressors to be phase-scrambled after they are derived)
results = GLMdenoisedata(dataset.design,dataset.data,dataset.stimdur,dataset.tr, ...
                         [],[], ...
                         struct('seed',0,'bootgroups',dataset.runtypes, ...
                                'pccontrolmode',1,'wantpercentbold',0), ...
                         figuredir);

% save the estimated HRF
hrf = results.modelmd{1};
save([figuredir '/hrf.mat'],'hrf');

% return the model
model = @(design) GLMpredictresponses(results.modelmd,design,dataset.tr,cellfun(@(x) size(x,1),design),3);
