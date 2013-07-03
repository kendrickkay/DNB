Denoise Benchmark (DNB) is an architecture for testing and comparing denoising methods 
for task-based fMRI.  The performance metric is cross-validation accuracy, whereby
a denoising method is evaluated based on how accurately its estimate of task-related
responses predict held-out data.  DNB is written in MATLAB and consists of three 
main components:
  (1) fMRI data (21 datasets available)
  (2) Code framework for automatic evaluation of denoising methods
  (3) Implementations of several denoising methods
DNB is developed by Kendrick Kay (kendrick@post.harvard.edu).

To get started with DNB, add it to your MATLAB path:
  addpath(genpath('DNB'));
Then, change to the DNB directory and try running the example scripts.

For additional information, please visit:
  http://kendrickkay.net/DNB/

History of major code changes:
- 2013/07/03 - Version 1.0.

%%%%%%%%%%%%%%%%%% CONTENTS

These functions download various files not included in the DNB repository:
- DNBdownloaddata.m - Download datasets to the DNBdata directory
- DNBdownloadresults.m - Download results to the DNBresults directory

These are top-level functions:
- DNBrun.m - Evaluate a specific denoising method on a specific dataset
- DNBloaddata.m - Load in a dataset (requires the data to have been downloaded)
- DNBevaluatemethod.m - A helper function called by DNBrun.m

These are implementations of various denoising methods:
- DNBmethod_GLMdenoise.m - GLMdenoise
- DNBmethod_GLMdenoiseblind.m - GLMdenoise with no exclusion of task-related voxels
- DNBmethod_GLMdenoisescramble.m - GLMdenoise but with phase-scrambled noise regressors
- DNBmethod_GLMglobalsignal.m - GLMstandard with a global signal regressor
- DNBmethod_GLMmelodic.m - ICA-based denoising using FSL's MELODIC utility
- DNBmethod_GLMmelodicconservative.m - GLMmelodic using a conservative threshold for
                                       identification of noise components
- DNBmethod_GLMmelodicliberal.m - GLMmelodic using a liberal (aggressive) threshold for
                                  identification of noise components
- DNBmethod_GLMmotion.m - GLMstandard with motion parameters as regressors
- DNBmethod_GLMomnibus.m - A combination of RETROICOR+RVHRCOR, the use of a global 
                           signal regressor, and the use of motion regressors
- DNBmethod_GLMretro1.m - RETROICOR followed by GLMstandard
- DNBmethod_GLMretro2.m - RETROICOR+RVHRCOR followed by GLMstandard
- DNBmethod_GLMstandard.m - GLMdenoise with no noise regressors

These directories contain various utilities:
- external - A directory containing external MATLAB toolboxes
- utilities - A directory containing various utility functions

These are additional files:
- example1.m - An example script showing how to run a denoising method on a dataset
- example2.m - An example script that loads the results of the DNB and generates
               figures illustrating these results
- README - The file you are reading

%%%%%%%%%%%%%%%%%% ADDITIONAL CONTENTS

To maintain compactness, the DNB repository omits large files.  These large
files can be automatically downloaded using DNBdownloaddata.m and 
DNBdownloadresults.m, or can be manually downloaded at
  http://kendrickkay.net/DNBdata/
  http://kendrickkay.net/DNBresults/

Here is a summary of the downloadable files:
- DNBdata - This directory contains the fMRI data
  - datasetNN.mat - Data for dataset NN
  - datasetNN_physio.tar - Physiological data for dataset NN (available for some datasets)
- DNBresults - This directory contains the DNB results
  - results.mat - All benchmarking results
  - figures.tar - Figures illustrating the results

%%%%%%%%%%%%%%%%%% DEPENDENCIES

DNB has several code dependencies besides what is provided in the DNB repository.
These dependencies are as follows:
(1) GLMdenoise (http://github.com/kendrickkay/GLMdenoise/)
(2) FSL (http://fsl.fmrib.ox.ac.uk/fsl/)
    Only the 'melodic' and 'fsl_regfilt' utilities from FSL are used.
    It is assumed that a command-line call to 'melodic' and 'fsl_regfilt'
    will invoke the appropriate executables.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Copyright (c) 2013, Kendrick Kay
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this
list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

The name of its contributors may not be used to endorse or promote products 
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
