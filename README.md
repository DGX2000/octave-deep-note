# Deep Note Cover (MATLAB)
A cover of the famous "Deep Note" sound trademark by THX, as a MATLAB/Octave script. The script needs to executed to generate the output (*output.wav*) as it is not included in this repository, since I'm not completey sure about the copyright implications.

## Structure of Deep Note

The piece consists of three parts and is, in total, 32 seconds long. It begins with 30 voices randomly placed in the frequency range from 200 to 400Hz. Each voice is frequency modulated, the lower the frequency the weaker the modulation.

After the 6th second the start of the frequency sweep to the final chord can be heard. In the first few seconds (from 6s to 11.5s) the sweep progresses very moderately in a linear manner. After that there is a much steeper linear sweep of about 1.5 seconds, followed by several steps in frequency similar in shape to a logistic function (1/(1+exp(-x))).

Finally, the piece ends with a chord of 12 notes. These notes D1, D2, A2, D3, A3, D4, A4, D5, A5, D6, and F#6; therefore, we have several octaves of D together with its perfect fifth A and only for the highest D, additionally, the major third F#. Each voice is also frequency modulated but substantially less than during the first part.

Each voice is a cello patch, synthesized through summing 12 sines. Their exact amplitudes and frequency ratios (in respect to the fundamental) are (presumably?) unknown.

Dynamically, there is a crescendo in the first few seconds and then again more strongly when the final chord is approache during the second part (frequency sweep). There also is some alternating between the stereo channels in the first part.

## Roadmap

- [X] develop all 3 parts  
- [ ] get rid of audio glitches (mostly due to volume)  
- [ ] add the dynamics (crescendo is missing)  
- [ ] adjust parameters until it sounds about right (exact parameters were random and are unknown)  
