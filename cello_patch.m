function out = cello_patch(fc, fm_func, t)
  # These parameters were derived from a spectral analysis
  # of a cello and then subjectively tweaked by hand.
  ratios = [0.5, linspace(1.0, 10.95, 11)]';
  amplitudes = [0.1, logspace(0, -3.25, 11)]';

  voices = fm_sine(ratios * fc, @(x) ratios * fm_func(x), t);
  
  total_amplitude = sum(amplitudes);
  out = (voices' * amplitudes) ./ total_amplitude;
end
