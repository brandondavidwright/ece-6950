channel = 1;
note = 60;
velocity = 64;
msg = midimsg("NoteOn", channel, note, velocity);
frequency = 440 * 2^((msg.Note-69)/12);
amplitude = msg(1).Velocity/127;
msgs=  [midimsg("Note", channel, 60, 64, 0.5, 0), ...
        midimsg("Note", channel, 62, 64, 0.5, .75), ...
        midimsg('Note',channel,57,40,0.5,1.5), ...
        midimsg('Note',channel,60,50,1,3)];
eventTimes = [msgs.Timestamp];

osc = audioOscillator('Frequency',frequency,'Amplitude',amplitude);
deviceWriter = audioDeviceWriter('SampleRate',osc.SampleRate);

bend1 = [midimsg("NoteOn", channel, 60, 127, 0),...
    midimsg("PitchBend", channel, 10000, .5), ...
    midimsg("PitchBend", channel, 0, 1), ...
    midimsg("NoteOff", channel, 60, 127, 2)];  



% i = 1;
% tic
% while toc < max(eventTimes)
%     if toc > eventTimes(i)
%         msg = msgs(i);
%         i = i+1;
% 
%         if msg.Velocity~= 0
%             osc.Frequency = 440 * 2^((msg.Note-69)/12);
%             osc.Amplitude = msg.Velocity/127;
%         else
%             osc.Amplitude = 0; 
%         end
%     end
%     deviceWriter(osc());
% end
% release(deviceWriter)

availableDevices = mididevinfo;
device = mididevice(availableDevices.output(2).ID);
midisend(device, msgs);
% 
% midisend(device, bend1);
