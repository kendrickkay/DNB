function DNBrun(datasetnumber,methodname)

% function DNBrun(datasetnumber,methodname)
%
% <datasetnumber> is a positive integer
% <methodname> is a string with the name of the denoising method,
%   e.g., 'GLMdenoise', 'GLMglobalsignal', 'GLMmotion', etc.
%
% Call DNBevaluatemethod for the denoising method referred to by
% <methodname> and the dataset referred to by <datasetnumber>.
% The result is a matrix of cross-validated R^2 values; write this
% as a variable named 'performance' to DNBresults/METHOD_datasetNN.mat
% where METHOD is <methodname> and NN is the dataset number.
%
% Figures and other outputs may be saved to directories that start
% with the prefix 'DNBresults/METHOD_datasetNN'.
%
% Example:
% DNBrun(14,'GLMstandard');
% a = load('DNBresults/GLMstandard_dataset14.mat');
% meanvol = DNBloaddata(14,'meanvol');
% figure; imagesc(meanvol(:,:,5)); axis image; colormap(gray); colorbar;
% figure; imagesc(a.performance(:,:,5),[0 50]); axis image; colormap(hot); colorbar;

% figure out a directory name for figures, outputs, etc.
figuredir = absolutepath(strrep(which('DNBrun'),'DNBrun.m', ...
              sprintf('DNBresults/%s_dataset%02d',methodname,datasetnumber)));

% evaluate the method on the dataset
performance = DNBevaluatemethod(datasetnumber,str2func(sprintf('DNBmethod_%s',methodname)),figuredir);

% save the cross-validated R^2 values
save([figuredir '.mat'],'performance');
