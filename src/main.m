%
% This program records ten seconds of audio, creates a MIDI message from
% the recording, and plays back the MIDI message over the Windows MIDI
% Mapper device.
% After the MIDI message is played back, another ten seconds are recorded
% and played back until the script is stopped.
%
clear;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Detect MIDI devices and set MIDI output                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
availableDevices = mididevinfo;
device = mididevice(availableDevices.output(2).ID); % MIDI mapper
% device = mididevice(availableDevices.output(4).ID); % loop MIDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Set up audio recording parameters                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
recDuration = 10;
Fs = 44100;
nBits = 16;
nChannels = 1;
recObj = audiorecorder(Fs, nBits, nChannels);
while 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Record sound from Windows default audio input                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp("start recoding")
    recordblocking(recObj, recDuration);
    disp("end stop recording")
    sigsound = getaudiodata(recObj);    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Find MIDI message from audio recordin                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    midi_messages = create_midi(sigsound, Fs)';
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Send MIDI messages to selected MIDI output                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp("playing midi")
    midisend(device, midi_messages);
    pause(recDuration+1)
end

