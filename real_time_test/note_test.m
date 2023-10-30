availableDevices = mididevinfo;
device = mididevice(availableDevices.output(2).ID);

fs = 1;
notes = [26 28 28 30 0 30 32 32 0 35 35 0];
buffer = [26 28 28 30 0 30 32 32 0 35 35 0]; % not needed
previousNote = 26;

midi_m = create_midi(notes, fs, buffer, previousNote)
previousNote = notes(end)
midisend(device, midi_m(:,1));