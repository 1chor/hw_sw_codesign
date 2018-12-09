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

  ir_length = ceil(length(ir_signal)/(fft_length/2))*(fft_length/2);
  input_length = ceil(length(input_signal)/(fft_length/2))*(fft_length/2);

  ir_signal = [ir_signal;zeros(ir_length-length(ir_signal),2)];
  input_signal = [input_signal;zeros(input_length-length(input_signal),2)];

  sprintf("File lengths after zero-extension [# stero samples]:")
  sprintf("  input file: %d", length(input_signal))
  sprintf("  ir file: %d", length(ir_signal))


  % To perform the convolution using the overlap-add method we chop up the input
  % signal and the impulse response into chunks of length block_length 
  fft_length
  
  %block_length = fft_length/2
  block_length = header_length
  
  num_input_blocks = length(input_signal)/block_length
  num_ir_blocks = length(ir_signal)/block_length
  
  output_buffer_fir_1 = zeros(length(input_signal),1);
  output_buffer_fir_2 = zeros(length(input_signal),1);
  
  output_buffer_fft_1 = zeros(length(input_signal)+1*block_length,1);
  output_buffer_fft_2 = zeros(length(input_signal)+1*block_length,1);
  
  % initialize output signal and make it one block longer than the input signal
  % this is avoids an buffer overflow for the last block
  
  output_signal = zeros(length(input_signal)+1*block_length,2);
  
  output_buffer_header_1 = zeros(header_length,1);
  output_buffer_header_2 = zeros(header_length,1);
  
  output_buffer_body_1 = zeros(body_length,1);
  output_buffer_body_2 = zeros(body_length,1);
  
  input_buffer_fir_1 = zeros(N_length,1);
  input_buffer_fir_2 = zeros(N_length,1);
  
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
  
  %Buffer for header FDL
  %input_buffer_header_1 = buffer(input_signal(s+1,1),header_length);
  %input_buffer_header_2 = buffer(input_signal(s+1,2),header_length);
 
  %Buffer for body FDL
  %input_buffer_body_1 = buffer(input_signal(s+1,1),body_length);
  %input_buffer_body_2 = buffer(input_signal(s+1,2),body_length);
  
  if ( use_custom_fft == true )
    
    input_buffer_fft_1 = zeros(block_length,1);
    input_buffer_fft_2 = zeros(block_length,1);
    
    cnt_header = 0;
    
    for s=0:input_length-1
      
      input_buffer_fft_1(1:block_length-1) = input_buffer_fft_1(2:block_length);
      input_buffer_fft_1(block_length) = input_signal(s+1,1);
      
      input_buffer_fft_2(1:block_length-1) = input_buffer_fft_2(2:block_length);
      input_buffer_fft_2(block_length) = input_signal(s+1,2);
      
      if ( ( mod(s,block_length-1) == 0 ) && ( s > 0 ) )
        
        output_buffer_1 = zeros(2 * block_length,1);
        output_buffer_2 = zeros(2 * block_length,1);
        
        for j=2:num_ir_blocks-1
            
            % load the required blocks and zero-extend them to fft_length
            % rememer that the length of the result of a convolution is 
            % given by the addition of the lengths of the inputs signals 
            
            input_block_1 = [input_buffer_fft_1;zeros(block_length,1)];
            ir_block_1 = [ir_signal(1+j*block_length:(j+1)*block_length,1);zeros(block_length,1)];
            
            %disp(input_block_1);
            %return;
            
            output_buffer_1 = output_buffer_1 + fft(input_block_1) .* fft(ir_block_1);
            
            input_block_2 = [input_buffer_fft_2;zeros(block_length,1)];
            ir_block_2 = [ir_signal(1+j*block_length:(j+1)*block_length,2);zeros(block_length,1)];
            
            output_buffer_2 = output_buffer_2 + fft(input_block_2) .* fft(ir_block_2);
        end
        
        output_buffer_1 = real(ifft(output_buffer_1));
        output_buffer_fft_1(1+cnt_header*block_length:(cnt_header+2)*block_length,1) = output_buffer_fft_1(1+cnt_header*block_length:(cnt_header+2)*block_length,1) + output_buffer_1;
        
        output_buffer_2 = real(ifft(output_buffer_2));
        output_buffer_fft_2(1+cnt_header*block_length:(cnt_header+2)*block_length,1) = output_buffer_fft_2(1+cnt_header*block_length:(cnt_header+2)*block_length,1) + output_buffer_2;
        
        cnt_header = cnt_header + 1;
        
      end
      
    end
    
  else
    
    for i=0:num_input_blocks-1
        
        % ------------------------------------------------------------------------
        % left channel
        % ------------------------------------------------------------------------
        
        output_buffer_1 = zeros(2 * block_length,1);
        output_buffer_2 = zeros(2 * block_length,1);
        
        for j=2:num_ir_blocks-1
            
            input_block_index = i-j;
            
            %at the beginning of the file there is no history yet --> exit loop
            
            if(input_block_index < 0)
              break;
            end
            
            % load the required blocks and zero-extend them to fft_length
            % rememer that the length of the result of a convolution is 
            % given by the addition of the lengths of the inputs signals 
            
            input_block_1 = [input_signal(1+input_block_index*block_length:(input_block_index+1)*block_length,1);zeros(block_length,1)];
            ir_block_1 = [ir_signal(1+j*block_length:(j+1)*block_length,1);zeros(block_length,1)];
            
            %disp(input_block_1);
            %return;
            
            output_buffer_1 = output_buffer_1 + fft(input_block_1) .* fft(ir_block_1);
            
            input_block_2 = [input_signal(1+input_block_index*block_length:(input_block_index+1)*block_length,2);zeros(block_length,1)];
            ir_block_2 = [ir_signal(1+j*block_length:(j+1)*block_length,2);zeros(block_length,1)];
            
            output_buffer_2 = output_buffer_2 + fft(input_block_2) .* fft(ir_block_2);
        end
        
        output_buffer_1 = real(ifft(output_buffer_1));
        output_buffer_fft_1(1+i*block_length:(i+2)*block_length,1) = output_buffer_fft_1(1+i*block_length:(i+2)*block_length,1) + output_buffer_1;
        
        output_buffer_2 = real(ifft(output_buffer_2));
        output_buffer_fft_2(1+i*block_length:(i+2)*block_length,1) = output_buffer_fft_2(1+i*block_length:(i+2)*block_length,1) + output_buffer_2;
        
    end
    
  end
  
  % hier wird das output signal gebastelt
  
  output_signal(1:length(input_signal),1) = fir_1;
  output_signal(1:length(input_signal),2) = fir_2;
  
  output_signal(:,1) = output_signal(:,1) + output_buffer_fft_1;
  output_signal(:,2) = output_signal(:,2) + output_buffer_fft_2;
  
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

syms N B; %Creates symbolic variable
syms k T;
%k = 1.5; %Proportionality constant
%T = ir_length; %Length of filter impulse response
f_s = 48000; %Samplefrequenz
f_fpga = 100000000; %Clockfrequenz vom FPGA
cycle = f_fpga / f_s; %Zeit fuer direkt FFT

sprintf("Cost of Single-FDL Convolution")
O_SFDL = 4*k*log2(2*N) + 4*T/N; %Cost of Single-FDL Convolution
N_opt = solve(diff(O_SFDL,N)==0,N) %Optimal value for Single-FDL Convolution

sprintf("Cost of Double-FDL Convolution")
O_DoubleFDL = 4*k*log2(2*N) + 4*B/N + 4*k*log2(2*B) + 4*(T/B-1); %Cost of Double-FDL Convolution
B_opt = solve(diff(O_DoubleFDL,B)==0,B) %Optimal value for Double-FDL Convolution

