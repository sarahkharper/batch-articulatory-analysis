function out = Append_CD(filename);
%Uses CSV file with ScanCorpusGestSensors output and TTCD_CL script that
%computes lingual pellet distances from palate to append constriction
%location and degree measurements to input CSV file
%
%Can be modified to get distances from pharyngeal wall instead of palate
%(see comment @ line 31)
%
%Sarah Harper 11/2018

T1CLC = [];
T2CLC = [];
T3CLC = [];
T4CLC = [];
T1CLV = [];
T2CLV = [];
T3CLV = [];
T4CLV = [];
T1CDC = [];
T2CDC = [];
T3CDC = [];
T4CDC = [];
T1CDV = [];
T2CDV = [];
T3CDV = [];
T4CDV = [];

datacsv = readtable(filename);
for i = 1:length(datacsv.SUBJ);
    fn = sprintf('%s_%s', char(datacsv.SUBJ(i)),char(datacsv.TASK(i)));
    try,
        datamat = LoadMAT(fullfile('mat',fn),fn);
        %Load palate trace (note: if distances from pharyngeal wall
        %desired, can change 'pal' to 'phar')
        pal = LoadMAT(fullfile('mat',fn),'pal');
        data = TTCD_CL(datamat,pal);
    catch,
        fprintf('error attempting to load mat/%s (skipped)\n',fn);
        continue;
    end;
    timC = datacsv.Time_ms_C(i);
    timV = datacsv.Time_ms_V(i);
    maxC = floor(timC*datamat(5).SRATE/1000);
    maxV = floor(timV*datamat(5).SRATE/1000);
    %Find row of struct where NAME value is T1CL
    icl = find(strcmp({data.NAME}, 'T1CL')==1);
    %Get constriction location (on palate) for each lingual sensor for both timepoints
    T1CLC = [T1CLC; data(icl).SIGNAL(maxC)];
    T2CLC = [T2CLC; data(icl+2).SIGNAL(maxC)];
    T3CLC = [T3CLC; data(icl+4).SIGNAL(maxC)];
    T4CLC = [T4CLC; data(icl+6).SIGNAL(maxC)];
    T1CLV = [T1CLV; data(icl).SIGNAL(maxV)];
    T2CLV = [T2CLV; data(icl+2).SIGNAL(maxV)];
    T3CLV = [T3CLV; data(icl+4).SIGNAL(maxV)];
    T4CLV = [T4CLV; data(icl+6).SIGNAL(maxV)];
    %Get constriction degree (dist from palate) for each lingual sensor for both timepoints
    T1CDC = [T1CDC; data(icl+1).SIGNAL(maxC)];
    T2CDC = [T2CDC; data(icl+3).SIGNAL(maxC)];
    T3CDC = [T3CDC; data(icl+5).SIGNAL(maxC)];
    T4CDC = [T4CDC; data(icl+7).SIGNAL(maxC)];
    T1CDV = [T1CDV; data(icl+1).SIGNAL(maxV)];
    T2CDV = [T2CDV; data(icl+3).SIGNAL(maxV)];
    T3CDV = [T3CDV; data(icl+5).SIGNAL(maxV)];
    T4CDV = [T4CDV; data(icl+7).SIGNAL(maxV)];
end
%write to table
tab = table(T1CLC, T2CLC, T3CLC, T4CLC, T1CLV, T2CLV, T3CLV, T4CLV, ...
    T1CDC, T2CDC, T3CDC, T4CDC, T1CDV, T2CDV, T3CDV, T4CDV, ...
    'VariableNames', {'T1_CLC', 'T2_CLC', 'T3_CLC', 'T4_CLC', 'T1_CLV', ...
    'T2_CLV', 'T3_CLV', 'T4_CLV', 'T1_CDC', 'T2_CDC', 'T3_CDC', ...
    'T4_CDC', 'T1_CDV', 'T2_CDV', 'T3_CDV', 'T4_CDV'});
full = [datacsv, tab];
writetable(full, filename);
out = full;
