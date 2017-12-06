clear; close all;

%Initialize sound files
gts_init;

%Get the filename from the user
filename = input('Guitar tab image name: ', 's');
%filename = 'Test Images/test_image8.JPG';

%Find the order of the notes on the image
ordered_notes = image_read(filename);

%*****SOUND SYNTHESIS*****
notes_to_play = synthesize(ordered_notes);

%*****PLAY AUDIO*****
 Fsloc = Fs(1);
    %   need to fix - needs to be played much faster.

horizontal_loc = diff(cell2mat(ordered_notes{1}(:, 1)));
for i = 2:length(ordered_notes)
    horizontal_loc = [horizontal_loc; horizontal_loc(length(horizontal_loc)); diff(cell2mat(ordered_notes{i}(:, 1)))];
end

temp = sort(horizontal_loc, 'descend');
max_diff = mean(temp(1:3));
count = 0;
note_num = 1;
for i = 1:length(horizontal_loc)
    if(horizontal_loc(i) ~= 0 || i == length(horizontal_loc))
        if(i == length(horizontal_loc) && horizontal_loc(i) == 0)
            yA = notes_to_play{note_num};
            sound(yA(1:40000), Fsloc);
            pause_time = 1 * horizontal_loc(i) / max_diff;
            pause(pause_time);
            
%             note_num = note_num + 1;
%             
%             yA = notes_to_play{note_num};
%             sound(yA(1:40000), Fsloc);
        elseif(i == length(horizontal_loc) && horizontal_loc(i) ~= 0)
            yA = notes_to_play{note_num};
            sound(yA(1:40000), Fsloc);
            pause_time = 1 * horizontal_loc(i) / max_diff;
            if(pause_time > 1)
                pause_time = 1;
            end
            pause(pause_time);
            
            note_num = note_num + 1;
            
            yA = notes_to_play{note_num};
            sound(yA(1:40000), Fsloc);
        else
            yA = notes_to_play{note_num};
            sound(yA(1:40000), Fsloc);
            pause_time = 1 * horizontal_loc(i) / max_diff;
            if(pause_time > 1)
                pause_time = 1;
            end
            pause(pause_time);
            note_num = note_num + 1;
        end
    elseif(horizontal_loc(i) == 0)
        continue;
    end
end
% for(j=1:1:length(notes_to_play))
%     yA = notes_to_play{j};
%     sound(yA(1:40000),Fsloc);
%     pause(0.75);
% end