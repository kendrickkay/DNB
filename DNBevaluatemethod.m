function performance = DNBevaluatemethod(datasetnumber,denoisemethod,figuredir)

% function performance = DNBevaluatemethod(datasetnumber,denoisemethod,figuredir)
%
% <datasetnumber> is a positive integer
% <denoisemethod> is a function that basically accepts an fMRI dataset and returns
%   an estimate of the task-related components in those data.  Please see 
%   README for the details.
% <figuredir> is a directory location that can be used by <denoisemethod>
%   for writing figures, outputs, etc.  In order to indicate different cross-validation
%   iterations, we attach suffixes like _01, _02, etc. to the supplied <figuredir>.
%
% DNBevaluatemethod evaluates the performance of <denoisemethod> on the dataset
% referred to by <datasetnumber>.  This involves performing leave-one-run-out
% cross-validation, evaluating how well the <denoisemethod> predicts the
% time-series data in the left-out runs.  The metric that we use to quantify
% goodness of predictions is percent variance explained (R^2).  We compute
% R^2 after subtracting the mean and projecting out a linear trend from both
% the measured time-series and the predicted time-series (the reason for this
% is to remove the impact of signal drift).
%
% The output of this function is <performance>, a matrix of dimensions 
% X x Y x Z with the cross-validated R^2 values.
%
% Example:
% performance = DNBevaluatemethod(14,@DNBmethod_GLMstandard,'test');

%%%%%%%%%%%%%% Perform cross-validation and compute predictions

% report
fprintf('*** DNBevaluatemethod: evaluating method %s on dataset %d. ***\n',func2str(denoisemethod),datasetnumber);

% load in some information
runsets = DNBloaddata(datasetnumber,'runsets');
hrf = DNBloaddata(datasetnumber,'hrf');

% perform leave-one-run- (or run-set-) out cross-validation.
% record the predicted time-series in <predictions>.
predictions = {};
for p=1:max(runsets)

  % report
  fprintf('*** DNBevaluatemethod: performing cross-validation iteration %d of %d. ***\n',p,max(runsets));

  % determine split
  testix = find(runsets==p);
  trainix = setdiff(1:length(runsets),testix);

  % load the training dataset
  traindataset = DNBloaddata(datasetnumber,'all',trainix);

  % fit model
  model = feval(denoisemethod,traindataset,[figuredir sprintf('_%02d',p)],hrf(:,p));
  
  % clean up
  clear traindataset;
  
  % load the design matrices for the testing data
  testdesign = DNBloaddata(datasetnumber,'design',testix);

  % compute the predictions
  predictions(testix) = cellfun(@single,feval(model,testdesign),'UniformOutput',0);

  % clean up
  clear model;

end

%%%%%%%%%%%%%% Evaluate predictions against the data

% report
fprintf('*** DNBevaluatemethod: evaluating predictions against the data. ***\n');

% load all of the data
data = DNBloaddata(datasetnumber,'data');

% calc
xyzsize = sizefull(data{1},3);

% construct polynomial projection matrix (constant and linear terms)
polymatrix = {};
for p=1:length(data)
  polymatrix{p} = projectionmatrix(constructpolynomialmatrix(size(data{p},4),0:1));
end

% compute cross-validated R^2 values
performance = reshape(calccodcell( ...
  cellfun(@(a,b) a*squish(b,3)',polymatrix,predictions,'UniformOutput',0), ...
  cellfun(@(a,b) a*squish(b,3)',polymatrix,data,'UniformOutput',0), ...
  1),xyzsize);

% clean up
clear data;

% report
fprintf('*** DNBevaluatemethod: complete! ***\n');
