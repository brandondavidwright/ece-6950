function midi_m = create_midi(recording, Fs)
    %find fundamental frequency with respect to time
    f0 = pitchnn(recording, Fs);
    
    %adjust length of frequencies to same length as recording
    n1 = numel(f0);
    n2 = length(recording);
    f02 = interp1(1:n1, f0, linspace(1, n1, n2), 'nearest');
    
    %find keyboard notes for frequencies
    notes = freq_to_note(f02);
    
    % detect change in notes
    notes(isnan(notes))=0;    
    pitch_change = diff(notes) ~= 0;

    % find volume
    SPL = splMeter("SampleRate", Fs);
    pressure_levels = SPL(recording);

    % find indeces where note changes
    change_indeces = find(pitch_change);
    change_indeces = [change_indeces length(notes)];

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

    %set sound pressure minimum value to 0
    note_peaks(note_peaks<0) = 0;

    t = 0:1/Fs:length(notes)/Fs;
    
    %find midi notes
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
        midi_m(i, :) = midimsg("Note", 1, note, volume(i), note_length/Fs, timestamp);
    end
end