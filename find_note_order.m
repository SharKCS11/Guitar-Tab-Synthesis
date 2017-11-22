%Inputs: locations (cell array with location information across all
%strings), feature_widths (vector with widths of all feature images)

%Outputs: ordered_notes(cell array with length = # of string groups.
%A string group is (total # of strings) / 6 <- 6 strings/group. Each
%element in the cell array is a n x 4 cell array, where n is the total
%number of notes found that that string group. 
%    element(:, 1) = Horizontal locations column
%    element(:, 2) = Note letter -> each string corresponds to a note
%    element(:, 3) = String number. Strings numbering starts where string 1
%                    is the top-most string. Indexing starts over with each
%                    new group of strings. See below:
%                    -------------- 1
%                    -------------- 2
%                    -------------- 3
%                    -------------- 4
%                    -------------- 5
%                    -------------- 6
%
%                    -------------- 1
%                    -------------- 2
%                    -------------- 3
%                    -------------- 4
%                    -------------- 5
%                    -------------- 6
%    element(:, 4) = Fret number -> the number found on the guitar tab

function ordered_notes = find_note_order(locations, feature_widths)
    ordered_notes = [];
    num_strings = size(locations{1}, 1);
    
    notes = ['E', 'B', 'G', 'D', 'A', 'E'];

%FIND NOTES FROM LOCATION INFORMATION
%Note: At some locations and strings, there may be more than one note. The
%incorrectly identified notes are removed in the second section of this function.
    
    %Loop through every group of 6 strings
    for string_group = 1:num_strings/6  
        temp_ordered_notes = [];
        
        %Loop through every string
        for string_num = 1:6
            %Loop through every feature (0, 1, 2, ..., 12)
            for feature = 1:size(locations, 1)
                %Find output of localized_dot_product for a given feature 
                loc = locations{feature}(6*(string_group - 1) + string_num, :);
                
                %Find all nonzero indices
                y = find(loc);
                while(~isempty(find(y, 1)))
                    %Group the nonzero points so that points with similar
                    %horizontal indices are considered the same "location".
                    %For instance, if the locations vector has non-zero
                    %values a [15, 16, 17, 100, 101, 102], the first
                    %iteration of the while loop, temp will be [15, 16,
                    %17], and the second iteration of the while loop, temp
                    %will be [100, 101, 102].
                    
                    temp = y((y > y(1) - floor(feature_widths(feature)) & (y < y(1) + ceil(feature_widths(feature)) - 1)));

                    %Determine index of string to generate string letter
                    ind = mod(string_num, 6);
                    if (~ind)
                        ind = 6;
                    end

                    %Creates a note for each grouping of non-zero location values
                    %Appends note to temp_ordered_notes
                    note = {floor(mean(temp)), notes(ind), string_num, feature - 1};
                    temp_ordered_notes = [temp_ordered_notes; note];
                    
                    %Removes the group of non-zero location values for next
                    %loop iteration.
                    y = y(y>max(temp));
                end
            end
        end
                
%REPEATED NOTES CORRECTION       
        
        %Sort all found notes by horizontal location. Note that
        %temp_ordered_notes at this point could contain note-location
        %conflicts. The following code corrects that by doing a direct
        %comparison with notes in the same horizontal location groupings.
        temp_ordered_notes = sortrows(temp_ordered_notes, 1);
        
        %Grab horizontal locations
        horz_locations = cell2mat(temp_ordered_notes(:, 1));
        ctr = 1;
        
        %Indices note-location conflicts to be deleted at end. 
        %Note: Deletion must occur after the loop or else indexing gets
        %thrown off.
        delete_inds = [];
        while(~isempty(horz_locations))
            %Group notes by relative horizontal positions
            horz_range = horz_locations((horz_locations > horz_locations(1) - 15) & (horz_locations < horz_locations(1) + 15));
            
            %If there is no repeated note for a horizontal location, no
            %need to delete any notes. Skip loop iteration.
            if(length(horz_range) == 1)
                horz_locations = horz_locations(horz_locations > max(horz_range));
                ctr = ctr + length(horz_range);
                continue;
            end
            
            %Find the strings of all the notes in the same horizontal
            %position
            all_strings = cell2mat(temp_ordered_notes(ctr:ctr + length(horz_range) - 1, 3)); 
            
            %Find indices of repeated strings 
            %Note: indices returned are for ANY repeated note for any string. The
            %difficulty is separating out which indices correspond to which string 
            [num, bin] = histc(all_strings, unique(all_strings));
            multiple = find(num > 1);
            repeated_string_ind = find(ismember(bin, multiple));
            
            %Since there are indices that correspond to the same string,
            %keep track of indices that have already been searched.
            checked_inds = [];
            
            %Loop through all indices
            for o = 1:length(repeated_string_ind)
                
                %If index has already been checked, skip this loop
                %iteration
                if(ismember(repeated_string_ind(o), checked_inds))
                    continue;
                end
                
                %Find the value of the string that is repeated
                repeated_string = all_strings(repeated_string_ind(o));
                
                %Find all indices of local horizontal position that have
                %this string value
                string_inds = find(all_strings == repeated_string);
                
                max_vals = [];
                
                %For every string index, look at the maximum value of the
                %dot product over this local horizontal position. 
                for p = 1:length(string_inds)
                    feature_num = temp_ordered_notes{ctr + string_inds(p) - 1, 4} + 1;
                    dot_out = locations{feature_num}(repeated_string, unique(horz_range));
                    max_vals(p) = max(dot_out);
                end
                
                %Want to keep the note with the highest dot product value.
                %Store the rest of the indices in delete_inds so those
                %corresponding notes can be deleted later
                [keep_val, keep_ind] = max(max_vals);
                for q = 1:length(string_inds)
                    if(q ~= keep_ind)
                        delete_inds = [delete_inds, ctr + string_inds(q) - 1];
                    end
                end              
                
                %Record which indices have been visited
                checked_inds = [checked_inds; string_inds];
            end          
            
            %Assign one horizontal value to each localized region. Decided
            %to average all horizontal position locations and take the
            %floor. Decision was arbitrary, and since the notes are spread
            %out, this decision does not matter too much.
            for r = 1:length(horz_range)
                horz_value = floor(mean(horz_range));
                temp_ordered_notes{ctr + r - 1, 1} = horz_value;
            end
            
            %Increment counter
            ctr = ctr + length(horz_range);
            
            %Eliminate searched horizontal range from the horizontal
            %locations
            horz_locations = horz_locations(horz_locations > max(horz_range));
        end
        
        %Delete repeated notes
        temp_ordered_notes(delete_inds, :) = [];
        
        %Sort the notes first by 1.) horizontal location and 2.) string
        %location
        temp_ordered_notes = sortrows(temp_ordered_notes, [1, 3]);
        
        %Append this group of 6 strings to output
        ordered_notes{end + 1} = temp_ordered_notes;
    end   
end