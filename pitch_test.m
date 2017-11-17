% Read first four seconds of open A
[yA,Fs]=audioread('openA2.wav');
nsamp = 4*Fs;
yC = pitch_shift(yA,3); % shift A2 one whole-step to B2
yB = sum(yA')';
% Get frequency components for b
yB_freq = fftshift(fft(yB));
om = linspace(-Fs/2,Fs/2,nsamp);
figure(2);
plot(om,abs(yB_freq));
title('Frequency components of open A note');
xlabel('f (Hz)');
% Get frequency components for C
yC_freq=fftshift(fft(yC));
figure(3);
plot(om,abs(yC_freq));
title(sprintf('Frequency components of C3 \n(open A shifted 3 half-steps)'));
xlabel('f (Hz)');
sound(yA,Fs);
pause(1.5);
sound(yC,Fs);