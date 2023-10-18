function note = freq_to_note(f)
    if isnan(f)
        note = 0;
    else
        note = floor(12*log2(f./440) + 49);
        note(note<20) = 0;
    end
end