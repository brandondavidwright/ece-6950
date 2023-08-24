clear;
recDuration = 15;
Fs = 1e4;
nBits = 24;
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

