clear;
close all;
Fs = 1e4;
tFinal = 15;
t = 1/Fs:1/Fs:tFinal;
tt = t.';
% input = 100*sin(2*pi*440*t); 

filename = "sample.wav";
recording = audioread(filename);
figure
plot(tt, recording);

% f0 = pitch(recording, Fs)
f0 = pitchnn(recording, Fs);

figure
plot(f0)

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

notes = freq_to_note(f02);

% soundsc(recording, Fs);

figure
plot(notes);

midi_messages = create_midi(notes, Fs)';

availableDevices = mididevinfo;
device = mididevice(availableDevices.output(2).ID);

midisend(device, midi_messages);

% plot(t, d);
gw = .5; kf = .5; gphi = .5; gm = .5;



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

function midi_m = create_midi(notes, fs) 
    notes(isnan(notes))=0;

% detect change
    pitch_change = diff(notes) ~= 0;



    % find indeces where note changes
    change_indeces = find(pitch_change);
    change_indeces(length(change_indeces)) = length(notes);

    % midi_notes = zeros(1, length(change_indeces));
    % note_lengths = zeros(1, length(change_indeces));

    % create variables with midi note and length
    for i = 1:length(change_indeces)
        midi_notes(i) = notes(change_indeces(i));
        if i == 1 
            note_lengths(i) = change_indeces(i);
        else 
            note_lengths(i) = change_indeces(i) - change_indeces(i-1);
        end
    end

    midi_notes;
    note_lengths;

    t = 0:1/fs:length(notes)/fs;

    % msgs = [midimsg("Note", 1, midi_notes(1), 100, note_lengths(1), t(change_indeces(1)))]';
    
    
        note = midi_notes(1);
        if note == 0
            volume = 0;
        else
            volume = 100;
        end

    midi_m(i, :) = midimsg("Note", 1, note, volume, note_lengths(1), t(change_indeces(1)));

    for i = 2: length(midi_notes)
        note = midi_notes(i);
        note(isnan(note))=0; 
        if note == 0
            volume = 0;
        else
            volume = 60;
        end
        l = fs*note_lengths(i);
        index = change_indeces(i);
        note_length = note_lengths(i);
        time = t(change_indeces(i))
        midi_m(i, :) = midimsg("Note", 1, note, volume, note_length, time);
    end

    % midi_m = msgs;
end
    
