clear; close all;
filename = "sample.wav";
[recording, Fs] = audioread(filename);
plot(real(fft(recording)));