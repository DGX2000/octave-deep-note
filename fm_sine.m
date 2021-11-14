function out = fm_sine(fc, fm_func, t)
  out = sin(2.0*pi*fc*t + fm_func(t));
end