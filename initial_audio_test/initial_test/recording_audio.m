clear;
close all;
recDuration = 15;
Fs = 1000;
nBits = 16;
nChannels = 1;
recObj = audiorecorder(Fs, nBits, nChannels);
disp("start")
recordblocking(recObj, recDuration);
disp("end")
play(recObj)
sigsound = getaudiodata(recObj);
plot(sigsound);
filename = "sample.wav";
audiowrite(filename, sigsound, Fs);