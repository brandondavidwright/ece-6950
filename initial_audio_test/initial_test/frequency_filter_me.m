clear;
close all;

filename = "sample.wav";
[recording, Fs] = audioread(filename);
% sound(recording, Fs)

tFinal = 15;
t = 1/Fs:1/Fs:tFinal;
tt = t.';

figure
plot(tt, recording)
xlabel("Time (s)")
ylabel("Amplitude")
title("Wave file of sound recording")

f0 = pitchnn(recording, Fs);

n1 = numel(f0);
n2 = length(recording);
f02 = interp1(1:n1, f0, linspace(1, n1, n2), 'nearest');

figure
plot(tt, f02)
xlabel("Time (s)")
ylabel("f_0 (Hz)")
title("Fundamental frequency f_0 of recording")

notes = freq_to_note(f02);

figure
plot(tt, notes);
xlabel("Time (s)")
ylabel("Key (A440)")
title("Keys of recording")

midi_messages = create_midi(notes, Fs, recording)';

availableDevices = mididevinfo;
% device = mididevice(availableDevices.output(2).ID);
device = mididevice(availableDevices.output(4).ID);


midisend(device, midi_messages);

function note = freq_to_note(f)
    note = floor(12*log2(f./440) + 49);
end

function midi_m = create_midi(notes, fs, recording)
    tFinal = 15;
    t = 1/fs:1/fs:tFinal;
    tt = t.';
    % detect change
    notes(isnan(notes))=0;    
    pitch_change = diff(notes) ~= 0;

    SPL = splMeter("SampleRate", fs);
    pressure_levels = SPL(recording);

    figure
    plot(tt, pressure_levels);
    xlabel("time (s)")
    ylabel("Sound pressue (dB)")
    title("Sound pressue of recording")

    % find indices where note changes
    change_indices = find(pitch_change);
    change_indices = [change_indices length(notes)];

    % create variables with midi note and length
    for i = 1:length(change_indices)
        if i == 1
            note_peaks(i) = max(pressure_levels(i:change_indices(i)));         
            note_lengths(i) = change_indices(i);
        elseif i == length(change_indices)
            note_peaks(i) = pressure_levels(i);
            midi_notes(i) = notes(change_indices(i)); 
            note_lengths(i) = change_indices(i) - change_indices(i-1);
        else 
            midi_notes(i) = notes(change_indices(i)); 
            note_lengths(i) = change_indices(i) - change_indices(i-1);
            peak = max(findpeaks(pressure_levels(change_indices(i-1):change_indices(i))));
            if(isempty(peak)); peak = 0; end
            note_peaks(i) = peak;
        end
    end

    note_peaks(note_peaks<0) = 0;

    t = 0:1/fs:length(notes)/fs;
    
    note = midi_notes(1);
    if note == 0
        volume(1) = 0;
    else
        volume(1) = find_volume(note_peaks(1));
    end

    midi_m(i, :) = midimsg("Note", 1, note, volume, note_lengths(1), t(1));

    for i = 2: length(midi_notes)
        note = midi_notes(i);
        if note == 0
            volume(i) = 0;
        else
            volume(i) = find_volume(note_peaks(i));
        end
        note_length = note_lengths(i);
        timestamp = t(change_indices(i-1)+1);
        midi_m(i, :) = midimsg("Note", 1, note, volume(i), note_length/fs, timestamp);
    end
end

function volume = find_volume(note_peak)
    volume = floor(127*note_peak/100);
end
    
