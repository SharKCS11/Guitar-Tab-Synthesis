%Initialize sound files
%{
Sample rates:
E6 - 44100  A5 - 48000
D4 - 44100  G3 - 44100
B2 - 44100  E1 - 44100
%}

%Get the filename from the user
filename = input('Guitar tab image name: ', 's');

%Find the order of the notes on the image
ordered_notes = image_read(filename);
ordered_notes = ordered_notes{1};

%*****SOUND SYNTHESIS*****

%*****PLAY AUDIO*****
