%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sample program to compare several blind source separation techniques:   %
% 1 - AIRES                                                               %
% 2 - TRINICON                                                            %
% 3 - AuxIVA                                                              %
% 4 - Independent Low-Rank Matrix Analysis (ILRMA)                        %
%                                                                         %
% Coded by O. Golokolenko (oleg.golokolenko@tu-ilmenau.de) on July, 2019  %
% Copyright 2019 Golokolenko Oleg                                         %
%                                                                         %
% These programs are distributed only for academic research at            %
% universities and research institutions.                                 %
% It is not allowed to use or modify these programs for commercial or     %
% industrial purpose without our permission.                              %
% When you use or modify these programs and write research articles,      %
% cite the following references:                                          %
%                                                                         %
% 1 - O.  Golokolenko  and  G.  Schuller,  "Fast  time  domain            %
% stereo audio source separation using fractional delay filters,"         %
% in AES 147th Convention, 2019                                           %
%                                                                         %
% 2 - H. Buchner, R. Aichner, and W. Kellermann, "Trinicon: A versatile   %
% framework for multichannel blind signal processing,"  in                %
% IEEE International Conference on Acoustics,  Speech,  and  Signal       %
% Processing,  Montreal,  Que., Canada, 2004.                             %
%                                                                         %
% 3 - Ono, Nobutaka. "Stable and fast update rules for independent        %
% vector analysis based on auxiliary function technique." WASPAA 2011.    %
%                                                                         %
% 4 - D. Kitamura, N. Ono, H. Sawada, H. Kameoka, H. Saruwatari,          %
% "Determined blind source separation unifying independent vector         %
% analysis and nonnegative matrix factorization," IEEE/ACM Trans. ASLP,   %
% vol. 24,no. 9, pp. 1626-1641, September 2016.                           %
%                                                                         %
% 5 - D. Kitamura, N. Ono, H. Sawada, H. Kameoka, "Determined             %
% blind source separation with independent low-rank matrix analysis,"     %
% Audio Source Separation. Signals and Communication Technology.,         %
% S. Makino, Ed. Springer, Cham, pp. 125-155, March 2018.                 %
%                                                                         %
% Audio sample files are taken from TIMIT database: J. Garofolo           %
% et al., ???Timit acoustic-phonetic continuous speech corpus,??? 1993    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all; clc;

fs_ = 16000;

%% Load simulated dataset
fs = 16000;
addpath('convolutive_datasets')
%% RT60 = 0.05s and distance from sound sources to mics = 1m
%fname = 'stationary_ss_rt60-0.05_TIMIT_dist-1.0m.mat';
%% RT60 = 0.05s and distance from sound sources to mics = 2.5m
fname = 'stationary_ss_rt60-0.05_TIMIT_dist-2.5m.mat';
%% RT60 = 0.1s and distance from sound sources to mics = 1m
%fname = 'stationary_ss_rt60-0.1_TIMIT_dist-1.0m.mat';
%% RT60 = 0.1s and distance from sound sources to mics = 2.5m
%fname = 'stationary_ss_rt60-0.1_TIMIT_dist-2.5m.mat';
%% RT60 = 0.2s and distance from sound sources to mics = 1m
%fname = 'stationary_ss_rt60-0.2_TIMIT_dist-1.0m.mat';
%% RT60 = 0.2s and distance from sound sources to mics = 2.5m
%fname = 'stationary_ss_rt60-0.2_TIMIT_dist-2.5m.mat';

loadedData = load(fname);
% Load mixed audio
x = loadedData.mixed_ss;
% Load original audio (not mixed)
x_original = loadedData.original_rir_ss;


%% Resample, if necessary
%{
if isempty(fs)
    fs = fs_;
else
    if fs_ ~= fs
        warning('Sampling rates do not match. The sampling rate will be changed');
        x = resample(x,fs,fs_);
    end
end
%}

%% Play loaded audio file
%soundsc(x(:,1), fs_);
%soundsc(x(:,2), fs_);

%% Normilize input signal
x_mixed = x./(max(abs(x(:)))); 


%% Apply AIRES BSS
disp("****************");
disp("AIRES BSS");
startTrinc = tic;
% AIRES configuration
aires = aires_class_offline;
% Number of unmixing iteretions
aires.num_iterations = 20;
% Search stepsize
aires.alpha = 0.6;
aires_x_demixed = aires.separate_signals(x_mixed);
runtimeAlg = toc(startTrinc);
fprintf('\tRuntime: %5.3f s\n', runtimeAlg);


[SDR,SIR,SAR,perm]=bss_eval_sources(aires_x_demixed.',x_original.');
disp('AIRES BSS SDR measure Original VS Unmixed, [dB]');
disp(SDR);
disp('AIRES BSS SIR measure Original VS Unmixed, [dB]');
disp(SIR);

%% Apply TRINICON BSS
disp("****************");
disp("TRINICON BSS");
startTrinc = tic;
% TRINICON configuration
trinicon_x_demixed = trinicon_bss_fnc(x_mixed);
runtimeAlg = toc(startTrinc);
fprintf('\tRuntime: %5.3f s\n', runtimeAlg);


[SDR,SIR,SAR,perm]=bss_eval_sources(trinicon_x_demixed.',x_original.');
disp('TRINICON BSS SDR measure Original VS Unmixed, [dB]');
disp(SDR);
disp('TRINICON BSS SIR measure Original VS Unmixed, [dB]');
disp(SIR);

% Play separated sound sources
%soundsc(trinicon_x_demixed(:,1), fs_);
%pause(5);
%soundsc(trinicon_x_demixed(:,2), fs_);
%pause(5);

%% Apply AuxIVA BSS
disp("****************");
disp("AuxIVA BSS");
addpath('AuxIVA')
startTrinc = tic;
epochs=30;
auxiva_x_demixed = auxiva_bss(x_mixed, epochs);
runtimeAlg = toc(startTrinc);
fprintf('\tRuntime: %5.3f s\n', runtimeAlg);


[SDR,SIR,SAR,perm]=bss_eval_sources(auxiva_x_demixed.',x_original.');
disp('AuxIVA BSS SDR measure Original VS Unmixed, [dB]');
disp(SDR);
disp('AuxIVA BSS SIR measure Original VS Unmixed, [dB]');
disp(SIR);

% Play separated sound sources
%soundsc(auxiva_x_demixed(:,1), fs_);
%pause(5);
%soundsc(auxiva_x_demixed(:,2), fs_);
%pause(5);

%% Apply ILRMA BSS
disp("****************");
disp("ILRMA BSS");
addpath('ILRMA')
startTrinc = tic;
epochs=30;
ilrma_x_demixed = ilrma_bss(x_mixed, epochs);
runtimeAlg = toc(startTrinc);
fprintf('\tRuntime: %5.3f s\n', runtimeAlg);


[SDR,SIR,SAR,perm]=bss_eval_sources(ilrma_x_demixed.',x_original.');
disp('ILRMA BSS SDR measure Original VS Unmixed, [dB]');
disp(SDR);
disp('ILRMA BSS SIR measure Original VS Unmixed, [dB]');
disp(SIR);

% Play separated sound sources
%soundsc(ilrma_x_demixed(:,1), fs_);
%pause(5);
%soundsc(ilrma_x_demixed(:,2), fs_);
%pause(5);
%%


function x_unmixed_trinicon = trinicon_bss_fnc(x_mixed)

    %% TRINICON configuration

    % number of microphones (= input channels)
    cfg_trinicon.nMic = 2;
    % number of sources (= output channels)
    cfg_trinicon.nSrc = 2;

    % length of unmixing filter w (in samples)
    cfg_trinicon.L = 1024;
    % number of maximum delays for calculation of correlation
    cfg_trinicon.D = cfg_trinicon.L-1;

    % off-line block length (in samples)
    cfg_trinicon.blockLen = 2 * cfg_trinicon.L;

    % Sylvester constraint: 'SCC': column SC,   'SCR': row SC
    cfg_trinicon.SC = 'SCR';

    % shift of unit impulse at initialization (in samples); should be chosen
    % large enough to cover the intermicrophone distance
    cfg_trinicon.initShift = 20;

    % adaptation step size
    cfg_trinicon.stepSize = 0.01;

    % number of iterations
    cfg_trinicon.numIter = 600;


    % --- Inverses
    % inversion method:
    %   one of 'efficient_broadband', 'inv_narrowband'
    cfg_trinicon.compCorrInv = 'inv_narrowband';


    % -- efficient broadband inverse
    % value of regularization for sigma^2=0
    cfg_trinicon.effBroadPar.delta = 1;


    % --- narrowband inverse
    % regularization constant
    cfg_trinicon.invNrbPar.delta = eps;

    % DFT length for inversion
    cfg_trinicon.invNrbPar.NBR = 10 * cfg_trinicon.blockLen;

    % weighting factor between narrowband and broadband inverse, extremal values:
    %   0: narrowband,      1: broadband
    cfg_trinicon.invNrbPar.NBrho = 0.5;


    % - run offline TRINICON
    % inputs:
    %   cfg_trinicon:   configuration structure; see above
    %   x:              acoustic mixture (two channels);
    %                   dimension <nSamples x 2>
    %
    % outputs:
    %   y:              separated signals; same length as input;
    %                   dimension <nSamples x 2>
    %   W:              demixing system; dimension <L x nMic x nSrc>;
    %                   i.e., W(:,p,q) denotes the impulse response from
    %                   the p-th input to the q-th output    
    offlTrinc = CLASS_offlineTRINICON(cfg_trinicon);
    [x_unmixed_trinicon, W] = offlTrinc.sepSignals(x_mixed);   

end

