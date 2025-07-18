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
correct = 0;
for k = 1:20
    file = sprintf('%stest (%d).wav', testdir, k);
    [s, fs] = audioread(file);
    s = s / rms(s);

    v = mfcc(s, fs);

    dist = zeros(1, n);
    for i = 1:n
        d = disteu(v, code{i});
        dist(i) = sum(min(d, [], 2)) / size(d, 1);
    end

    [~, min_idx] = min(dist);

    if min_idx == k
        correct = correct + 1;
    end
end

accuracy = correct / 20 * 100;
fprintf('Accuracy: %.2f%%\n', accuracy);

%% Time-warping analysis
fprintf('\nTime-warping analysis for s8.wav:\n');
[s8, fs8] = audioread('dataset/test/s8.wav');
s8 = s8 / rms(s8);

alphas = 0.1:0.1:2.0;

for window_func = {@hamming, @hann}
    fprintf('\nWindow function: %s\n', func2str(window_func{1}));
    fprintf('Alpha | Recognized Speaker\n');
    fprintf('------|--------------------\n');

    for alpha = alphas
        s_warped = resample(s8, 1, round(1/alpha));

        v = mfcc(s_warped, fs8, window_func{1});

        dist = zeros(1, n);
        for i = 1:n
            d = disteu(v, code{i});
            dist(i) = sum(min(d, [], 2)) / size(d, 1);
        end

        [~, min_idx] = min(dist);
        fprintf('%5.1f | %d\n', alpha, min_idx);
    end
end

%% Noise analysis
fprintf('\nNoise analysis:\n');
snr_levels = [30, 20, 15, 10, 5];
accuracies_noise = zeros(size(snr_levels));

for i = 1:length(snr_levels)
    snr = snr_levels(i);
    fprintf('\nTraining with SNR = %d dB\n', snr);

    code_noisy = train_noisy(traindir, n, snr);

    correct_noise = 0;
    for k = 1:20
        file = sprintf('%stest (%d).wav', testdir, k);
        [s, fs] = audioread(file);
        s = s / rms(s);

        v = mfcc(s, fs, @hamming);

        dist = zeros(1, n);
        for j = 1:n
            d = disteu(v, code_noisy{j});
            dist(j) = sum(min(d, [], 2)) / size(d, 1);
        end

        [~, min_idx] = min(dist);

        if min_idx == k
            correct_noise = correct_noise + 1;
        end
    end

    accuracies_noise(i) = correct_noise / 20 * 100;
    fprintf('Accuracy with SNR %d dB: %.2f%%\n', snr, accuracies_noise(i));
end

figure;
plot(snr_levels, accuracies_noise, '-o');
xlabel('SNR (dB)');
ylabel('Accuracy (%)');
title('Accuracy vs. SNR');
grid on;