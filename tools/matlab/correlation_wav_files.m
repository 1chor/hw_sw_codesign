function correlation_wav_files(infile1, infile2)

	% read source audio file
	[signal1, signal1_samplerate] = audioread(infile1);

	[infile1_pathstr,infile1_name,infile1_ext] = fileparts(infile1);

    size_sig1 =size(signal1);
	if size_sig1(2) ~= 2
		disp "infile1 not stereo!";
		return;
	end

	% read source audio file
	[signal2, signal2_samplerate] = audioread(infile2);

	[infile2_pathstr,infile2_name,infile2_ext] = fileparts(infile2);

    size_sig2 =size(signal2);
	if size_sig2(2) ~= 2
		disp "infile2 not stereo!";
		return;
	end


	left = signal_corr(signal1(:,1), signal2(:,1));
	right = signal_corr(signal1(:,2), signal2(:,2));
	correlation = (left+right)/2;


	sprintf("qualitiy check on [%s] and [%s]", infile1, infile2)
	sprintf("%s%s: length = %i samples", infile1_name, infile1_ext, length(signal1(:,1)) )
	sprintf("%s%s: length = %i samples", infile2_name, infile2_ext, length(signal2(:,1)) )
	minLength = min(length(signal1(:,1)), length(signal2(:,1)))
	sprintf("max difference left channel: %f", max(abs(signal1(1:minLength,1) - signal2(1:minLength,1))) )
	sprintf("max difference right channel: %f", max(abs(signal1(1:minLength,2) - signal2(1:minLength,2))) )
	sprintf("correlation: %f \n", correlation) 

	
	%plotStart = 44100 * 2;
	%plotLength = 44100 * 3;%16*2048;% minLength;   
	%plot(signal1(plotStart:plotLength,1))
	%hold on
 	%plot(signal2(plotStart:plotLength,1), 'r')
	%pause();
end


function result = signal_corr(s1, s2)
  % make signals same length; zero pad shorter one
  %maxLength = max(length(s1), length(s2));
  %s1 = [s1 ; zeros(maxLength-length(s1),1)];
  %s2 = [s2 ; zeros(maxLength-length(s2),1)];
  
  %make signals same length; cut off longer one
  minLength = min(length(s1), length(s2)) ;
  s1 = s1(1:minLength);
  s2 = s2(1:minLength);
  
  % compute normalized signal correlation, range: [-1, 1]
  corr = sum(s1.*s2);
  auto1 = sum(s1.*s1);
  auto2 = sum(s2.*s2);
  result = corr / sqrt(auto1*auto2);
end
