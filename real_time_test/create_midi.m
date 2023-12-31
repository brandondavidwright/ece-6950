function midi_m = create_midi(notes, Fs, recording, previousNote) 
    % detect change
    notes(isnan(notes))=0;
    previousNote(isnan(previousNote)) = 0;
    pitch_change = diff(notes) ~= 0;

    if previousNote == notes(1)
        %pitch_change(1,1) = 0;

    end

    SPL = splMeter("SampleRate", Fs);
    pressure_levels = SPL(recording);

    % find indices where note changes
    change_indices = find(pitch_change);
    change_indices = [change_indices length(notes)];

    note_peaks = zeros(1);
    midi_notes = zeros(1);
    note_lengths = zeros(1);

    % create variables with midi note and length
    for i = 1:length(change_indices)
        if i == 1
            note_peaks(i) = max(pressure_levels(i:change_indices(i)));   
            midi_notes(i) = notes(change_indices(i)); 
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

    t = 0:1/Fs:length(notes)/Fs;
    
    note = midi_notes(1);
  

    % midi_m(i, :) = midimsg("Note", 1, note, volume(1), note_lengths(1), t(1)); %TODO change
    if previousNote ~= note          
        if note == 0
            volume(1) = 0;
        else
            volume(1) = find_volume(note_peaks(1));
        end
        midi_m = midimsg("NoteOff", 1, previousNote, volume(1), t(1)); %TODO change
        midi_m = cat(1, midi_m,  midimsg("NoteOn", 1, note, volume(1), t(1))); %TODO change
    else
        % midi_m = midimsg("NoteOn", 1, note, volume, t(1)); %TODO change
        midi_m = zeros(1);
    end

    % do we need something for i = 1?

    for i = 2: length(midi_notes)
        note = midi_notes(i);
        if note == 0
            volume(i) = 0;
        else
            volume(i) = find_volume(note_peaks(i));
        end
        note_length = note_lengths(i)
        timestamp = t(change_indices(i-1)+1)
        % midi_m(i, :) = midimsg(v   "Note", 1, note, volume(i), note_length/Fs, timestamp); %TODO change
        midi_m = cat(1, midi_m, midimsg("NoteOff", 1, midi_notes(i-1), volume(i), timestamp)); %TODO change
        midi_m = cat(1, midi_m, midimsg("NoteOn", 1, note, volume(i), timestamp)); %TODO change
    end
end