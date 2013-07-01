%% Generate figures illustrating the DNB results

%% Download the DNB results (if necessary)

% download results
DNBdownloadresults;

% construct path to the DNB root directory
dnbdir = absolutepath(strrep(which('DNBrun'),'DNBrun.m',''));

%% Load in a .mat file that contains the DNB results

load(fullfile(dnbdir,'DNBresults','results.mat'));

%% Check the workspace

whos
%%

%% Write out spatial maps of cross-validated R^2 values

% for each dataset
for p=1:size(allR2,1)
  fprintf('writing cross-validated R^2 maps for dataset %d...',p);

  % for each denoising method
  for q=1:size(allR2,2)

    % if we have results available
    if ~isempty(allR2{p,q})
    
      % construct the filename
      file0 = sprintf(fullfile(dnbdir,'figures','dataset%02d_%s.png'),p,denoisemethods{q});

      % write out the spatial map with a hot colormap that ranges from 0% to 100%.
      % the R^2 values are square-rooted before conversion to colors such that
      % the dynamic range of the color map is concentrated at the low end.
      imwrite(uint8(255*makeimagestack(signedarraypower(allR2{p,q}/100,0.5),[0 1])),hot(256),file0);

    end

  end

  fprintf('done.\n');
end

%% Inspect a cross-validated R^2 map

figure;
imageactual(fullfile(dnbdir,'figures','dataset01_GLMdenoise.png'));
title('Cross-validated R^2 for GLMdenoise on Dataset 1');
%%

%% Write out spatial maps that provide additional information

% for each dataset
for p=1:length(meanvols)
  fprintf('writing additional maps for dataset %d...',p);

  % write out the mean volume
  file0 = sprintf(fullfile(dnbdir,'figures','dataset%02d_meanvol.png'),p);
  imwrite(uint8(255*makeimagestack(meanvols{p},1)),gray(256),file0);

  % write out a binary mask indicating which voxels were selected to compare denoising methods
  file0 = sprintf(fullfile(dnbdir,'figures','dataset%02d_voxelselection.png'),p);
  imwrite(uint8(255*makeimagestack(voxelselections{p},[0 1])),gray(256),file0);

  % write out the brain mask which helped determine the voxel selection
  file0 = sprintf(fullfile(dnbdir,'figures','dataset%02d_brainmask.png'),p);
  imwrite(uint8(255*makeimagestack(brainmasks{p},[0 1])),gray(256),file0);

  fprintf('done.\n');
end

%% Inspect these additional maps

figure;
imageactual(fullfile(dnbdir,'figures','dataset01_meanvol.png'));
title('Mean volume for Dataset 1');
%%

figure;
imageactual(fullfile(dnbdir,'figures','dataset01_voxelselection.png'));
title('Voxel selection for Dataset 1');
%%

figure;
imageactual(fullfile(dnbdir,'figures','dataset01_brainmask.png'));
title('Brain mask for Dataset 1');
%%

%% For each denoising method, calculate the median cross-validated R^2 value achieved on each dataset

% initialize  
summary = zeros([size(allR2) 3]);  % this will hold the median and the 16th and 84th percentiles of the bootstrapped medians

% for each dataset
for p=1:size(allR2,1)
  fprintf('calculating median R^2 values for dataset %d...',p);
  
  % for each denoising method
  for q=1:size(allR2,2)
    
    % if we don't have results, just insert NaNs
    if isempty(allR2{p,q})
      summary(p,q,1:3) = NaN;

    % otherwise, calculate the median and then a confidence interval via bootstrapping.
    % note that we consider only those voxels in the binary mask voxelselections{p}.
    else
      [d,d,summary(p,q,1:3)] = calcmdsepct(allR2{p,q}(voxelselections{p}));
    end

  end

  fprintf('done.\n');
end

%% Visualize a summary of the cross-validation results on a bar chart

% for visibility, we will divide up the figure into several plots.
% here we define which groups of datasets to show on a single plot.
ixs = {1:7 8:13 14:21};

% loop over groups of datasets
for p=1:length(ixs)

  % first, write out the figure to a .png file
  figure; setfigurepos([100 100 900 275]); hold on;
  h = bar(summary(ixs{p},:,1),1);  % plot the medians
  colormap(jet);
  for mm=1:length(h)
    tempxd = get(get(h(mm),'Children'),'XData');
    errorbar2(mean(tempxd([1 3],:),1),summary(ixs{p},mm,1)', ...
              squish(summary(ixs{p},mm,2:3),2)','v','r-','LineWidth',1);
  end
  set(gca,'XTick',1:length(ixs{p}),'XTickLabel',ixs{p});
  xlabel('Dataset');
  ylabel('Cross-validated R^2');
  legend(h,denoisenames,'Location','EastOutside');
  filename = sprintf(fullfile(dnbdir,'figures','summary%d.png'),p);
  print('-dpng',filename);
  close;

  % then, show this .png file in a figure window
  figure;
  imageactual(filename);
  title('Summary of cross-validation results');
  %%
  
end

%% Write out scatter plots that show a detailed comparison of each pair of denoising methods on each dataset

% for each dataset
for p=1:size(allR2,1)
  fprintf('writing scatter plots for dataset %d...',p);
  
  % for each denoising method
  for d1=1:size(allR2,2)

    % for each denoising method
    for d2=1:size(allR2,2)

      % skip if results are unavailable or if we are comparing a method to itself
      if isempty(allR2{p,d1}) || isempty(allR2{p,d2}) || d1==d2
        continue;
      end

      % write out the figure to a .png file
      figure; setfigurepos([100 100 500 500]); hold on;
      scatter(allR2{p,d1}(voxelselections{p}), ...
              allR2{p,d2}(voxelselections{p}),25,'r.');
      ax = axis;
      mn = min(ax([1 3]));
      mx = max(ax([2 4]));
      axis([mn mx mn mx]);
      axissquarify;
      axis([mn mx mn mx]);
      xlabel(sprintf('%s (cross-validated R^2)',denoisenames{d1}));
      ylabel(sprintf('%s (cross-validated R^2)',denoisenames{d2}));
      title(sprintf('Dataset %d',p));
      filename = sprintf(fullfile(dnbdir,'figures','scatter_%s_vs_%s_dataset%02d.png'), ...
                                  denoisemethods{d1},denoisemethods{d2},p);
      print('-dpng',filename);
      close;

    end

  end

  fprintf('done.\n');
end

%% Inspect one of these scatter plots

figure;
imageactual(fullfile(dnbdir,'figures','scatter_GLMstandard_vs_GLMdenoise_dataset01.png'));
%%
