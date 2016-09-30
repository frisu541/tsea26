% Load noisy input data into x
x=read_hex('IOS0010');

Fs=500; % Sampling frequency
N=length(x);
t = (0:N-1)/Fs; % time axis

% Create a low pass filter with a cut-off frequency of 15 Hz
order=31;
Wn = 15/(Fs/2); % Cut-off frequency 15 Hz
h = fir1(order, Wn);  

% Matlab based filtering
y = filter(h, 1, x);

if exist('IOS0011', 'file')
  y_senior=read_hex('IOS0011');
 else
   fprintf('Warning: IOS0011 output from srsim not found!\n'); 
   y_senior=zeros(1,length(y));
end

relerr = visualize_timedomain(x,y,y_senior,t,h);
fprintf('Relative error of Senior implementation compared to Matlab implementation: %f\n',relerr);
%visualize_freqdomain(x,y,y_senior,t,h,Fs);

fileID = fopen('coeff.txt','w');
fprintf(fileID,'%s\n','Filter coefficients');
fprintf(fileID,'	.df %.24f\n', h);
fclose(fileID);

%%
h_fi = fi(h, true, 16, 15);
h_hex = hex(h_fi);

fileID = fopen('coeff_hex.txt','w');
fprintf(fileID,'%s\n','Filter coefficients (fixed point 1.15, hex form)');
for i=1:32
    pos = (i-1)*7;
    fprintf(fileID,'	.dw 0x%s\n', h_hex(pos+1:pos+4));
end
fclose(fileID);

%% Signed scaling of coefficients, abs(max(h)*sf) < 1
hmax = max(abs(h));
sf = 2^floor(abs(log2(hmax))); % = 8

h8 = h*8; % scaling factor: 8

h8_fi = fi(h8, true, 16, 15);
h8_hex = hex(h8_fi);

fileID = fopen('coeff_hex_mul8.txt','w');
fprintf(fileID,'%s\n','Filter coefficients mul8 (fixed point 1.15, hex form)');
for i=1:32
    pos = (i-1)*7;
    fprintf(fileID,'	.dw 0x%s\n', h8_hex(pos+1:pos+4));
end
fclose(fileID);

%% Unsigned scaling of coefficients
h8_fiu = fi(h8, false, 16, 16);
h8_hexu = hex(h8_fiu);

fileID = fopen('coeff_hex_mul8_unsigned.txt','w');
fprintf(fileID,'%s\n','Filter coefficients mul8, unsigned (fixed point 1.15, hex form)');
for i=1:32
    pos = (i-1)*7;
    fprintf(fileID,'	.dw 0x%s\n', h8_hexu(pos+1:pos+4));
end
fclose(fileID);






