clear all; close all;

% function save_midi_file(midi_msg)
    identifier =  '0x4d546864';
    chunklen = '0x00000006';
    format = '0x0001';
    ntracks = '0x0001';
    tickdiv = '0x0060'; %hardcoded to 96 ppqn.  Calculate this maybe?
    header = hexToBinaryVector([identifier, chunklen, format, ntracks, tickdiv])
% end