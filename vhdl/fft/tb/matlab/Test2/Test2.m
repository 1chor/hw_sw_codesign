% signals are already zero extended
xreal1 = zeros(1,512);
xreal2 = zeros(1,512);

xreal1(1:256) = 0:255; % values from 1 to 256                                                 
xreal2(1:256) = 255:-1:0; % values from 256 to 1

% create input files
xreal1h = fopen('real_input1.txt','w'); 
xreal2h = fopen('real_input2.txt','w'); 
fprintf(xreal1h,'%08X\n',xreal1); 
fprintf(xreal2h,'%08X\n',xreal2); 

[y1] = fft(xreal1); 
[y2] = fft(xreal2); 

% create output files
yreal1h = fopen('real_output1.txt','w');                                  
yimag1h = fopen('imag_output1.txt','w');
yreal2h = fopen('real_output2.txt','w');                                  
yimag2h = fopen('imag_output2.txt','w');
fprintf(yreal1h,'%08X\n',typecast(int16(real(y1)),'uint16'));                                                 
fprintf(yimag1h,'%08X\n',typecast(int16(imag(y1)),'uint16'));
fprintf(yreal2h,'%08X\n',typecast(int16(real(y2)),'uint16'));                                                 
fprintf(yimag2h,'%08X\n',typecast(int16(imag(y2)),'uint16'));

fclose(xreal1h);                                                                 
fclose(xreal2h);
fclose(yreal1h);                                                                 
fclose(yimag1h);
fclose(yreal2h);                                                                 
fclose(yimag2h);
