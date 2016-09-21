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
visualize_freqdomain(x,y,y_senior,t,h,Fs);

fileID = fopen('coeff.txt','w');
fprintf(fileID,'%s\n','Filter coefficients');
fprintf(fileID,'%.15f\n', h);
fclose(fileID);
