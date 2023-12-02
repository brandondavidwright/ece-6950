<h1>ECE 6950 Final Project</h1>

This project implements a methodology to help amateur musicians create MIDI music. With this MATLAB script, the change in pitch and volume of a digital recording is measured and processed to create a MIDI data stream that can be read in real time by any MIDI software or instrument connected to a personal computer. Using this script, the musician can play a melody on one instrument and play back and record the same melody on the digital recreation of any other instrument. By using this script, creating music with MIDI no longer requires proficiency on a keyboard-based instrument or music notation. The barrier of entry to music creation is dramatically lowered so that anyone who can play—or even hum—a melody can create high quality music that can be played and recorded on any instrument or machine that is MIDI compatible.

This project requires a copies of the MATLAB Audio and Deep Learning Toolbox plugins.  
Additionally, pitch detection requires the download of the training data for the CREPE neural network, which can be found [here](https://www.mathworks.com/help/audio/ref/crepe.html).

<h3>To run this projet:</h3>

1. Unzip the CREPE netowrk weight data in a folder added to your path.

2. Open the folder `src` in MATLAB and execute the script `main.m`

This script will record audio in 10-second intervals and play the clips back in MIDI message format.  The script will continue to loop until manually terminated by the user.

A video of the demo can be found [here](https://youtu.be/u-XBbV21a_4).