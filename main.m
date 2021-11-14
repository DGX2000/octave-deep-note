# MUSIC PARAMETERS
bpm = 60;
bars_part1 = 2.5;
bars_part2 = 1.5;
bars_part3 = 4.0;

# Notes: D1, D2, A2, D3, A3, D4, A4, D5, A5, D6, F#6
chord_notes = [36.708, 73.416, 110, 146.832, 220, 293.665, 440, 587.33, 880, 1174.659, 1479.978];
chord_voices = [2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3];

# AUDIO PARAMETERS
sample_rate = 44100;

# ------------------------------------------------------------------------------
# DERIVED PARAMETERS
n_voices = sum(chord_voices);

duration_part1 = (60/bpm) * 4 * bars_part1;
duration_part2 = (60/bpm) * 4 * bars_part2;
duration_part3 = (60/bpm) * 4 * bars_part3;

t1 = linspace(0, duration_part1, sample_rate*duration_part1);
t2 = linspace(0, duration_part2, sample_rate*duration_part2);
t3 = linspace(0, duration_part3, sample_rate*duration_part3);

# FREQUENCY-MODULATION FUNCTIONS
wobble_func = @(x, A, fm) A*sin(2.0*pi*fm*x);
chirp_func = @(x, c) 2.0*pi * c * x.^2;

# ------------------------------------------------------------------------------
# SOUND GENERATION

# PITCH
# Part 1: 30 voices randomly placed between 200 and 400Hz with random 'wobbling'
#         in frequency (the lower the voice, the lesser the wobbling).
part1_out = cello_patch(220.0, ...
                        @(x) wobble_func(x, 10.0, 0.5), t1);

# Part 2: 30 voices sweeping linearly to their final positions. To achieve this
#         the frequencies at the end of part 1 are calculated, then sorted in
#         ascending order and every voice is given a target frequency to reach.
part2_out = cello_patch(220.0, ...
                        @(x) chirp_func(x, (440.0-220.0)/duration_part2), t2);

# Part 3: 
part3_out = [];
for i=1:max(size(chord_voices))
  note_sound = [];
  for j=1:chord_voices(i)
    note_sound(:,j) = (1.0/n_voices) * ...
                      cello_patch(chord_notes(i), ...
                                  @(x) wobble_func(x, 10.0*rand(), rand()), ...
                                  t3);
  end
  out(:,i) = tanh(sum(note_sound, 2));
end
part3_out = tanh(sum(out, 2));

# VOLUME
# Part 1: Apply a general volume curve over the mono audio.

# Part 2: Clone the mono audio and add a back-and-forth between channels
#         during the beginning with the 30 random voices. This back-and-forth
#         slowly diminishes towards the sweeping part.

# WRITE TO FILE
audiowrite('output.wav', [part1_out; part2_out; part3_out], sample_rate);
