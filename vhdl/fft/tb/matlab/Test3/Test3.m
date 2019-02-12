% signals are already zero extended
xreal = zeros(1,512);

for i=1:127 
	xreal(2*i) = i; % positive values
	xreal(2*i+1) = -i; % negative values       
end

% create input files
xrealh = fopen('real_input.txt','w'); 
fprintf(xrealh,'%08X\n',typecast(int16(xreal),'uint16'));  

[y] = fft(xreal); 

% create output files
yrealh = fopen('real_output.txt','w');                                  
yimagh = fopen('imag_output.txt','w');
fprintf(yrealh,'%08X\n',typecast(int16(real(y)),'uint16'));                                                 
fprintf(yimagh,'%08X\n',typecast(int16(imag(y)),'uint16'));

fclose(xrealh);    
fclose(yrealh);                                                                 
fclose(yimagh);
