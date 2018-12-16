%!/bin/octave

%function reverb_reference(infile, outfile, impluseresponsefile)
  %load input signals 
  
  %infile = './../sample_files/input.wav';
  %outfile = './../sample_files/output.wav';
  
  infile = './../sample_files/ir_cave.wav';
  outfile = './../sample_files/output_cave.wav';
  
  impluseresponsefile = './../sample_files/ir_short.wav';
  rightfile = './../sample_files/output_richtig.wav';
  
  use_custom_fir = false;
%  use_custom_fir = true;

%  use_custom_fft = false;
  use_custom_fft = true;
  
  [ir_signal, ir_sampleRate] = audioread(impluseresponsefile);
  [input_signal, input_sampleRate] = audioread(infile);

  % ir_signal and input_singal are vectors of stero values, i.e. a matrix with two
  % columns and length(*_signal) rows

  % To get the Nth stero sample use:
  % >> input_signal(1,:)

  % To get all samples of one channel use (where x is either 1 or 2)
  % >> input_signal(:,x)

  % Note that in Matlab/Octave the first index in an array has index ONE!

  fft_length = pow2(13); % returns th Nth power of two
  
  N_length = 512; % Length for direct Fir
  fir_length = N_length;
  header_length = 256; % Length of Header FDL Blocks
  body_length = 4096; % Length of Body FDL Blocks
  
  % for easier processing, make sure that the input signal as well as the imuplse
  % response signal have a length which is a mulitple of fft_length/2 ()

  sprintf("Original file lengths [# stero samples]:")
  sprintf("  input file: %d", length(input_signal))
  sprintf("  ir file: %d", length(ir_signal))
  
  % keine ahnung warum das ceil shit hier ist.
  % hab den direkten wert danach eingetragen.
  
  % wenn ich hier die genauen werte verwende, dann wird es ungenauer.
  % habe dann nur mehr 0.99999999999999.
  
  % vll loest sich das prbolem wenn ich ueberall die bloecke verwende
  
  % wenn ich das zero extended nehme geht es sich schoen
  
  ir_length = ceil(length(ir_signal)/(fft_length/2))*(fft_length/2);
  input_length = ceil(length(input_signal)/(fft_length/2))*(fft_length/2);
  
  %ir_length = 96000;
  %input_length = 174250;

  ir_signal = [ir_signal;zeros(ir_length-length(ir_signal),2)];
  input_signal = [input_signal;zeros(input_length-length(input_signal),2)];

  sprintf("File lengths after zero-extension [# stero samples]:")
  sprintf("  input file: %d", length(input_signal))
  sprintf("  ir file: %d", length(ir_signal))
  
  ir_header_signal_1 = zeros(length(ir_signal)-512, 1);
  ir_header_signal_1 = ir_signal( 513:length(ir_signal), 1 );
  
  ir_header_signal_2 = zeros(length(ir_signal)-512, 1);
  ir_header_signal_2 = ir_signal( 513:length(ir_signal), 2 );

  % To perform the convolution using the overlap-add method we chop up the input
  % signal and the impulse response into chunks of length block_length 
  fft_length
  
  %block_length = fft_length/2
  block_length = header_length
  
  num_input_blocks = length(input_signal)/block_length
  num_ir_blocks = length(ir_signal)/block_length
  
  num_ir_header_blocks = num_ir_blocks - 2;
  num_in_header_blocks = length(input_signal)/header_length
  
  output_buffer_fir_1 = zeros(length(input_signal),1);
  output_buffer_fir_2 = zeros(length(input_signal),1);
  
  output_buffer_fft_1 = zeros(length(input_signal)+3*block_length,1);
  output_buffer_fft_2 = zeros(length(input_signal)+3*block_length,1);
  
  % initialize output signal and make it one block longer than the input signal
  % this is avoids an buffer overflow for the last block
  
  output_signal = zeros(length(input_signal)+1*block_length,2);
  
  output_buffer_header_1 = zeros(header_length,1);
  output_buffer_header_2 = zeros(header_length,1);
  
  output_buffer_body_1 = zeros(body_length,1);
  output_buffer_body_2 = zeros(body_length,1);
  
  input_buffer_fir_1 = zeros(N_length,1);
  input_buffer_fir_2 = zeros(N_length,1);
  
  %input_buffer_fft_1_history = zeros( header_length, num_input_blocks );
  %input_buffer_fft_2_history = zeros( header_length, num_input_blocks );
  
  input_buffer_fft_1_history = zeros( header_length, num_ir_blocks );
  input_buffer_fft_2_history = zeros( header_length, num_ir_blocks );
  
  % ----------------------------------------------------------------------------
  % FIR
  % ----------------------------------------------------------------------------
  
  if ( use_custom_fir == true )
    
    cnt = 0;
    
    for s=0:input_length-1
      
      %Buffer for fir filter
      
      input_buffer_fir_1(2:fir_length) = input_buffer_fir_1(1:fir_length-1);
      input_buffer_fir_1(1) = input_signal(s+1,1);
      
      input_buffer_fir_2(2:fir_length) = input_buffer_fir_2(1:fir_length-1);
      input_buffer_fir_2(1) = input_signal(s+1,2);
      
      % das sollte eingeltich nicht als block gemacht werden, aber sonst ist
      % es zu langsam
      
      if ( ( mod(s,fir_length) == 0 ) && ( s > 0 ) )
        
        fir_1 = filter(ir_signal(1:fir_length,1),1,input_buffer_fir_1);
        fir_2 = filter(ir_signal(1:fir_length,2),1,input_buffer_fir_2);
        
        output_buffer_fir_1( (cnt*fir_length) + 1 : ((cnt+1) * fir_length ) ) = fir_1;
        output_buffer_fir_2( (cnt*fir_length) + 1 : ((cnt+1) * fir_length ) ) = fir_2;
        
        cnt = cnt + 1;
        
      end
      
    end
    
    fir_1 = output_buffer_fir_1;
    fir_2 = output_buffer_fir_2;
    
  else
    
    % der fir filter wird auf das ganze input signal angewendet, aber nur
    % mit einem begrenzten ir teil.
    
    fir_1 = filter(ir_signal(1:fir_length,1),1,input_signal(:,1));
    fir_2 = filter(ir_signal(1:fir_length,2),1,input_signal(:,2));
    
  end
  
  % ----------------------------------------------------------------------------
  % FFT
  % ----------------------------------------------------------------------------
  
  if ( use_custom_fft == true )
    
    % ----------------------------------------------------------------------------
    % HEADER
    % ----------------------------------------------------------------------------
    
    h_header_1 = zeros(header_length, num_ir_header_blocks);
    h_header_2 = zeros(header_length, num_ir_header_blocks);
    
    h_header_index = 0;
    
    for i=0:num_ir_header_blocks-1
      
      h_header_1( :,h_header_index+1 ) = ir_header_signal_1(1+i*header_length:(i+1)*header_length,1);
      h_header_2( :,h_header_index+1 ) = ir_header_signal_2(1+i*header_length:(i+1)*header_length,1);
      
      h_header_index = h_header_index + 1;
      
    end
    
    i_header_1 = zeros(header_length, num_input_blocks);
    i_header_2 = zeros(header_length, num_input_blocks);
    
    i = 0;
    
    i_header_1_buffer = zeros(header_length, 1);
    i_header_2_buffer = zeros(header_length, 1);
    
    for s=0:input_length-1
      
      i_header_1_buffer(1:header_length-1) = i_header_1_buffer(2:header_length);
      i_header_1_buffer(header_length) = input_signal(s+1,1);
      
      i_header_2_buffer(1:header_length-1) = i_header_2_buffer(2:header_length);
      i_header_2_buffer(header_length) = input_signal(s+1,2);
      
      if ( s > 0 )
        if ( s == (header_length*(i+1)-1) )
          i_header_1( :,i+1 ) = i_header_1_buffer(1:header_length);
          i_header_2( :,i+1 ) = i_header_2_buffer(1:header_length);
          
          i = i + 1;
        end
      end
      
    end
    
    for i=0:num_in_header_blocks-1
      
      output_buffer_1 = zeros(2 * header_length,1);
      output_buffer_2 = zeros(2 * header_length,1);
      
      for j=0:num_ir_header_blocks-1
        
        input_block_index = i-j;
        
        %at the beginning of the file there is no history yet --> exit loop
        
        if(input_block_index < 0)
          break;
        end
        
        % load the required blocks and zero-extend them to fft_length
        % rememer that the length of the result of a convolution is
        % given by the addition of the lengths of the inputs signals
        
        in_block_1 = [i_header_1(:,input_block_index+1);zeros(header_length,1)];
        ir_block_1 = [h_header_1(:,j+1);zeros(header_length,1)];
        
        output_buffer_1 = output_buffer_1 + fft(in_block_1) .* fft(ir_block_1);
        
        in_block_2 = [i_header_2(:,input_block_index+1);zeros(header_length,1)];
        ir_block_2 = [h_header_2(:,j+1);zeros(header_length,1)];
        
        output_buffer_2 = output_buffer_2 + fft(in_block_2) .* fft(ir_block_2);
      end
      
      output_buffer_1 = real(ifft(output_buffer_1));
      output_buffer_fft_1(1+i*header_length:(i+2)*header_length,1) += output_buffer_1;
      
      output_buffer_2 = real(ifft(output_buffer_2));
      output_buffer_fft_2(1+i*header_length:(i+2)*header_length,1) += output_buffer_2;
      
    end
    
    % ----------------------------------------------------------------------------
    % BODY
    % ----------------------------------------------------------------------------
    
  else
    
    % als erstes werde ich das ir signal in die bloecke aufteilen
    % damit ich leichter daruaf zugreifen kann
    
    % num_ir_blocks ist 375 wenn ich die laenge des ir signals auf
    % 96.000 festlege. wenn das zero extended wird, dann ist es groesser.
    
    h_header_1 = zeros(block_length, num_ir_blocks-2);
    h_header_2 = zeros(block_length, num_ir_blocks-2);
    
    % der erste block wird richtig gespeichert.  i==0. beginnt mit  3.0518e-05
    % der zweite block wird richtig gespeichert. i==1. beginnt mit -9.1553e-05
    % der dritte block wird richtig gespeichert. i==2. beginnt mit  0.00006
    % der block bei i == 373 wird richtig gespeichert
    % der block bei i == 374 wird richtig gespeichert
    % bei i == 375 kommt nichts mehr
    
    % DER ERSTE BLOCK IST BEI INDEX 1 GESPEICHERT.
    
    % we start with 0.
    % therefore the each index in the loop has to be incremented by 1.
    % if the loop did not start with 0, it would not be possible to select
    % the data starting with range 1.
    
    % hier brauchen wir einen zweiten index.
    % h_header_index wird dazu verwendet um den richtigen block auszuwaehlen
    % i um den bereich in dem ir signal auszuwaehlen.
    % z.b. header(1) = ir_signal(513:...)
    
    h_header_index = 0;
    
    for i=2:num_ir_blocks-1
      
      h_header_1( :,h_header_index+1 ) = ir_signal(1+i*block_length:(i+1)*block_length,1);
      h_header_2( :,h_header_index+1 ) = ir_signal(1+i*block_length:(i+1)*block_length,2);
      
      h_header_index = h_header_index + 1;
      
    end
    
    % i == 0 passt -> 0.00000, -0.00015
    % i == 1 passt -> -3.6163e-02, -6.5094e-02
    % i == 2 passt -> -0.4235535, -0.4453125
    % i == num-1 passt -> 0, 0 -> ist ja von dem zero extended
    
    i_header_1 = zeros(block_length, num_input_blocks);
    i_header_2 = zeros(block_length, num_input_blocks);
    
    i = 0;
    
    i_header_1_buffer = zeros(block_length, 1);
    i_header_2_buffer = zeros(block_length, 1);
    
    for s=0:input_length-1
      
      i_header_1_buffer(1:block_length-1) = i_header_1_buffer(2:block_length);
      i_header_1_buffer(block_length) = input_signal(s+1,1);
      
      i_header_2_buffer(1:block_length-1) = i_header_2_buffer(2:block_length);
      i_header_2_buffer(block_length) = input_signal(s+1,2);
      
      % diese mod operation funktioniert nicht
      %if ( ( mod(s, block_length-1) == 0 ) && ( s > 0 ) )
      
      if ( s > 0 )
        if ( s == (block_length*(i+1)-1) )
          i_header_1( :,i+1 ) = i_header_1_buffer(1:block_length);
          i_header_2( :,i+1 ) = i_header_2_buffer(1:block_length);
          
          i = i + 1;
        end
      end
      
    end
    
    % bei den schleifen nehme ich scheinbar immer normale indices an und
    % muss dann bei den array zugriffen 1 dazu addieren.
    
    for i=0:num_input_blocks-1
      
      output_buffer_1 = zeros(2 * block_length,1);
      output_buffer_2 = zeros(2 * block_length,1);
      
      for j=0:num_ir_header_blocks-1
        
        input_block_index = i-j;
        
        %at the beginning of the file there is no history yet --> exit loop
        
        if(input_block_index < 0)
          break;
        end
        
        % load the required blocks and zero-extend them to fft_length
        % rememer that the length of the result of a convolution is
        % given by the addition of the lengths of the inputs signals
        
        in_block_1 = [i_header_1(:,input_block_index+1);zeros(block_length,1)];
        ir_block_1 = [h_header_1(:,j+1);zeros(block_length,1)];
        
        output_buffer_1 = output_buffer_1 + fft(in_block_1) .* fft(ir_block_1);
        
        in_block_2 = [i_header_2(:,input_block_index+1);zeros(block_length,1)];
        ir_block_2 = [h_header_2(:,j+1);zeros(block_length,1)];
        
        output_buffer_2 = output_buffer_2 + fft(in_block_2) .* fft(ir_block_2);
      end
      
      output_buffer_1 = real(ifft(output_buffer_1));
      output_buffer_fft_1(1+i*block_length:(i+2)*block_length,1) += output_buffer_1;
      
      output_buffer_2 = real(ifft(output_buffer_2));
      output_buffer_fft_2(1+i*block_length:(i+2)*block_length,1) += output_buffer_2;
      
    end
    
  end
  
  % hier wird das output signal gebastelt
  
%  disp(output_buffer_fft_1(  (length(output_signal)-(block_length*3)) :  (length(output_signal)-(block_length*2))  ) );
%  return;
  
  output_signal(1:length(input_signal),1) = fir_1;
  output_signal(1:length(input_signal),2) = fir_2;
  
  % das fft muss verschoben auf das output signal addiert werden
  % da die fft ja erst ab dem 2. block beginnt.
  
  output_signal((header_length*2+1):length(output_signal),1) += output_buffer_fft_1( 1 : ( length(output_signal) - (header_length*2) ) );
  output_signal((header_length*2+1):length(output_signal),2) += output_buffer_fft_2( 1 : ( length(output_signal) - (header_length*2) ) );
  
  % crop the size of the output_signal to that of the input signal 
  output_signal = output_signal(1:length(input_signal),:);

  %scale by maximum value --> i.e. normalize to 1
  output_signal(:,1) = output_signal(:,1) ./ max(output_signal(:,1));
  output_signal(:,2) = output_signal(:,2) ./ max(output_signal(:,2));

  %scale by fixed value
  %scale = 16
  %output_signal(:,1) ./= scale;
  %output_signal(:,2) ./= scale;

  audiowrite(outfile, output_signal, input_sampleRate,'BitsPerSample',16);

%end

%% Cost Analysis

%syms N B; %Creates symbolic variable
%syms k T;
%k = 1.5; %Proportionality constant
%T = ir_length; %Length of filter impulse response
%f_s = 48000; %Samplefrequenz
%f_fpga = 100000000; %Clockfrequenz vom FPGA
%cycle = f_fpga / f_s; %Zeit fuer direkt FFT

%sprintf("Cost of Single-FDL Convolution")
%O_SFDL = 4*k*log2(2*N) + 4*T/N; %Cost of Single-FDL Convolution
%N_opt = solve(diff(O_SFDL,N)==0,N) %Optimal value for Single-FDL Convolution

%sprintf("Cost of Double-FDL Convolution")
%O_DoubleFDL = 4*k*log2(2*N) + 4*B/N + 4*k*log2(2*B) + 4*(T/B-1); %Cost of Double-FDL Convolution
%B_opt = solve(diff(O_DoubleFDL,B)==0,B) %Optimal value for Double-FDL Convolution

