%!/bin/octave

  %load input signals 
  
  impluseresponsefile = './../sample_files/ir_short.wav';
    
  % ----------------------------------------------------------------------------
  % READ FILES
  % ----------------------------------------------------------------------------
  
  [ir_signal, ir_sampleRate] = audioread(impluseresponsefile);
  
  %in = [ 0 1 2 3 4 5 6 7 8 9 ]
  f = fft( ir_signal );