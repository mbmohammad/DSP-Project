clc
clear
close all
addpath(genpath('..'))

%% Parameters
traindir    = 'dataset/train/';
n           = 88;
code        = train(traindir, n);

testdir     = 'dataset/test/';

%% Speaker Recognition Loop
for k = 1:20
    %% To Do: Load test file, extract MFCC, compare with all codebooks,
    % compute distortion, find minimum, and evaluate recognition
end