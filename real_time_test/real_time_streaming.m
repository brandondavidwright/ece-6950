close all; clear;

% File = dsp.AudioFileReader('sample.wav');
% Fs = File.SampleRate;

deviceReader = audioDeviceReader(44100);
setup(deviceReader)
Fs = deviceReader.SampleRate;


availableDevices = mididevinfo;
device = mididevice(availableDevices.output(2).ID);

% filename = "myTestAudio.wav";
% 
% fileWriter = dsp.AudioFileWriter(filename,'FileFormat','WAV');
disp('Start playing now.')
x = zeros(1);
previousNote = 0;
midi_m = zeros(1,1);
sampleBuffer = zeros(1);
noteBuffer = [0];
tic
while 1 
    sample = deviceReader(); %N=1024
    % sample = step(File);
    sampleBuffer = cat(1, sampleBuffer, sample);
    if length(sampleBuffer)/Fs > 0.07
        % disp(acquiredAudio);
        
        % disp(sample(:,1))
        f0 = pitchnn(sampleBuffer, Fs);
        n1 = numel(f0);
        n2 = length(sampleBuffer);
        f02 = interp1(1:n1, f0, linspace(1, n1, n2), 'nearest');
        % length(f)
        notes = freq_to_note(f02);
        noteBuffer = cat(2, noteBuffer, notes);
        midi_m = create_midi(notes, Fs, sampleBuffer, previousNote)
        previousNote = notes(end)
        midisend(device, midi_m(:,1));
        %fileWriter(sample);
        sampleBuffer = zeros(1);
    end
    
end
disp('Recording complete.')

plot(noteBuffer)

[recording, Fs] = audioread(filename);
sound(recording, Fs)

release(deviceReader)
release(fileWriter)