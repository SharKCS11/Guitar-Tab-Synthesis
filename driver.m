%Initialize sound files
gts_init;



%Get the filename from the user
%filename = input('Guitar tab image name: ', 's');
filename = 'Test Images/test_image9.JPG';

%Find the order of the notes on the image
ordered_notes = image_read(filename);

%*****SOUND SYNTHESIS*****
notes_to_play = synthesize(ordered_notes);

%*****PLAY AUDIO*****
 Fsloc = Fs(1);
    %   need to fix - needs to be played much faster.
for(j=1:1:length(notes_to_play))
    yA = notes_to_play{j};
    sound(yA(1:40000),Fsloc);
    pause(1);
end