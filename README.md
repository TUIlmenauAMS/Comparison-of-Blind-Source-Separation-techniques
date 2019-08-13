# Comparison-of-Blind-Source-Separation-techniques
Compare AIRES BSS with ILRMA and AuxIVA


This sample software applies Blind Source Separation (BSS) algorithms to simulated convolutive mixtures in order to compare separation performance.

* The main file to run comparison:

main_bss_separation.m

The main executable file separates convolutive mixture using our proposed Time Domain Stereo Audio Source Separation technique (AIRES), frequency domain BSS ILRMA[1,2] and AuxIVA[3]. Ater separation main_bss_separation.m prints out Signal-to-Distortion Ratio and computation time for all 3 BSS (SIR and SAR also can be printed, since whey are calculated as well).

* How to change convolutive mixtures:

simply uncomment in the beginning of the file desired line with FileName "fname". 

Pay attention - all BSS work only with audio signals of 16kHz sampling rate.

[1] - D. Kitamura, N. Ono, H. Sawada, H. Kameoka, H. Saruwatari, "Determined blind source separation unifying independent vector analysis and nonnegative matrix factorization," IEEE/ACM Trans. ASLP, vol. 24, no. 9, pp. 1626-1641, September 2016.

[2] - D. Kitamura, N. Ono, H. Sawada, H. Kameoka, H. Saruwatari, "Determined blind source separation with independent low-rank matrix analysis," Audio Source Separation. Signals and Communication Technology., S. Makino, Ed. Springer, Cham, pp. 125-155, March 2018.  

[3] - Ono, Nobutaka. "Stable and fast update rules for independent vector analysis based on auxiliary function technique." WASPAA 2011.


Oleg Golokolenko, oleg.golokolenko@tu-ilmenau.de, August 2019.
