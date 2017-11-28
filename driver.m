%Get the filename from the user
filename = input('Guitar tab image name: ', 's');

%Find the order of the notes on the image
ordered_notes = image_read(filename);

%*****SOUND SYNTHESIS*****

%*****PLAY AUDIO*****
