function DNBdownloadresults

% function DNBdownloadresults
%
% Download the results of the Denoise Benchmark (DNB) into the 
% DNBresults directory (which is created if it does not exist).  
% If a given file already exists, it is not downloaded.  If you
% like, you may manually download the results from:
%   http://www.cmrr.umn.edu/~kendrick/DNBresults/

% figure out the path to the DNBresults directory
dirloc = absolutepath(strrep(which('DNBdownloadresults'),'DNBdownloadresults.m','DNBresults'));

% create the directory
mkdirquiet(dirloc);

% do it
files = {'results.mat' 'figures.tar'};
for q=1:length(files)
  fileloc = fullfile(dirloc,files{q});
  if exist(fileloc,'file')
    fprintf('The file %s already exists. Skipping.\n',files{q});
  else
    fprintf('Downloading %s (please be patient).\n',files{q});
    urlwrite(sprintf('http://www.cmrr.umn.edu/~kendrick/DNBresults/%s',files{q}),fileloc);
    fprintf('Downloading is done!\n');
  end
end
