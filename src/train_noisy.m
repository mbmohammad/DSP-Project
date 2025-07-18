function code = train_noisy(traindir, n, snr)
% Speaker Recognition: Training Stage (with noise)
%
% Input:
%       traindir : string name of directory contains all train sound files
%       n        : number of train files in traindir
%       snr      : signal-to-noise ratio in dB
%
% Output:
%       code     : trained VQ codebooks, code{i} for i-th speaker

k = 64;                         % number of centroids required

for i = 1:n                     % train a VQ codebook for each speaker
    file = sprintf('%ss%d.wav', traindir, i);
    disp(file);

    [s, fs] = audioread(file);
    s = s / rms(s);

    s_noisy = awgn(s, snr, 'measured');

    v = mfcc(s_noisy, fs, @hamming);

    code{i} = vqlbg(v, k);      % Train VQ codebook
end
