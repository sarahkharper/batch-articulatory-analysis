function lableCreate(dirname)

cd(dirname);

fileList = dir('*.csv');

for f = 1:length(fileList),
    cd(dirname);
    fil = fileList(f).name;
    data = readtable(fil);
    OFFSET = [];
    VALUE = [];
    for i = 1:height(data), 
        %Get midpoint and add to OFFSET
        starts = data.tmin(i)*1000;
        ends = data.tmax(i)*1000;
        dur = starts - ends;
        midpt = (dur/2)+starts;
        OFFSET = [OFFSET; midpt];
        
        %Combine tmin and tmax into one variable, VALUE
        val = [starts ends];
        VALUE = [VALUE; val];
        
        %Change place holders
        if strcmp(data.text(i),'{SL}')||strcmp(data.text(i),'sil')||strcmp(data.text(i),'{NS}')||strcmp(data.text(i),'ns')
            data.text{i} = 'sp';
        end
    end
        
    %Rename text and tier variables
    nameind = find(strcmp(data.Properties.VariableNames, 'text'),1);
    hookind = find(strcmp(data.Properties.VariableNames, 'tier'),1);
    data.Properties.VariableNames([nameind hookind]) = {'NAME', 'HOOK'};

    %Delete redundant tmin and tmax table variables and add new variables
    data.tmin = [];
    data.tmax = [];
    data.VALUE = VALUE;
    data.OFFSET = OFFSET;

    %Convert table to struct and add to appropriate pre-existing labels
    %file
    sdata = table2struct(data);
    [~, fname, ext] = fileparts(fil);
    tsk = fname(end-2:end);
    labname = sprintf('labels_task%s.mat', tsk);
%     eman = fname(1:end-3);
    finname = strcat(fname,'_lbl');
    finname
    partdir = dirname(1:end-11);
    labdir = strcat(partdir, 'labels');
    cd(labdir);
    if exist(labname, 'file'),
        m = matfile(labname, 'Writable', true);
        m.(finname) = sdata;
    else
        save(labname, 'sdata');
        m = matfile(labname, 'Writable', true);
        m.(finname) = sdata;
    end
end