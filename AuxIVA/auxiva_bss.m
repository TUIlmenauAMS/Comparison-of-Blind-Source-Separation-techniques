%AuxIVA
% reference:Ono, Nobutaka. "Stable and fast update rules for 
% independent vector analysis based on auxiliary function technique." WASPAA 2011.
% ZitengWANG@201901

function x_demixed=auxiva_bss(x_mixed, epochs)
%disp("Start AuxIVA separation ... ");
addpath('AuxIVA/STFT')

Nfft = 1024;
Nshift=Nfft/2;

% fft
X = stft_multi_2(x_mixed, Nfft);
[Nframe,Nbin,Nch] = size(X);

%% AuxIVA
% demixing matrix, Nbin x Nch x Nch 
W = repmat(eye(Nch),1,1,Nbin); W = permute(complex(W,0), [3,1,2]);
I = eye(Nch);
% Y: Nframe x Nbin x Nch
Y = squeeze(sum(bsxfun(@times, X, permute(conj(W), [4,1,2,3])) ,3));

%epochs = epochs;
for ep=1:epochs
    % Nframe x Nch
    R = sqrt(squeeze(sum(abs(Y).^2, 2)));
    Gr = 1 ./ (R+eps);
    for bin = 1:Nbin
        for ch = 1:Nch
            % compute V
            Vtmp = bsxfun(@times, permute(X(:,bin,:),[1,3,2]), conj(X(:,bin,:)));
            V = squeeze(sum(bsxfun(@times, Gr(:,ch), Vtmp), 1)) / Nframe;
            % update W
            WV = squeeze(W(bin,:,:))' * V;
            Wtmp = WV \ I(:,ch);
            Wtmp = Wtmp / sqrt(Wtmp' * V * Wtmp);
            W(bin,:,ch) = Wtmp;
        end
    end
    %??demixing
    Y = squeeze(sum(bsxfun(@times, X, permute(conj(W), [4,1,2,3])) ,3));
end

% project back
z = projection_back(Y, X(:,:,1));
Y = bsxfun(@times, Y, permute(z, [3,1,2]));


%% output
x_demixed = istft_multi_2(Y, size(x_mixed,1));

% Normilize input signal
x_demixed = x_demixed./(max(abs(x_demixed(:))));

%saveDir = 'GeneratedData\';
%audiowrite([saveDir 'AuxIVA_src1.wav'], y(:,1), fs);
%audiowrite([saveDir 'AuxIVA_src2.wav'], y(:,2), fs);

%%% to update: permutation exists in the separated signals
%%% check "Independent vector analysis based on overlapped cliques of 
%%% variable width for frequency-domain blind signal separation"
%disp("AuxIVA separation has been done");

% disp("Evaluation of separation in progress ...")
% sdr_sir_sar_results = zeros([3,2]);
% [SDR,SIR,SAR,perm]=bss_eval_sources(x_demixed.',x_original.');
% sdr_sir_sar_results(1,:) = SDR;
% sdr_sir_sar_results(2,:) = SIR;
% sdr_sir_sar_results(3,:) = SAR;

end
