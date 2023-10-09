clear; close all;
%% Introduction to audio streaming with Audio System Toolbox
% 
% Copyright 2016 The MathWorks, Inc.

%% Audio streaming basics

% Initialize a file reader to produce an input signal
% File = dsp.AudioFileReader('FunkyDrums-44p1-stereo-25secs.mp3');
% Fs = File.SampleRate;
% % Initialize a device writer to play back the output
% Out = audioDeviceWriter('SampleRate', Fs);
% % Initialize a spectrum analyzer to visualize the results over frequency
% Spectrum = dsp.SpectrumAnalyzer('SampleRate',Fs,...
%     'PlotAsTwoSidedSpectrum',false,'FrequencyScale','Log');
% 
% % Filter parameters
% Fc = 1000;
% z = zeros(2);
% 
% tic
% while(toc < 11)
%     % Read from file
%     x = step(File);
% 
%     % Filter input block
%     [y, z] = highPassFilter(Fc, Fs, x, z);
% 
%     % Write to audio device
%     step(Out,y);
% 
%     % Visualize spectrum
%     step(Spectrum,[x(:,1),y(:,1)])
% 
% end
% 
% release(File), release(Out), release(Spectrum)

%% Working with audio I/O
%% Initialization
% Interfacing hardware via software is often a bit of a hassle, so let us
% take a look at how audio I/O objects are used

% >> In = audioDeviceReader
% >> In.D + <Tab>
% >> In.Driver = ' + <Tab>
% >> In.Device = ' + <Tab>

% We are now all set with the initialization
% Assume we connected an input source to my audio input, say a tone
% generator

% %% Acquiring one block at a time
% 
% % Read one block
% x = step(In);
% 
% % Plot it
% plot(x)
% 
% %% Streaming 
% % Streaming is one loop away - simply add a while or for loop around the
% % call to step 
% tic
% while toc < 20
%     % Read one block
%     x = step(In);
% 
%     % Plot it
%     plot(x)
%     drawnow
% end

%% I/O streaming 
% Closing the loop between input and output only requires writing to an
% audio output device at the end of the loop
In = audioDeviceReader %#ok<NOPTS>

filename = "sample.wav";

File = dsp.AudioFileReader('sample.wav');
availableDevices = mididevinfo;
device = mididevice(availableDevices.output(2).ID);
Fs = File.SampleRate;
sampleBuffer = zeros(1);
noteRegister = 0;
previousToc = 0;
tic
while toc < 15
    % Read one block
    x = step(File);
    % note = pitchnn(x, Fs);
    sampleBuffer = cat(1,sampleBuffer,x);
    if toc - previousToc >= 0.07
        f = pitchnn(sampleBuffer, Fs);
        note = max(freq_to_note(f)) % fix this
        if(note ~= noteRegister) 
            midi_messages = midimsg("NoteOn", 1, note, 100, toc);
            midisend(device, midi_messages);
        end        
        previousToc = toc;
        noteRegister = note;
    end
   
    sampleBuffer = 0;
    % *** Your processing code goes HERE: ***
    

    % midi_messages = midimsg("Note", 1, note, volume(i), note_length/fs, timestamp);

    y = x;
    
    % % Write block to output
    % step(Out,y);
   
    % Plot it
    plot(x)
    drawnow
    disp(toc)
end

%% Packaging audio processing algorithms for execution efficiency
%% Back to audio streaming basics

% Initialize a file reader to produce an input signal
% File = dsp.AudioFileReader('FunkyDrums-44p1-stereo-25secs.mp3');
% Fs = File.SampleRate;
% % Initialize a device writer to play back the output
% Out = audioDeviceWriter('SampleRate', Fs);
% % Initialize a spectrum analyzer to visualize the results over frequency
% Spectrum = dsp.SpectrumAnalyzer('SampleRate', Fs,...
%     'PlotAsTwoSidedSpectrum',false,'FrequencyScale','Log');
% 
% % Filter parameters
% Fc = 1000;
% z = zeros(2);
% 
% tic
% while(toc < 11)
%     % Read from file
%     x = step(File);
% 
%     % Filter input block
%     [y, z] = highPassFilter(Fc, Fs, x, z);
% 
%     % Write to audio device
%     step(Out,y);
% 
%     % Visualize spectrum
%     step(Spectrum,[x(:,1),y(:,1)])
% 
% end
% 
% release(File), release(Out), release(Spectrum)

%% Review code for custom high-pass filter

% edit highPassFilter.m

% Notes -
% On efficiency:
% * Coefficients need computing every time the function is called
% On usability:
% * States need understanding and maintaining outside of the function
% * Unclear what are inputs/outputs and what algorithm parameters

%% A new version of the same algorithm

% edit HighPass.m

% Note -
% On efficiency:
% * Coefficients are precomputed and remembered, and only updated
%   when the cutoff frequency is changed by the user
% On usability:
% * States are attached to the algorithm - remembered and managed
%   internally
% * How the algorithm works with input and outputs is clearly visible from
%   the process function
% * Parameters exposed to the user are clearly identifiable as public
%   properties

%% Live-tuning a modular algorithm

% Initialize a file reader to produce an input signal
% File = dsp.AudioFileReader('FunkyDrums-48-stereo-25secs.mp3');
% % Initialize a device writer to play back the output
% Out = audioDeviceWriter('SampleRate', 48000);
% 
% % Create a high pass filter
% Filter = HighPass();
% 
% % Add interactive tunability
% % ...via MIDI, e.g. (change DeviceName and Control ID, here 1023)
% % configureMIDI(Filter,'Fc',1023,'DeviceName','nanoKONTROL2')
% % ...or UI
% w = tuneSingleParameterWithUI(Filter, 'CrossoverFrequencies', 20, 2000);
% pause(2)
% 
% tic
% while(toc < 15) && ishandle(w)
%     % Read from file
%     x = step(File);
% 
%     % Filter input block
%     y = process(Filter,x);
% 
%     % Write to audio device
%     step(Out,y);
%     drawnow
% end
% 
% release(File), release(Out)
% 
% %% Automating streaming and live tuning with Audio Test Bench
% % Once the algorithm  encapsulates all the info, all can be automated
% 
% Filter = HighPass();
% 
% audioTestBench(Filter);
% Use, e.g.: <matlabroot>\toolbox\audio\samples\FunkyDrums-44p1-stereo-25secs.mp3
