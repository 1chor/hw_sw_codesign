%!/bin/octave
%function reverb_reference(infile, outfile, impluseresponsefile)
	%load input signals 
    infile = '.\..\sample_files\input.wav';
    outfile = '.\..\sample_files\output.wav';
    impluseresponsefile = '.\..\sample_files\ir_short.wav';
    rightfile = '.\..\sample_files\output_richtig.wav';
    
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
	block_length = fft_length/2
	num_input_blocks = length(input_signal)/block_length
	num_ir_blocks = length(ir_signal)/block_length

	% initialize output signal and make it one block longer than the input signal
	% this is avoids an buffer overflow for the last block
	output_signal = zeros(length(input_signal)+1*block_length,2);

    fir_1 = filter(ir_signal(1:2*block_length,1),1,input_signal(:,1));
    fir_2 = filter(ir_signal(1:2*block_length,2),1,input_signal(:,2));
   
	for i=0:num_input_blocks-1
		%left channel
		output_buffer = zeros(fft_length,1);
		for j=0:num_ir_blocks-1
			input_block_index = i-j;
			%at the beginning of the file there is no history yet --> exit loop
			if(input_block_index < 0)
				break;
            end
			% load the required blocks and zero-extend them to fft_length
			% rememer that the length of the result of a convolution is 
			% given by the addition of the lengths of the inputs signals 
			input_block = [input_signal(1+input_block_index*block_length:(input_block_index+1)*block_length,1);zeros(block_length,1)];
			ir_block = [ir_signal(1+j*block_length:(j+1)*block_length,1);zeros(block_length,1)];
			%perform the mulitplication in the freuqency domain
			
            if(j>1)
                output_buffer = output_buffer + fft(input_block) .* fft(ir_block);
            end
        end
		output_buffer = real(ifft(output_buffer)) + [fir_1(1+i*block_length:(i+1)*block_length);zeros(block_length,1)];
		
		output_signal(1+i*block_length:(i+2)*block_length,1) = output_buffer + output_signal(1+i*block_length:(i+2)*block_length,1);
		
		%right channel
		output_buffer = zeros(fft_length,1);
		for j=0:num_ir_blocks-1
			input_block_index = i-j;
			if(input_block_index < 0)
				break;
            end
			input_block = [input_signal(1+input_block_index*block_length:(input_block_index+1)*block_length,2);zeros(block_length,1)];
			ir_block = [ir_signal(1+j*block_length:(j+1)*block_length,2);zeros(block_length,1)];
			
            if(j>1)
                output_buffer = output_buffer + fft(input_block) .* fft(ir_block);
            end
        end
		output_buffer = real(ifft(output_buffer)) + [fir_2(1+i*block_length:(i+1)*block_length);zeros(block_length,1)];
		
		output_signal(1+i*block_length:(i+2)*block_length,2) = output_buffer + output_signal(1+i*block_length:(i+2)*block_length,2);
    end
   
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
cycle = f_fpga / f_s; %Zeit f�r direkt FFT

sprintf("Cost of Single-FDL Convolution")
O_SFDL = 4*k*log2(2*N) + 4*T/N; %Cost of Single-FDL Convolution
N_opt = solve(diff(O_SFDL,N)==0,N) %Optimal value for Single-FDL Convolution

sprintf("Cost of Double-FDL Convolution")
O_DoubleFDL = 4*k*log2(2*N) + 4*B/N + 4*k*log2(2*B) + 4*(T/B-1); %Cost of Double-FDL Convolution
B_opt = solve(diff(O_DoubleFDL,B)==0,B) %Optimal value for Double-FDL Convolution

