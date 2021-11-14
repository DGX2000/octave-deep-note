function out = cello_patch(fc, fm_func, t)
  # These parameters were derived from a spectral analysis
  # of a cello and then subjectively tweaked by hand.
  ratios = [0.25; 0.5; linspace(1.0, 11.93, 12)'];
  amplitudes = [0.1, 0.2, 1.0, 0.3, 0.22, 0.08, 0.033, 0.052, ...
                0.023, 0.069, 0.001, 0.004, 0.003, 0.001]';

  voices = fm_sine(ratios * fc, @(x) ratios * fm_func(x), t);
  out = tanh(voices' * amplitudes);
end
