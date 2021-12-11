# MUSIC PARAMETERS
bpm = 60;
bars_part1 = 1.5;
bars_part2 = 2.75;
bars_part3 = 3.75;

# Notes: D1, D2, A2, D3, A3, D4, A4, D5, A5, D6, F#6
chord_notes = [36.708, 73.416, 110, 146.832, 220, 293.665, 440, 587.33, 880, 1174.659, 1479.978];
chord_voices = [2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3];

# AUDIO PARAMETERS
sample_rate = 44100;

fm_amplitude_part_1 = 60.0;
fm_frequencies_part_1 = 0.15;

# DEBUGGING
part1 = 1;
part2 = 1;
part3 = 1;

# ------------------------------------------------------------------------------
# DERIVED PARAMETERS
n_voices = sum(chord_voices);

duration_part1 = (60/bpm) * 4 * bars_part1;
duration_part2 = (60/bpm) * 4 * bars_part2;
duration_part3 = (60/bpm) * 4 * bars_part3;

t1 = linspace(0, duration_part1, sample_rate*duration_part1);
t2 = linspace(0, duration_part2, sample_rate*duration_part2);
t3 = linspace(0, duration_part3, sample_rate*duration_part3);

# ------------------------------------------------------------------------------
# SOUND GENERATION

# PITCH
# Part 1: 30 voices randomly placed between 200 and 400Hz with random 'wobbling'
#         in frequency (the lower the voice, the lesser the wobbling).
tic;
random_frequencies = 200.0 * rand(n_voices, 1) + 200.0;
fm_frequencies = fm_frequencies_part_1 * (random_frequencies / 200.0);
fm_amplitudes = fm_amplitude_part_1 * (random_frequencies / 200.0);

wobble_func = @(x, A, fm) A*sin(2.0*pi*fm*x);

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

# Part 2: 30 voices sweeping to their final positions. To achieve this
#         the frequencies at the end of part 1 are calculated, then sorted in
#         ascending order and every voice is given a target frequency to reach.
tic;
final_frequencies = random_frequencies + fm_amplitudes .* ...
                    sin(2.0*pi*fm_frequencies*duration_part1);
                    
# Analysis of original, slow linear sweep starts in first part
# at about 6 seconds in, turns to fast linear sweep from 12s to 14s,
# then from 14s to 17s there are ~4 "(1-exp)" steps towards target
# each of those 3 steps covers about one third of the total frequency step

chirp_wobble_func = @(x, sf, d2) ...
  (fm_amplitude_part_1*sf/200.0) * exp((log(0.1)/d2)*x) .* ...
  sin(2.0*pi * (fm_frequencies_part_1*sf/200.0) * x);

chirp_func = @(x, tf, sf, d2, c) pi * (tf-sf)/d2 * x.^2 + ...
                                 chirp_wobble_func(x, sf, d2);
                    
# TODO: Decide on the ordering of final frequencies
if part2 == 1
part2_out = zeros(sample_rate*duration_part2, n_voices);
for i=1:max(size(chord_voices))
  for j=1:chord_voices(i)
    current_voice = sum(chord_voices(1:i-1))+j;
    start_frequency = final_frequencies(current_voice);
    target_frequency = chord_notes(i);
    
    part2_out(:,current_voice) = ...
      cello_patch(start_frequency, ...
        @(x) chirp_func(x, target_frequency, start_frequency, duration_part2), t2);
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

# VOLUME CURVE (crescendo, with sweeping between channels in part 1)
part1_stereo = [part1_out, part1_out];
if part1 == 1
  part1_out = part1_out .*  (0.75 ./ (1 + 10.0*exp(-t1)))';
  part1_stereo = part1_out .* [0.6+0.15*sin(2*t1)', 0.6+0.15*cos(2*t1)'];
end

part2_stereo = [part2_out, part2_out];
if part2 == 1
  part2_stereo = part2_stereo .* (0.6 + (0.25/duration_part2) * t2)';
end


part3_stereo = [part3_out, part3_out];


# WRITE TO FILE
audiowrite('output.wav', [part1_stereo; part2_stereo; part3_stereo], sample_rate);