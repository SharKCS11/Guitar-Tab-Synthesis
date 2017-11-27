function final_vector = produceSound(ordered_notes)
%produces vector with appropriate data for producing sound
%takes multiple notes along same x coordinate and rests into account
%takes the "note", horizontal value, pitch shift from ordered_notes

%store audio for the notes
[note_a, Fs_a] = audioread('a.wav');
[note_b, Fs_b] = audioread('b.wav');
[note_c, Fs_c] = audioread('c.wav');
[note_d, Fs_d] = audioread('d.wav');
[note_e, Fs_e] = audioread('e.wav');
[note_f, Fs_f] = audioread('f.wav');
[note_g, Fs_g] = audioread('g.wav'); 

%In order to find the duration of notes, we need to look at the "horizontal
%value" of each note, adjust for each image's scaling/differences between
%horizontal values. Used this scaling value to adjust the endTimer in
%playerObject
x = 1:length(ordered_notes);
y = [];
for j = 1:length(ordered_notes)
    y = [y ordered_notes[j][1]];
end
p = polyfit(x, y,1);
scaling = p(1);
note_length = 0;
note_scaler = 0;

final_vector = [];
for i = 1:length(ordered_notes)
    %Takes the horizontal distance between current note and next note,
    %divide by scaling to see duration. Rounded it to get the general
    %region
    if(i < length(ordered_notes))
        note_length = round((ordered_notes[i+1][1] - ordered_notes[i][1]) / scaling);
    end
    %note_scaler used to specify endTime in playerObject
    if(note_length == 1)
        note_scaler = .25;
    elseif(note_length == 2)
        note_scaler = .5
    else
        note_scaler = 1;
    end
    beginTime = 0;
    pitchshift_value = ordered_notes[i][4];
    %could be more efficient, but looks at note value and shift value to
    %make the playerobject
    switch ordered_notes[i][2]
        case 'A'
            finishTime = note_scaler * Fs_a;
            shifted_data = pitch_shift(note_a, pitchshift_value);
            playerobj = audioplayer(shifted_data(beginTime:finishTime,:), Fs_a);
        case 'B'
            finishTime = note_scaler * Fs_b;
            shifted_data = pitch_shift(note_b, pitchshift_value);
            playerobj = audioplayer(shifted_data(beginTime:finishTime,:), Fs_b);
        case 'C'
            finishTime = note_scaler * Fs_c;
            shifted_data = pitch_shift(note_c, pitchshift_value);
            playerobj = audioplayer(shifted_data(beginTime:finishTime,:), Fs_c);
        case 'D'
            finishTime = note_scaler * Fs_d;
            shifted_data = pitch_shift(note_d, pitchshift_value);
            playerobj = audioplayer(shifted_data(beginTime:finishTime,:), Fs_d);
        case 'E'
            finishTime = note_scaler * Fs_e;
            shifted_data = pitch_shift(note_e, pitchshift_value);
            playerobj = audioplayer(shifted_data(beginTime:finishTime,:), Fs_e);
        case 'F'
            finishTime = note_scaler * Fs_f;
            shifted_data = pitch_shift(note_f, pitchshift_value);
            playerobj = audioplayer(shifted_data(beginTime:finishTime,:), Fs_f);
        case 'G'
            finishTime = note_scaler * Fs_g;
            shifted_data = pitch_shift(note_g, pitchshift_value);
            playerobj = audioplayer(shifted_data(beginTime:finishTime,:), Fs_g);
        otherwise
            print('error, exiting');
            
    end

    finalvector = [finalvector playerobj];
end
        
       

