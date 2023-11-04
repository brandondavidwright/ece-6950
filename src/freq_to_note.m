function note = freq_to_note(f)
    note = floor(12*log2(f./440) + 49);
end