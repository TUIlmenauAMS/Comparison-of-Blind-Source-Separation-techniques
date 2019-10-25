%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sample program to compare several blind source separation techniques:   %
% 1 - AIRES                                                               %
% 2 - AuxIVA                                                              %
% 3 - Independent Low-Rank Matrix Analysis (ILRMA)                        %
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
% # reference:Ono, Nobutaka. "Stable and fast update rules for            %
% independent vector analysis based on auxiliary                          %
% function technique." WASPAA 2011.                                       %
% ZitengWANG@201901                                                       %
%                                                                         %
% # Original paper (The algorithm was called "Rank-1 MNMF" in this paper) %
% D. Kitamura, N. Ono, H. Sawada, H. Kameoka, H. Saruwatari, "Determined  %
% blind source separation unifying independent vector analysis and        %
% nonnegative matrix factorization," IEEE/ACM Trans. ASLP, vol. 24,       %
% no. 9, pp. 1626-1641, September 2016.                                   %
%                                                                         %
% # Book chapter (The algorithm was renamed as "ILRMA")                   %
% D. Kitamura, N. Ono, H. Sawada, H. Kameoka, H. Saruwatari, "Determined  %
% blind source separation with independent low-rank matrix analysis,"     %
% Audio Source Separation. Signals and Communication Technology.,         %
% S. Makino, Ed. Springer, Cham, pp. 125-155, March 2018.                 %
%                                                                         %
% Audio sample files are taken from TIMIT database: J. Garofolo           %
% et al., ???Timit acoustic-phonetic continuous speech corpus,??? 1993        %
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
aires_x_demixed= aires.separate_signals(x_mixed);
runtimeAlg = toc(startTrinc);
fprintf('\tRuntime: %5.3f s\n', runtimeAlg);


[SDR,SIR,SAR,perm]=bss_eval_sources(aires_x_demixed.',x_original.');
disp('AIRES BSS SDR measure Original VS Unmixed, [dB]');
disp(SDR);

% Play separated sound sources
%soundsc(aires_x_demixed(:,1), fs_);
%pause(5);
%soundsc(aires_x_demixed(:,2), fs_);
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

% Play separated sound sources
%soundsc(ilrma_x_demixed(:,1), fs_);
%pause(5);
%soundsc(ilrma_x_demixed(:,2), fs_);
%pause(5);
%%




