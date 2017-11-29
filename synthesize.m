function [notes] = synthesize(ordered_notes)
%{ 
SYNTHESIZE - takes in an ordered_notes cell and outputs a cell of audio
vectors, (each 4-seconds long). This function should be called prior
to producing sound.

Preconditions: The "driver" function has been called. Do not call this
function before independently of driver, as the data structures for sound
files need to be initialized.
C-style format of note data structure (for reference):
struct note{
    used; (boolean to tell whether the note has been previously requested)
    audio; (audio vector to actually play the note)
};

%}
notes =cell(1,1);
notesIdx = 1;
for(cellidx=1:1:length(ordered_notes))
    g_ord_notes = ordered_notes{cellidx};
    group = [];
    i = 1;
    while(i<=size(g_ord_notes,1))
        curr_loc = g_ord_notes{i,1}; % give 5-pixel tolerance
        group = [group ; g_ord_notes{i,3}, g_ord_notes{i,4}];
        i = i+1;
        if(i <= size(g_ord_notes,1) && abs(g_ord_notes{i,1}-curr_loc < 5))
           %if i is in range AND next location is within tolerance,
           continue;
        else % get notes
            notes{notesIdx} = getSoundVec(group);
            notesIdx = notesIdx+1;
            group = [];
        end
    end
end


end

% Gets the audio from string/fret value.
function soundOut = getSoundVec(note_vals)
%{
format of note vals should be [string, fret ; string, fret ; etc.]
This function will use dynamic programming to generate and return audio
vectors to be played.
%}
soundOut = [];
soundCnt = 0;
global MNR
for(j=1:1:size(note_vals,1))
    strIdx = note_vals(j,1);
    fretIdx = note_vals(j,2)+1;
    if(~MNR(strIdx,fretIdx).used) % If note has NOT been used before, generate and memoize.
        fprintf('Note %d, %d encountered the first time. Generating.\n',strIdx,fretIdx-1);
        MNR(strIdx,fretIdx).used = true;
        MNR(strIdx,fretIdx).audio = pitch_shift(MNR(strIdx,1).audio,fretIdx-1);
    end
    if(length(soundOut)<1)
        soundOut = MNR(strIdx,fretIdx).audio;
    else
        soundOut = soundOut + MNR(strIdx,fretIdx).audio;
    end
    soundCnt = soundCnt + 1;
end
soundOut = soundOut./soundCnt;


end
