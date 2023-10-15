deviceReader = audioDeviceReader(1000);
setup(deviceReader)

Fs = deviceReader.SampleRate;

filename = "myTestAudio.wav";

fileWriter = dsp.AudioFileWriter(filename,'FileFormat','WAV');
disp('Speak into microphone now.')
x = zeros(1);
tic
while 1 
    sample = deviceReader();
    disp(length(sample))
    % disp(acquiredAudio);
    
    % disp(sample(:,1))
    f0 = pitchnn(sample, Fs);
    n1 = numel(f0);
    n2 = length(sample);
    f02 = interp1(1:n1, f0, linspace(1, n1, n2), 'nearest');
    % length(f)
    notes = freq_to_note(f02);
    midi_m = create_midi(notes, Fs, sample)
    midisend(device, midi_m);
    %fileWriter(sample);
end
disp('Recording complete.')


[recording, Fs] = audioread(filename);
sound(recording, Fs)

release(deviceReader)
release(fileWriter)