function c = mfcc(s, fs, window_type)
    % MFCC
    %
    % Inputs:
    %       s       : speech signal
    %       fs      : sample rate in Hz
    %
    % Outputs:
    %       c       : MFCC coefficient vector

    bank = melfb(20, 256, fs);
    bank = full(bank);
    bank = bank / max(bank(:));

    % DCT matrix
    for k = 1:12
        n = 0:19;
        dct(k, :) = cos((2 * n + 1) * k * pi / (2 * 20));
    end


    s = filter([1 -0.9375], 1, s);

    s = s(:);

    % frame blocking
    len = floor(length(s) * fs / 1000);
    inc = floor(len / 2);
    nf = floor((length(s) - len + inc) / inc);
    f = zeros(len, nf);
    indf = inc * (0:(nf-1));
    inds = (1:len)';
    f(:) = s(indf(ones(len, 1), :) + inds(:, ones(1, nf)));

    % windowing
    w = window(window_type, len);
    f = f .* w(:, ones(1, nf));

    % FFT
    t = abs(fft(f, 256));

    % Mel-frequency wrapping and DCT
    t = t(1:129, :);
    c = dct * log(bank * t);
end
