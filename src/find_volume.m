function volume = find_volume(note_peak)
% FIND_VOLUME  Finds MIDI note volume from value of NOTE_PEAK.  <---- H1 line
%   V = FIND_VOLUME(NOTE_PEAK) finds corresponding MIDI note peak from
%   value of NOTE_PEAK
%   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Determine MIDI note velocity (volume) from peak sound pressure  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    volume = floor(127*note_peak/100);
end