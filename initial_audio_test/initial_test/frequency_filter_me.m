 clear;
close all;


filename = "sample.wav";
[recording, Fs] = audioread(filename);
%sound(recording, Fs)
tFinal = 15;
t = 1/Fs:1/Fs:tFinal;
tt = t.';
% input = 100*sin(2*pi*440*t); 

figure
plot(recording);
  
% f0 = pitch(recording, Fs)
f0 = pitchnn(recording, Fs);

% %remap frequencyes
% n1 = length(recording);
% n2 = length(f0);
% temp = repmat(f0(1:floor(n1/n2):end), floor(n2), 1);
% f0_remapped = temp(1:end);

% n1 = length(recording);
% n2 = length(f0)
% t = round(n1/n2);
% k=[true,  diff(f0)~=0];
% k2 = find(k);
% k3 = [k2(2:end)-1 numel(k)];
% k4 =  k3-k2+1;
% m = round(k4*t);
% if all(diff(m) == 0)
%     out = reshape(ones(m(1),1)*f0(k),1,[]);
% else
%     out = cell2mat(arrayfun(@(x,y)x(ones(1,y)),f0(k),m,'un',0));
% end

n1 = numel(f0);
n2 = length(recording);
f02 = interp1(1:n1, f0, linspace(1, n1, n2), 'nearest');

figure
plot(f02)

notes = freq_to_note(f02);

%notes(notes ~= 18 & notes ~= 23 & notes ~= 28 & notes ~= 33 & notes ~= 37 & notes ~= 42) = NaN;

%soundsc(recording, Fs);

figure
plot(tt, notes);

%notes = [NaN 25 25 25 25 25 NaN 18 NaN 18 NaN 27 27 27 27 NaN 27 27 29 29 30 30 30 30 30 30 30 30 30];
%midi_messages = create_midi(notes, 2)';

midi_messages = create_midi(notes, Fs, recording)';

availableDevices = mididevinfo;
device = mididevice(availableDevices.output(2).ID);

midisend(device, midi_messages);

% input = [tt(:), recording(:)];

% output = sim("frequency_filter", tFinal);

%u_sim = timeseries(input, tt, "Name", "input");
% 
%output = sim("frequency_filter");

function note = freq_to_note(f)
    note = floor(12*log2(f./440) + 49);
    % note(isnan(note))=0;
    % note = round(smooth(note(:)));
end

function midi_m = create_midi(notes, fs, recording) 
% detect change
    notes(isnan(notes))=0;    
    pitch_change = diff(notes) ~= 0;

    SPL = splMeter("SampleRate", fs);
    pressure_levels = SPL(recording);

    figure
    plot(pressure_levels);

    % find indeces where note changes
    change_indeces = find(pitch_change);
    change_indeces = [change_indeces length(notes)];
    % change_indeces(length(change_indeces)) = length(notes);

    % midi_notes = zeros(1, length(change_indeces));
    % note_lengths = zeros(1, length(change_indeces));

    % create variables with midi note and length
    for i = 1:length(change_indeces)
        if i == 1
            note_peaks(i) = max(pressure_levels(i:change_indeces(i)));         
            note_lengths(i) = change_indeces(i);
        elseif i == length(change_indeces)
            note_peaks(i) = pressure_levels(i);
            midi_notes(i) = notes(change_indeces(i)); 
            note_lengths(i) = change_indeces(i) - change_indeces(i-1);
        else
            midi_notes(i) = notes(change_indeces(i)); 
            note_lengths(i) = change_indeces(i) - change_indeces(i-1);
            peak = max(findpeaks(pressure_levels(change_indeces(i-1):change_indeces(i))));
            if(isempty(peak)); peak = 0; end
            note_peaks(i) = peak;
        end
    end

    note_peaks(note_peaks<0) = 0;

    midi_notes;
    note_lengths;
    note_peaks

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
        timestamp = t(change_indeces(i-1)+1);
        midi_m(i, :) = midimsg("Note", 1, note, volume(i), note_length/fs, timestamp);
    end

    % midi_m = msgs;
end

function volume = find_volume(note_peak)
    volume = floor(127*note_peak/100);
end
    
