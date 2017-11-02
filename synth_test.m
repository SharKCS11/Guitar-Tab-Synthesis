% Read open A wav file
[yA,Fs]=audioread('openA.wav');
length = 4 % seconds
nsamp = length*Fs;
yB=yA(1:nsamp,1)+yA(1:nsamp,2);
yB_freq = fftshift(fft(yB));
om = linspace(-Fs/2,Fs/2,nsamp);
plot(om,abs(yB_freq));
xlabel('f');
title('Frequency components of open A note');
hfs = 2^(1/12); % multiply by this to get half-step
