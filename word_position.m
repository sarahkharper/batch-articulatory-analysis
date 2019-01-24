function word_position(filename)
%Codes for the position of the target phoneme in the word (onset, cluster
%onset, coda or cluster coda) and appends information to CSV file
%specified when function is called
%
%(Example script: needs to be generalized for phoneme input)
%
%Sarah Harper 11/18

data = readtable(filename);

POS = [];
CLUST = [];

for i = 1:length(data.SUBJ),
    word = data.WORD{i};
    prev = data.PREV_PHONE(i);
    post = data.FOLL_PHONE(i);
    if strcmp(word,'sp'),
        if length(prev) > 3,
            data.WORD(i) = prev;
            word = prev;
        elseif length(post) > 3,
            data.WORD(i) = post;
            word = post;
        end
    end
    frst = word(1);
    lst = word(end);
    if strcmp(frst,'R'),
        pos = 'ON';
        clust = 'SI';
    elseif strcmp(lst,'R'),
        pos = 'CO';
        clust = 'SI';
    elseif strcmp(prev,'sp'),
        pos = 'ON';
        clust = 'SI';
    elseif strcmp(post,'sp'),
        pos = 'CO';
        clust = 'SI';
    elseif strcmp(prev,'B'),
        pos = 'ON';
        clust = 'CL';
    elseif strcmp(prev,'F'),
        pos = 'ON';
        clust = 'CL';
    elseif strcmp(prev,'P'),
        pos = 'ON';
        clust = 'CL';
    elseif strcmp(post,'B'),
        pos = 'CO';
        clust = 'CL';
    elseif strcmp(post,'P'),
        pos = 'CO';
        clust = 'CL';
    elseif strcmp(post,'F'),
        pos = 'CO';
        clust = 'CL';
    elseif strcmp(post,'M'),
        pos = 'CO';
        clust = 'CL';
    elseif strcmp(post,'V'),
        pos = 'CO';
        clust = 'CL';
    else
        pos = 'MI';
        clust = 'MI';
    end
    POS = [POS; pos];
    CLUST = [CLUST; clust];
end

tab = table(POS, CLUST, 'VariableNames', {'POSITION', 'CLUSTER'});
tfinal = [data, tab];
writetable(tfinal, filename);


