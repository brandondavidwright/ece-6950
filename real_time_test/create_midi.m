function midi_m = create_midi(notes, Fs, recording, previousNote) 
    % detect change
    notes(isnan(notes))=0;
    previousNote(isnan(previousNote)) = 0;
    pitch_change = diff(notes) ~= 0;

    if previousNote == notes(1)
        pitch_change(1,1) = 0; 
    end

    SPL = splMeter("SampleRate", Fs);
    pressure_levels = SPL(recording);

    % find indeces where note changes
    change_indeces = find(pitch_change);
    change_indeces = [change_indeces length(notes)];

    note_peaks = zeros(1);
    midi_notes = zeros(1);
    note_lengths = zeros(1);

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

    t = 0:1/Fs:length(notes)/Fs;
    
    note = midi_notes(1);
    if note == 0
        volume(1) = 0;
    else
        volume(1) = find_volume(note_peaks(1));
        %volume(1) = 100;
    end

    midi_m(i, :) = midimsg("Note", 1, note, volume(1), note_lengths(1), t(1)); %TODO change

    for i = 2: length(midi_notes)
        note = midi_notes(i);
        if note == 0
            volume(i) = 0;
        else
            volume(i) = find_volume(note_peaks(i));
            %volume(i) = 100;
        end
        note_length = note_lengths(i);
        timestamp = t(change_indeces(i-1)+1);
        midi_m(i, :) = midimsg("Note", 1, note, volume(i), note_length/Fs, timestamp); %TODO change
    end
end