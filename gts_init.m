%{
This script initializes the data structures and audio files needed
by the guitar tab synthesizer.

Sample rates:
E6 - 44100  A5 - 48000
D4 - 44100  G3 - 44100
B2 - 44100  E1 - 44100

Need a cell of structures: 6-by-13.
C-style format of struct (for reference):
struct note{
    used; (boolean to tell whether the note has been previously requested)
    audio; (audio vector to actually play the note)
};
%}
global MNR;
global Fs;
MNR = struct([]); % master note-record
noteElt = struct('used',false,'audio',[]); % initial struct values
MNR(6,13).used = false;
MNR(6,13).audio = [];
[MNR(:)] = deal(noteElt); % fill full struct
Fs = ones(1,6);
% Initialize all open strings.
base_soundnames = {'openE1.wav','openB2.wav','openG3.wav','openD4.wav','openA5.wav','openE6.wav'};
for(i=1:1:6)
   fprintf('Reading %s\n',base_soundnames{i});
   MNR(i,1).used = true;
   [MNR(i,1).audio,Fs(i)] = audioread(base_soundnames{i});
   % sound(MNR(i,1).audio(1:Fs(i)),Fs(i)); % uncomment to test init.
   % pause(0.66);
end




