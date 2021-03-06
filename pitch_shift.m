function [yOut] = pitch_shift(yIn,NH)
% PITCH_SHIFT  Shift pitch of sound yIn by 'NH' half-steps
% Each interval will be approximated by multiplying by
% 2^(1/12) per half-step, as on a real fretted instrument

% requires: pvoc_files to be in working directory
shfactor = 2^(NH*1/12);
tsaudio = pvoc(yIn,1/shfactor);
[N1,D1] = rat(1/shfactor); % approximate 1/shfactor to a rational number
yOut = resample(tsaudio,N1,D1);

% pitch shift may shorten file length: zero pad end of vector.
if(length(yOut) < length(yIn))
   yOut = padarray(yOut,[length(yIn)-length(yOut),0],'post');
end

end

%{ 
Pitch shifting code provided by D.P.W. Ellis of Columbia University
This phase vocoder is an open-source implementation of the algorithm
by Flanagan & Golden/Dolson
@misc{Ellis02-pvoc
  author = {D. P. W. Ellis},
  year = {2002},
  title = {A Phase Vocoder in {M}atlab},
  note = {Web resource},
  url = {http://www.ee.columbia.edu/~dpwe/resources/matlab/pvoc/},
}
%}

