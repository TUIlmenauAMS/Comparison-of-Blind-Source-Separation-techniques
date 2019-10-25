# Comparison-of-Blind-Source-Separation-techniques

This sample software applies Blind Source Separation (BSS) algorithms to simulated convolutive mixtures in order to compare separation performance.

1 - Offline BSS comparison
* The main file to run comparison:
"main_offline_bss_separation.m": AIRES vs TRINICON vs ILRMA vs AuxIVA

The main executable file separates convolutive mixture using our proposed Time Domain Stereo Audio Source Separation technique (AIRES)[1], time domain TRINICON[2], frequency domain BSS ILRMA[3,4] and AuxIVA[5]. For evaluation the Signal-to-Distortion Ratio, Signal-to-Interference Ratio and computation time for all 4 BSS are printed.

* How to change convolutive mixtures:

simply uncomment in the beginning of the file desired line with FileName "fname". 

Pay attention - all BSS work only with audio signals of 16kHz sampling rate.

[1] - O.  Golokolenko  and  G.  Schuller,  "Fast  time  domain stereo audio source separation using fractional delay filters," in
AES 147th Convention, 2019.

[2] - H. Buchner, R. Aichner, and W. Kellermann, "Trinicon: A versatile framework for multichannel blind signal processing,"  in
IEEE International Conference on Acoustics,  Speech,  and  Signal  Processing,  Montreal,  Que.,Canada, 2004.

[3] - D. Kitamura, N. Ono, H. Sawada, H. Kameoka, H. Saruwatari, "Determined blind source separation unifying independent vector analysis and nonnegative matrix factorization," IEEE/ACM Trans. ASLP, vol. 24, no. 9, pp. 1626-1641, September 2016.

[4] - D. Kitamura, N. Ono, H. Sawada, H. Kameoka, H. Saruwatari, "Determined blind source separation with independent low-rank matrix analysis," Audio Source Separation. Signals and Communication Technology., S. Makino, Ed. Springer, Cham, pp. 125-155, March 2018.  

[5] - Ono, Nobutaka. "Stable and fast update rules for independent vector analysis based on auxiliary function technique." WASPAA 2011.


2 - Online BSS comparison
* The main file to run comparison:
"main_online_bss_separation.m": AIRES vs TRINICON

* Convolutive mixtures are too big. Please download the samples here https://drive.google.com/open?id=1NrkBwqkX3oZdTdNIPzpg9jV9wfqwnnmW and move them into "convolutive_datasets" folder. 

The main executable file separates convolutive mixture using our proposed Time Domain Stereo Audio Source Separation technique (AIRES)[1], online time domain TRINICON[2]. For evaluation the Signal-to-Distortion Ratio, Signal-to-Interference Ratio and mean computation time per signal block are printed.

* How to change convolutive mixtures:

simply uncomment in the beginning of the file desired line with FileName "fname". 

Pay attention - all BSS work only with audio signals of 16kHz sampling rate.

[1] - O.  Golokolenko  and  G.  Schuller,  "A FAST STEREO AUDIO SOURCE SEPARATION FOR MOVING SOURCES," in ASILOMAR, 2019

[2] - Robert  Aichner,  Herbert  Buchner,  Fei  Yan,  and  Walter  Kellermann,   “A  real-time  blind  source  separation
scheme  and  its  application  to  reverberant  and  noisy acoustic environments,” Signal Processing, vol. 86, no.6, pp. 1260 – 1277, 2006,  Applied Speech and Audio Processing.



Oleg Golokolenko, oleg.golokolenko@tu-ilmenau.de, October 2019.
