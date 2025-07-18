function r = vqlbg(d, k)
    % VQLBG Vector quantization using the Linde-Buzo-Gray algorithm
    %
    % Inputs:
    %       d       : data, columns are training vectors
    %       k       : number of centroids required
    %
    % Outputs:
    %       r       : resulting codebook, columns are the centroids

    e = .01;
    r = mean(d, 2);

    for i = 1:log2(k)
        r = [r*(1-e), r*(1+e)];

        while (1)
            z = disteu(d, r);
            [m,ind] = min(z, [], 2);
            t = 0;
            for j = 1:2^i
                r(:, j) = mean(d(:, find(ind == j)), 2);
            end

            z = disteu(d, r);
            [m, ind] = min(z, [], 2);
            D = mean(m);

            if (((t - D) / t) < e)
                break;
            else
                t = D;
            end
        end
    end
end
