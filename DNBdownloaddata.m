function DNBdownloaddata(dataset)

% function DNBdownloaddata(dataset)
%
% <dataset> (optional) is a positive integer between 1 and 21.
%   Can be a vector of positive integers.  If [] or not supplied,
%   default to 1:21.
%
% Download the datasets specified by <dataset> into the DNBdata 
% directory (which is created if it does not exist).  If a given
% dataset already exists, it is not downloaded.  If you like, 
% you may manually download the datasets from:
%   http://stone.psychology.wustl.edu/DNBdata/

% internal constants
whichphysio = 14:21;

% input
if ~exist('dataset','var') || isempty(dataset)
  dataset = 1:21;
end

% calc
dataset = unique(dataset);

% figure out the path to the DNBdata directory
dirloc = absolutepath(strrep(which('DNBdownloaddata'),'DNBdownloaddata.m','DNBdata'));

% create the directory
mkdirquiet(dirloc);

% do it
for p=1:length(dataset)
  files = {};
  files{end+1} = sprintf('dataset%02d.mat',dataset(p));
  if ismember(dataset(p),whichphysio)
    files{end+1} = sprintf('dataset%02d_physio.tar',dataset(p));
  end
  for q=1:length(files)
    fileloc = fullfile(dirloc,files{q});
    if exist(fileloc,'file')
      fprintf('The file %s already exists. Skipping.\n',files{q});
    else
      fprintf('Downloading %s (please be patient).\n',files{q});
      urlwrite(sprintf('http://stone.psychology.wustl.edu/DNBdata/%s',files{q}),fileloc);
      fprintf('Downloading is done!\n');
    end
  end
end
