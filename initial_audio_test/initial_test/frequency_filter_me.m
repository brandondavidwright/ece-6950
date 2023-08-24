clear;
close all;
Fs = 1e4;
tFinal = 15;
t = 1/Fs:1/Fs:tFinal;
tt = t.';
% input = 100*sin(2*pi*440*t); 

filename = "sample.wav";
recording = audioread(filename);
plot(tt, recording);

% f0 = pitch(recording, Fs)
f0 = pitchnn(recording, Fs)

notes = freq_to_note(f0);

soundsc(recording, Fs);

plot(notes);

% plot(t, d);
gw = .5; kf = .5; gphi = .5; gm = .5;

% input = [tt(:), recording(:)];

% output = sim("frequency_filter", tFinal);

%u_sim = timeseries(input, tt, "Name", "input");
% 
%output = sim("frequency_filter");

function note = freq_to_note(f)
    note = 12*log2(f./440) + 49;
end
    
