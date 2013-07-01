function f = DNBloaddata(varargin)

% ***** Calling style 1:
%
% function dataset = DNBloaddata(datasetnumber,'all');
% 
% <datasetnumber> is a positive integer
%
% Return <dataset>, which is a struct with all information
% regarding that dataset.
%
% ***** Calling style 2:
%
% function XYZ = DNBloaddata(datasetnumber,'XYZ');
%
% <datasetnumber> is a positive integer
%
% Return a single piece of information named XYZ.
% XYZ can be any of the fields in the dataset struct,
% such as 'design', 'data', or 'hrf'.  Please see the
% README file for full details.
% 
% ***** Calling style 3:
%
% function ... = DNBloaddata(datasetnumber,...,runix)
%
% <datasetnumber> is a positive integer
% <runix> is a vector of indices
%
% This is the same as the first two calling styles, except
% that <runix> is passed in.  By passing in <runix>, only information
% corresponding to the specific set of runs referred to by <runix> 
% is returned.  If <runix> is [] or not specified, we return 
% information for all runs.
%
% ***** Examples:
%
% Example of calling style 1:
% dataset = DNBloaddata(14,'all');
% dataset
%
% Example of calling style 2:
% design = DNBloaddata(14,'design');
% design
%
% Example of calling style 3:
% design = DNBloaddata(14,'design',[1 2]);
% design

% input
datasetnumber = varargin{1};

% figure out the path to the dataset file
filename = absolutepath(strrep(which('DNBloaddata'),'DNBloaddata.m', ...
                               sprintf('DNBdata/dataset%02d.mat',datasetnumber)));

% load in the desired information
if isequal(varargin{2},'all')
  f = load(filename);
else
  f = load(filename,varargin{2});
end

% figure out the runs that are desired
if length(varargin) < 3
  runix = [];
else
  runix = varargin{3};
end

% extract subset if necessary
if ~isempty(runix)
  if isfield(f,'data')
    f.data = f.data(runix);
  end
  if isfield(f,'dataRETRO1')
    f.dataRETRO1 = f.dataRETRO1(runix);
  end
  if isfield(f,'dataRETRO2')
    f.dataRETRO2 = f.dataRETRO2(runix);
  end
  if isfield(f,'design')
    f.design = f.design(runix);
  end
  if isfield(f,'motionparameters')
    f.motionparameters = f.motionparameters(runix);
  end
  if isfield(f,'runsets')
    f.runsets = f.runsets(runix);
  end
  if isfield(f,'runtypes')
    f.runtypes = f.runtypes(runix);
  end
end

% undo the struct if necessary
switch varargin{2}
case 'all'
otherwise
  f = f.(varargin{2});
end
