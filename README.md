# Comparison-of-Blind-Source-Separation-techniques
Compare AIRES BSS with ILRMA and AuxIVA


This sample software apllies Blind Source Separation algorithms to simulated convolutive mixtures in order to compare them.

main_bss_separation.m is the main executable file which initially separates convolutive mixture using our proposed Time Domain Stereo Audio Source Separation technique (AIRES), ILRMA and AuxIVA. Ater separation main_bss_separation.m prints out Signal-to-Distortion measure and computation time for all 3 BSS (SIR and SAR also can be printed, since whey are calculated as well).

In order to change datasets (different distances and RT60) - simply uncomment in the beginning of the file desired line with FileName "fname". 

Pay attention - all BSS work only with audio signals of 16000kHz sampling rate.
