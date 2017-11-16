% Read first four seconds of open A
[yA,Fs]=audioread('openA2.wav');
yOut = pitch_shift(yA,2); % shift A2 one whole-step to B2
sound(yA,Fs);
pause(1.5);
sound(yOut,Fs);