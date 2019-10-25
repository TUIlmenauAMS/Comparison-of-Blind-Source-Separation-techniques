%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sample program to compare several online (real-time) blind source       % 
% separation techniques:                                                  % 
% 1 - AIRES                                                               %
% 2 - TRINICON                                                            %
%                                                                         %
% Coded by O. Golokolenko (oleg.golokolenko@tu-ilmenau.de)                %
% Copyright 2019 Golokolenko Oleg                                         %
%                                                                         %
% These programs are distributed only for academic research at            %
% universities and research institutions.                                 %
% It is not allowed to use or modify these programs for commercial or     %
% industrial purpose without our permission.                              %
% When you use or modify these programs and write research articles,      %
% cite the following references:                                          %
%                                                                         %
% 1 - O.  Golokolenko  and  G.  Schuller,  "A FAST STEREO AUDIO SOURCE    %
% SEPARATION FOR MOVING SOURCES," in ASILOMAR, 2019                       %
%                                                                         %
% 2 - Robert  Aichner,  Herbert  Buchner,  Fei  Yan,  and  Walter         %
% Kellermann, “A  real-time  blind  source  separation scheme  and  its   %
% application  to  reverberant  and  noisy acoustic environments,”        %
% Signal Processing, vol. 86, no.6, pp. 1260 – 1277, 2006,                %
% Applied Speech and Audio Processing.                                    %                
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; clc;

%% Load simulated datasets
disp('Loading data');
fs = 16000;

addpath('convolutive_datasets');
fname = ['dataset_rt60-0.05_mix-0_moving_rnd-0.mat'];
%fname = ['dataset_rt60-0.1_mix-0_moving_rnd-0.mat'];
%fname = ['dataset_rt60-0.2_mix-0_moving_rnd-0.mat'];
loadedData = load(fname);
% Load original audio of moving SS (not mixed)
x_original = loadedData.original_rir_moving_ss;
% Load mixed audio of moving SS
x = loadedData.mixed_moving_ss;


if 1
    % rescale to avoid clipping
    scalefac = 1/ (max(max(abs(x_original(:))), max(abs(x(:)))));
    x = scalefac .* x;
    x_original = scalefac .* x_original;
end


%% Block processing
disp('Starting block processing');

% Initialize TRINICON online instance
[trinicon, blockShift] = TRINICON_online();
% Initialize AIRES online instance
aires = AIRES_online();

M = floor(size(x,1)/blockShift);
truncLen = M*blockShift;
x = x(1:truncLen,:);
x_unmixed_trinicon = zeros(size(x));
x_unmixed_aires = zeros(size(x));
x_original_new = x_original(1:truncLen,:);

%%
startTrinc = tic;
% loop over signal blocks
for m = 1:M
    idx = (1:blockShift) + (m-1)*blockShift;
    xBlock = x(idx,:);
    
    % Run online TRINICON
    block_time_start = tic;
    trinicon_yBlock = trinicon.processBlock(xBlock);
    runtime_trinicon(m) = toc(block_time_start);
    x_unmixed_trinicon(idx,:) = trinicon_yBlock(end-blockShift+1:end, :);
    
    % Run online AIRES
    block_time_start = tic;
    aires_yBlock = aires.separate_signals_online(xBlock);
    runtime_aires(m) = toc(block_time_start);
    x_unmixed_aires(idx,:) = aires_yBlock(end-blockShift+1:end, :); 
       
end
runtimeAlg = toc(startTrinc);
disp('Finished block processing');
%%

%disp(mean(runtime_trinicon_block));
fprintf('\tRuntime: %5.3f s\n', runtimeAlg);
%fprintf('\tRuntime per block: %5.3f s\n', runtimeAlg / M);
fprintf('\tRuntime per block TRINICON: %5.3f s\n', mean(runtime_trinicon));
fprintf('\tRuntime per block AIRES: %5.3f s\n', mean(runtime_aires));
fprintf('\n###########################################\n')



%% Calculate SDR, SIR TRINICON
disp('TRINICON evaluation');
[trinicon_results(1,:), trinicon_results(2,:), trinicon_results(3,:), trinicon_results(4,:)]= bss_evaluation(x_unmixed_trinicon, x_original_new);
fprintf('\n###########################################\n')
%% Calculate SDR, SIR AIRES
disp('AIRES evaluation');
[aires_results(1,:), aires_results(2,:), aires_results(3,:), aires_results(4,:)]= bss_evaluation(x_unmixed_aires, x_original_new);
fprintf('\n###########################################\n')
%% Calculate SDR, SIR Mixed VS Original
disp('Mixed VS Original evaluation');
[mixedVSoriginal_results(1,:), mixedVSoriginal_results(2,:), mixedVSoriginal_results(3,:), mixedVSoriginal_results(4,:)]= bss_evaluation(x, x_original_new);
%%


function [SDR, SIR, sdr_mean_block, sir_mean_block]= bss_evaluation(y, x_orig)
%% Calculate SDR, SIR
% Inputs:
% se: nsrc x nsampl matrix containing estimated sources
% s: nsrc x nsampl matrix containing true sources

[SDR, SIR, SAR, perm, SDR_block, SIR_block, SAR_block]=bss_eval_sources_shorttime(y.', x_orig.');
disp('SDR measure Original VS Unmixed (FULL to FULL)');
disp(SDR);
disp('SIR measure Original VS Unmixed (FULL to FULL)');
disp(SIR);
SDR_block = cell2mat(SDR_block);
sdr_mean_block = mean(SDR_block.');
fmt = ['The sdr_mean block (FULL to FULL) is: [', repmat('%g, ', 1, numel(sdr_mean_block)-1), '%g]\n'];
%fprintf(fmt, sdr_mean_block)
SIR_block = cell2mat(SIR_block);
sir_mean_block = mean(SIR_block.');
fmt = ['The sir_mean block (FULL to FULL) is: [', repmat('%g, ', 1, numel(sir_mean_block)-1), '%g]\n'];
%fprintf(fmt, sir_mean_block)

end

function [t, blockShift] = TRINICON_online()
%% TRINICON configuration
% NOTE: this implementation only supports nMic = nSrc = 2 !

% number of microphones (= input channels)
cfg_trinicon.nMic = 2;
% number of sources (= output channels)
cfg_trinicon.nSrc = 2;

% length of unmixing filter w (in samples)
cfg_trinicon.L =  256; %512;
% number of maximum delays for calculation of correlation
cfg_trinicon.D = cfg_trinicon.L-1;

% off-line block length (in samples)
cfg_trinicon.blockLen = 2 * cfg_trinicon.L;

% number of off-line blocks
cfg_trinicon.K = 2;

% length of online block; do not change!
cfg_trinicon.blockLenOnline = cfg_trinicon.K * cfg_trinicon.blockLen;

% overlap factor between successive on-line blocks
cfg_trinicon.alpha = cfg_trinicon.K;

% Sylvester constraint: 'SCC': column SC,   'SCR': row SC
cfg_trinicon.SC = 'SCC';

% shift of unit impulse at initialization (in samples); should be chosen
% large enough to cover the intermicrophone distance
cfg_trinicon.initShift = 20;

% adaptation step size
cfg_trinicon.stepSize = 0.001;

% number of iterations
cfg_trinicon.numIter = 2;

% efficient broadband inverse
% dynamical regularization of diagonal elements of correlation matrix, e.g.,
%       R(:,1,1) = R(:,1,1) + delta*exp(-R(:,1,1)./sigma);
cfg_trinicon.delta = 0;
cfg_trinicon.sigma = 1;

% temporal smoothing of demixing filters
%   W_online = lambda .* W_old_online + (1-lambda) .* W_offline
% larger values provide stronger smoothing
cfg_trinicon.lambda = 0.2;

% create class instance
t = TRINICON_tdonline(cfg_trinicon);
blockShift = cfg_trinicon.blockLenOnline/cfg_trinicon.alpha;
end


function aires = AIRES_online()
%% AIRES configuration
% NOTE: this implementation only supports nMic = nSrc = 2 !

    aires = aires_class_online;    
    aires.maxdelay = 20;
    aires.n_blocks_signal_memory = 4;
    aires.Blocksize = 512;
    aires.n_iter_pro_block = 2;

end
