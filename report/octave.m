close all; clear;
f0 = 220;
f1 = 440;
f2 = 880;
fs = 44100;
t = 0:1/fs:0.009;

a = cos(2*pi*f0*t);
x = cos(2*pi*f1*t);
y = cos(2*pi*f2*t);

figure
plot(t,a,t,x)
title("Two notes one octave apart")
xlabel("Time (s)")
legend("A_3 (220 Hz)", "A_4 (440 Hz)");

