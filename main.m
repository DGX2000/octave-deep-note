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

fm_amplitude_part_1 = 60.0;
fm_frequencies_part_1 = 0.15;

# DEBUGGING
part1 = 1;
part2 = 0;
part3 = 0;

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
chirp_func = @(x, c) pi * c * x.^2;

# ------------------------------------------------------------------------------
# SOUND GENERATION

# PITCH
# Part 1: 30 voices randomly placed between 200 and 400Hz with random 'wobbling'
#         in frequency (the lower the voice, the lesser the wobbling).
tic;
random_frequencies = 200.0 * rand(n_voices, 1) + 200.0;
fm_frequencies = fm_frequencies_part_1 * (random_frequencies / 200.0);
fm_amplitudes = fm_amplitude_part_1 * (random_frequencies / 200.0);

if part1 == 1
part1_out = zeros(sample_rate*duration_part1, n_voices);
for i = 1:n_voices
  part1_out(:,i) = cello_patch(random_frequencies(i), ...
                     @(x) wobble_func(x, fm_amplitudes(i), fm_frequencies(i)), t1);
end
part1_out = sum(part1_out, 2) ./ n_voices;
else
  part1_out = [];
end

timer = toc;
fprintf("Part 1 took %d seconds.\n", timer);

# Part 2: 30 voices sweeping linearly to their final positions. To achieve this
#         the frequencies at the end of part 1 are calculated, then sorted in
#         ascending order and every voice is given a target frequency to reach.
tic;
final_frequencies = random_frequencies + fm_amplitudes .* ...
                    sin(2.0*pi*fm_frequencies*duration_part1);

# TODO: Decide on the ordering of final frequencies
if part2 == 1
part2_out = zeros(sample_rate*duration_part2, n_voices);
for i=1:max(size(chord_voices))
  for j=1:chord_voices(i)
    start_frequency = final_frequencies(sum(chord_voices(1:i-1))+j);
    target_frequency = chord_notes(i);
    
    part2_out(:,j) = cello_patch(start_frequency, ...
        @(x) chirp_func(x, (target_frequency-start_frequency)/duration_part2), t2);
  end
end
part2_out = sum(part2_out, 2) ./ n_voices;
else
  part2_out = [];
end

timer = toc;
fprintf("Part 2 took %d seconds.\n", timer);
                        
                        
# Part 3: 
tic;

if part3 == 1
part3_out = zeros(sample_rate*duration_part3, max(size(chord_voices)));
for i=1:max(size(chord_voices))
  note_sound = zeros(sample_rate*duration_part3, chord_voices(i));
  for j=1:chord_voices(i)
    note_sound(:,j) = cello_patch(chord_notes(i), ...
                                  @(x) wobble_func(x, 10.0*rand(), rand()), ...
                                  t3);
  end
  part3_out(:,i) = sum(note_sound, 2);
end
part3_out = sum(part3_out, 2) ./ n_voices;
else
  part3_out = [];
end

timer = toc;
fprintf("Part 3 took %d seconds.\n", timer);

# VOLUME
# Part 1: Apply a general volume curve over the mono audio.

# Part 2: Clone the mono audio and add a back-and-forth between channels
#         during the beginning with the 30 random voices. This back-and-forth
#         slowly diminishes towards the sweeping part.

# WRITE TO FILE
audiowrite('output.wav', [part1_out; part2_out; part3_out], sample_rate);
