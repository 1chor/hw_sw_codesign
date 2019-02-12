fidr = fopen('real_input_dec.txt','r');                                            
fidi = fopen('imag_input_dec.txt','r');  
xreali=fscanf(fidr,'%d', 512);                                                      
ximagi=fscanf(fidi,'%d', 512);   
fclose(fidi);                                                                  
fclose(fidr);   
% Create input complex row vector from source text files 
x = xreali + ximagi*i;
[y] = fft(x); 

xrealh = fopen('real_input.txt','w');                                  
ximagh = fopen('imag_input.txt','w');
yrealh = fopen('real_output.txt','w');                                  
yimagh = fopen('imag_output.txt','w');
fprintf(xrealh,'%08X\n',xreali);                                                 
fprintf(ximagh,'%08X\n',ximagi);
fprintf(yrealh,'%08X\n',typecast(int16(real(y)),'uint16'));                                                 
fprintf(yimagh,'%08X\n',typecast(int16(imag(y)),'uint16'));

fclose(xrealh);                                                                 
fclose(ximagh);
fclose(yrealh);                                                                 
fclose(yimagh);
