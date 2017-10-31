% Read open A wav file
[yA,Fs]=audioread('openA.wav');
length = 4 % seconds
nsamp = length*Fs;
yA=yA(1:nsamp,:);
yA_freq = fft(yA);
om = linspace(1,Fs/2,nsamp);

