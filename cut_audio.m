[yA,Fs]=audioread('Ref_sounds/Buncut.wav');
nsamp = 4*Fs;
yB = yA(1:nsamp,:);
audiowrite('Ref_sounds/openB2.wav',yB,Fs);