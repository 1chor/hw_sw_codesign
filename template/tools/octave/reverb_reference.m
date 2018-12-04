#!/bin/octave
function reverb_reference(infile, outfile, impluseresponsefile)
	#load input signals 
  infile = '.\..\sample_files\input.wav'
  outfile = '.\..\sample_files\output.wav'
  impluseresponsefile = '.\..\sample_files\ir_cave.wav'
    
	[ir_signal, ir_sampleRate] = audioread(impluseresponsefile);
	[input_signal, input_sampleRate] = audioread(infile);

	# ir_signal and input_singal are vectors of stero values, i.e. a matrix with two
	# columns and length(*_signal) rows

	# To get the Nth stero sample use:
	# >> input_signal(1,:)

	# To get all samples of one channel use (where x is either 1 or 2)
	# >> input_signal(:,x)

	# Note that in Matlab/Octave the first index in an array has index ONE!

	fft_length = pow2(13); # returns th Nth power of two


	# for easier processing, make sure that the input signal as well as the imuplse
	# response signal have a length which is a mulitple of fft_length/2 ()

	printf("Original file lengths [# stero samples]:\n")
	printf("  input file: %d\n", length(input_signal))
	printf("  ir file: %d\n", length(ir_signal))

	ir_length = ceil(length(ir_signal)/(fft_length/2))*(fft_length/2);
	input_length = ceil(length(input_signal)/(fft_length/2))*(fft_length/2);

	ir_signal = [ir_signal;zeros(ir_length-length(ir_signal),2)];
	input_signal = [input_signal;zeros(input_length-length(input_signal),2)];

	printf("File lengths after zero-extension [# stero samples]:\n")
	printf("  input file: %d\n", length(input_signal))
	printf("  ir file: %d\n", length(ir_signal))


	# To perform the convolution using the overlap-add method we chop up the input
	# signal and the impulse response into chunks of length block_length 
	fft_length
	block_length = fft_length/2
	num_input_blocks = length(input_signal)/block_length
	num_ir_blocks = length(ir_signal)/block_length

	# initialize output signal and make it one block longer than the input signal
	# this is avoids an buffer overflow for the last block
	output_signal = zeros(length(input_signal)+1*block_length,2);

	for i=0:num_input_blocks-1
		#left channel
		output_buffer = zeros(fft_length,1);
		for j=0:num_ir_blocks-1
			input_block_index = i-j;
			#at the beginning of the file there is no history yet --> exit loop
			if(input_block_index < 0)
				break;
			endif
			# load the required blocks and zero-extend them to fft_length
			# rememer that the length of the result of a convolution is 
			# given by the addition of the lengths of the inputs signals 
			input_block = [input_signal(1+input_block_index*block_length:(input_block_index+1)*block_length,1);zeros(block_length,1)];
			ir_block = [ir_signal(1+j*block_length:(j+1)*block_length,1);zeros(block_length,1)];
			#perform the mulitplication in the freuqency domain
			output_buffer .+= fft(input_block) .* fft(ir_block);
		endfor;
		output_buffer = real(ifft(output_buffer));
		
		output_signal(1+i*block_length:(i+2)*block_length,1) .+= output_buffer;
		
		
		#right channel
		output_buffer = zeros(fft_length,1);
		for j=0:num_ir_blocks-1
			input_block_index = i-j;
			if(input_block_index < 0)
				break;
			endif
			input_block = [input_signal(1+input_block_index*block_length:(input_block_index+1)*block_length,2);zeros(block_length,1)];
			ir_block = [ir_signal(1+j*block_length:(j+1)*block_length,2);zeros(block_length,1)];
			output_buffer .+= fft(input_block) .* fft(ir_block);
		endfor;
		output_buffer = real(ifft(output_buffer));
		
		output_signal(1+i*block_length:(i+2)*block_length,2) .+= output_buffer;
	endfor;

	# crop the size of the output_signal to that of the input signal 
	output_signal = output_signal(1:length(input_signal),:);

	#scale by maximum value --> i.e. normalize to 1
	output_signal(:,1) ./= max(output_signal(:,1));
	output_signal(:,2) ./= max(output_signal(:,2));

	#scale by fixed value
	#scale = 16
	#output_signal(:,1) ./= scale;
	#output_signal(:,2) ./= scale;

	audiowrite(outfile, output_signal, input_sampleRate,'BitsPerSample',16);

endfunction;

