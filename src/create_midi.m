function midi_m = create_midi(recording, Fs)
% CREATE_MIDI  Creates MIDI messages from audio recording.  <---- H1 line
%   M = CREATE_MIDI(RECORDING, FS) creates MIDI messages from RECORDING for
%   sampling frequency FS
%   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Determine fundamental frequencies of recording                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    f0 = pitchnn(recording, Fs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Adjust frequency array to be same length as recording           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n1 = numel(f0);
    n2 = length(recording);
    f02 = interp1(1:n1, f0, linspace(1, n1, n2), 'nearest');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Find musical notes from frequencies                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    notes = freq_to_note(f02);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Detect indices where musical notes change                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    notes(isnan(notes))=0;    
    pitch_change = diff(notes) ~= 0;
    change_indices = find(pitch_change);
    change_indices = [change_indices length(notes)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Find volumes of recording                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SPL = splMeter("SampleRate", Fs);
    pressure_levels = SPL(recording);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Find peak volume, note length, and musical notes                %
%   in between note changes                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Remove negative sound pressures                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    note_peaks(note_peaks<0) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Create time array for timestamps                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    t = 0:1/Fs:length(notes)/Fs;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Create MIDI messages                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        midi_m(i, :) = midimsg("Note", 1, note, volume(i), note_length/Fs, timestamp);
    end
end