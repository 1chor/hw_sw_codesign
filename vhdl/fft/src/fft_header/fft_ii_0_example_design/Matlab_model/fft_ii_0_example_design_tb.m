%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file : fft_ii_0_example_design_tb.m
%
% Description : The following Matlab testbench excercises the Altera FFT Model fft_ii_0_example_design_model.m
% generated by Altera's FFT Megacore and outputs results to text files.
%
% Copyright Altera
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameterization Space    
N=512;
% Read input complex vector from source text files
fidr = fopen('fft_ii_0_example_design_real_input.txt','r');                                            
fidi = fopen('fft_ii_0_example_design_imag_input.txt','r');                                           
xreali=fscanf(fidr,'%d');                                                    
ximagi=fscanf(fidi,'%d');                                                    
fclose(fidi);                                                                  
fclose(fidr);                                                                
% Create input complex row vector from source text files 
x = xreali' + j*ximagi';                                                        
[y, exp_out] = fft_ii_0_example_design_model(x,N,0); 
fidro = fopen('fft_ii_0_example_design_real_output_c_model.txt','w');                                 
fidio = fopen('fft_ii_0_example_design_imag_output_c_model.txt','w');                                  
fideo = fopen('fft_ii_0_example_design_exponent_out_c_model.txt','w');                                 
fprintf(fidro,'%d\n',real(y));                                                
fprintf(fidio,'%d\n',imag(y));                                                
fprintf(fideo,'%d\n',exp_out);                                               
fclose(fidro);                                                                
fclose(fidio);                                                              
fclose(fideo);                                                                 

