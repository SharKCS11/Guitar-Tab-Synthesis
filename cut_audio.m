[yA,Fs]=audioread('Ref_sounds/Auncut.wav');
nsamp = 4*Fs;
yB = yA(1:nsamp,:);
audiowrite('Ref_sounds/openA5.wav',yB,Fs);