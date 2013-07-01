%% Run GLMstandard on dataset 1

%% Download dataset 1 (if necessary)

DNBdownloaddata(1);

%% Load dataset 1

dataset = DNBloaddata(1,'all');

%% Inspect contents of dataset 1

dataset
%%
dataset.data
%%
size(dataset.data{1})
%%
dataset.design
%%
dataset.motionparameters
%%

%% Run GLMstandard (GLMdenoise without noise regressors) on dataset 1

DNBrun(1,'GLMstandard');

%% Inspect the result

a1 = load(strrep(which('DNBrun'),'DNBrun.m',fullfile('DNBresults','GLMstandard_dataset01.mat')));
figure;
imagesc(makeimagestack(signedarraypower(a1.performance/100,0.5),[0 1]),[0 1]);
colormap(hot);
%%
