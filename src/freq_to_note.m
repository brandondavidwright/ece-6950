function note = freq_to_note(f)
% FREQ_TO_NOTE  Finds nearest musical note to frequency F.  <---- H1 line
%   N = FREQ_TO_NOTEE(F) finds nearest musical note from frequency F using
%   A440 12-tone equal temperament (12-TET) tuning
%   value of NOTE_PEAK
%   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Determine nearest 12-TET musical note %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    note = floor(12*log2(f./440) + 69);
end