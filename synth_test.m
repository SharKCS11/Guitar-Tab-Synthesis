% Read open A wav file
[yA,Fs]=audioread('openA.wav');
length = 4 % seconds
nsamp = length*Fs;
yC=yA(1:nsamp,:);
yB=yA(1:nsamp,1)+yA(1:nsamp,2);
t=linspace(0,4,nsamp);
figure(1);
plot(t,yB);
xlabel('t (s)');
title('First four seconds of open A-note');
yB_freq = fftshift(fft(yB));
om = linspace(-Fs/2,Fs/2,nsamp);
figure(2);
plot(om,abs(yB_freq));
xlabel('f');
title('Frequency components of open A note');
hfs = 2^(1/12); % multiply by this to get half-step
audiowrite('openA2.wav',yC,Fs);