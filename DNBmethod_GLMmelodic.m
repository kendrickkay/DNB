function model = DNBmethod_GLMmelodic(dataset,figuredir,hrf,thresh)

% function model = DNBmethod_GLMmelodic(dataset,figuredir,hrf,thresh)
%
% <dataset>,<figuredir>,<hrf> are the inputs that a denoising method
%   is expected to accept.  Please see the README for details.
% <thresh> (optional) is the number of standard deviations above the mean
%   of randomly obtained R^2 values to use as a threshold.  If the R^2
%   of the design matrix regressed onto a component timecourse
%   is greater than <thresh>, then we retain that timecourse.
%   Otherwise, we remove that timecourse.  Default: 3.
%
% We apply a denoising method based on ICA as implemented in FSL's MELODIC utility.
% The idea is as follows: First, we remove drift from each fMRI run by projecting
% out polynomials (but preserving the mean of each voxel's time-series).  Second,
% we pass each fMRI run to MELODIC, which generates a number of component 
% timecourses. Third, we decide which timecourses are noise through a certain
% procedure (see below for details). Fourth, we use FSL's fsl_regfilt
% utility to remove those timecourses from the data.  Finally, we call
% GLMstandard on the data to derive an estimate of task-related components.
%
% The method used to decide which timecourses are noise involves regressing the
% timecourses against the design matrix of the experiment.  If the R^2
% value exceeds a certain threshold (see <thresh>), then we retain that
% timecourse.  If not, we remove that timecourse.
% 
% We return an estimate of the task-related components using the output 
% format that a denoising method is expected to conform to.  Please see 
% the README for details.
%
% To ensure a direct comparison against GLMdenoise and GLMstandard,
% we use the supplied <hrf>.

% input
if ~exist('thresh','var') || isempty(thresh)
  thresh = 3;
end

% internal constants
numshuffles = 1000;

% for each run, remove drift by projecting out polynomial regressors (but leave the mean intact)
for p=1:length(dataset.data)

  % calc number of time points
  numtime = size(dataset.data{p},4);

  % calc the maximum polynomial degree to use (this matches the behavior of GLMdenoise)
  polydeg = round(numtime*dataset.tr/60/2);
  
  % construct the polynomials
  pmatrix = projectionmatrix(constructpolynomialmatrix(numtime,0:polydeg));

  % project the polynomials out from the data but add the mean of each voxel back in
  dataset.data{p} = bsxfun(@plus,mean(dataset.data{p},4), ...
                           reshape((pmatrix * squish(dataset.data{p},3)')',size(dataset.data{p})));

end

% for each run, we will perform the ICA-based denoising
for p=1:length(dataset.data)

  % write the fMRI data for the current run to a temporary NIFTI file (file1) and call MELODIC.
  % the output will be stored in a temporary directory (dir1).
  file1 = [tempname '.nii'];
  dir1 = tempname;
  save_nii(settr_nii(make_nii(int16(dataset.data{p}),dataset.voxelsize),dataset.tr),file1);
  assert(unix(sprintf('melodic -i %s -o %s --tr=%.10f --report --verbose',file1,dir1,dataset.tr))==0);

  % load in the component timecourses
  timecourses = load([dir1 '/melodic_mix']);
  numtimecourses = size(timecourses,2);
  
  % obtain the design matrix for the current run and ignore conditions that do not occur in the run
  design = dataset.design{p};
  design = design(:,~all(design==0,1));
  
  % initialize
  throwout = [];  % a vector of indices of timecourses that we will remove
  R2 = zeros(1,numtimecourses);
  R2randommn = zeros(1,numtimecourses);
  R2randomsd = zeros(1,numtimecourses);
  modelfit = zeros(size(numtimecourses));
  
  % for each timecourse, determine how much variance (R^2) can be accounted for by the design matrix.
  % compare this R^2 value to that obtained when randomly shuffling the timecourse.
  % if the actual R^2 value is less than or equal to <thresh> standard deviations away 
  % from the mean of the randomly obtained R^2 values, we mark that timecourse for removal.
  for q=1:numtimecourses
  
    % prep
    opt = struct('wantpercentbold',0);

    % fit the design matrix to the timecourse
    results = GLMestimatemodel(design,timecourses(:,q)',dataset.stimdur,dataset.tr,'assume',hrf,0,opt);

    % fit the design matrix to randomly shuffled timecourses
    resultsRANDOM = GLMestimatemodel(design,permutedim(repmat(timecourses(:,q),[1 numshuffles]),1,[],1)', ...
       dataset.stimdur,dataset.tr,'assume',hrf,0,opt);

    % record R^2 values
    R2(q) = results.R2;
    R2randommn(q) = mean(resultsRANDOM.R2);
    R2randomsd(q) = std(resultsRANDOM.R2);
    
    % record the time-series fit of the model
    modelfit(:,q) = GLMpredictresponses(results.modelmd,design,dataset.tr,size(design,1),1);

    % if the actual R^2 value too low, mark this timecourse for removal
    if (R2(q) - R2randommn(q)) / R2randomsd(q) <= thresh
      throwout = [throwout q];
    end

  end
  
  % save the results
  save(sprintf([figuredir '_melodicrun%02d.mat'],p), ...
       'timecourses','R2','R2randommn','R2randomsd','modelfit','throwout');
  
  % if we do not need to remove components, just initialize some variables
  if isempty(throwout)
    file2 = [];
    file3 = [];

  % if we need to remove components, then use fsl_regfilt
  else
  
    % use fsl_regfilt to remove the components deemed to be noise.
    % the output will be stored in a temporary NIFTI file (file2).
    file2 = tempname;
    thelist = sprintf('%d,',throwout);
    assert(unix(sprintf('fsl_regfilt -i %s -d %s/melodic_mix -o %s -f "%s"', ...
                        file1,dir1,file2,thelist(1:end-1)))==0);
  
    % load in the NIFTI file and replace the data in our dataset 
    % with the contents of the NIFTI file
    file3 = gunziptemp([file2 '.nii.gz']);
    a1 = load_untouch_nii(file3);
    dataset.data{p} = single(a1.img);
    clear a1;

  end
  
  % clean up temporary files
  delete(file1);
  rmdir(dir1,'s');
  if ~isempty(file2)
    delete([file2 '.nii.gz']);
  end
  delete(file3);

end

% call GLMdenoisedata on the denoised data (do not use any PCs)
results = GLMdenoisedata(dataset.design,dataset.data,dataset.stimdur,dataset.tr, ...
                         'assume',hrf, ...
                         struct('seed',0,'bootgroups',dataset.runtypes, ...
                                'numpcstotry',0,'wantpercentbold',0), ...
                         figuredir);

% return the model
model = @(design) GLMpredictresponses(results.modelmd,design,dataset.tr,cellfun(@(x) size(x,1),design),3);
