clear;
close all;
%setup midi devices
availableDevices = mididevinfo;
device = mididevice(availableDevices.output(2).ID); % MIDI mapper
% device = mididevice(availableDevices.output(4).ID); % loop MIDI
%setup audio recording
recDuration = 10;
Fs = 44100;
nBits = 16;
nChannels = 1;
recObj = audiorecorder(Fs, nBits, nChannels);
while 1
    disp("start recoding")
    %record sound
    recordblocking(recObj, recDuration);
    disp("end stop recording")
    sigsound = getaudiodata(recObj);    
    
    %find midi note messages
    midi_messages = create_midi(sigsound, Fs)';
    
    %send midi signals
    disp("playing midi")
    midisend(device, midi_messages);
    pause(recDuration+1)
end

