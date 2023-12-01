% clear
fs = 1;
t = 0:1/fs:2;

notes = [0 25 25 25 27 27 29 30 30 30 30 30];

midi_messages = create_midi(notes, fs)';

availableDevices = mididevinfo;
device = mididevice(availableDevices.output(2).ID);

midisend(device, midi_messages);

function note = freq_to_note(f)
    note = 12*log2(f./440) + 49;
end

function midi_m = create_midi(notes, fs) 
    % detect change
    pitch_change = diff(notes) ~= 0

    % find indices where note changes
    change_indices = [find(pitch_change) length(notes)]

    % midi_notes = zeros(1, length(change_indices));
    % note_lengths = zeros(1, length(change_indices));

    % create variables with midi note and length
    for i = 1:length(change_indices)
        midi_notes(i) = notes(change_indices(i));
        if i == 1 
            note_lengths(i) = change_indices(i);
        else 
            note_lengths(i) = change_indices(i) - change_indices(i-1);
        end
    end

    midi_notes
    note_lengths

    t = 0:1/fs:length(notes)/fs;

    % msgs = [midimsg("Note", 1, midi_notes(1), 100, note_lengths(1), t(change_indices(1)))]';

    midi_m(i, :) = midimsg("Note", 1, midi_notes(1), 100, note_lengths(1), t(1));

    for i = 2: length(midi_notes)
        note = midi_notes(i)
        l = note_lengths(i)
        index = change_indices(i)
        time = t(change_indices(i-1))
        midi_m(i, :) = midimsg("Note", 1, floor(midi_notes(i)), 100, note_lengths(i), t(change_indices(i-1)));
    end

    % midi_m = msgs;
end
     

    