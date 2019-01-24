function out = L_constriction_retraction(filename);
%Gets distance of pellets of interest (set up here for T1 and T3) from pharyngeal
%wall (using script TTCD_CL) and calculates 

%Create vectors to which data will be added in loop
T1MC = [];
T3MC = [];
T1MV = [];
T3MV = [];
T1GC = [];
T3GC = [];
T1GV = [];
T3GV = [];
frm_C = [];
frm_V = [];

datacsv = readtable(filename);
for i = 1:length(datacsv.SUBJ);
    fn = sprintf('%s_%s', char(datacsv.SUBJ(i)),char(datacsv.TASK(i)));
    try,
        datamat = LoadMAT(fullfile('mat',fn),fn);
        %Get approximation of pharynx from mat file
        phar = LoadMAT(fullfile('mat',fn),'phar');
        %Get distance of sensors from pharynx using TTCD_CL
        data = TTCD_CL(datamat,phar);
    catch,
        fprintf('error attempting to load mat/%s (skipped)\n',fn);
        continue;
    end;
    %Get times of TT and TD constriction maxima
    timC = datacsv.Time_ms_C(i);
    timV = datacsv.Time_ms_V(i);
    %Get times of TT and TD constriction onset
    GtimC = datacsv.GONS_time_ms_C(i);
    GtimV = datacsv.GONS_time_ms_V(i);
    %Convert times (in ms) to frames
    maxC = floor(timC*datamat(5).SRATE/1000);
    maxV = floor(timV*datamat(5).SRATE/1000);
    GmaxC = floor(GtimC*datamat(5).SRATE/1000);
    GmaxV = floor(GtimV*datamat(5).SRATE/1000);
    %Find row of struct where NAME value is T1CL
    icl = find(strcmp({data.NAME}, 'T1CL')==1);
    %Get constriction degree (distance from pharynx) for each sensor at
    %gesture onset & maximum for TT and TD gestures
    T1MC = [T1MC; data(icl+1).SIGNAL(maxC)];
    T3MC = [T3MC; data(icl+5).SIGNAL(maxC)];
    T1MV = [T1MV; data(icl+1).SIGNAL(maxV)];
    T3MV = [T3MV; data(icl+5).SIGNAL(maxV)];
    T1GC = [T1GC; data(icl+1).SIGNAL(GmaxC)];
    T3GC = [T3GC; data(icl+5).SIGNAL(GmaxC)];
    T1GV = [T1GV; data(icl+1).SIGNAL(GmaxV)];
    T3GV = [T3GV; data(icl+5).SIGNAL(GmaxV)];
    frm_C = [frm_C; maxC];
    frm_V = [frm_V; maxC];
end
%Calculate retraction as difference in distance between onset and
%maximum of each gesture for each sensor
T1RC = T1GC - T1MC;
T1RV = T1GV - T1MV;
T3RC = T3GC - T3MC;
T3RV = T3GV - T3MV;
%write to table
tab = table(T1GC, T3GC, T1GV, T3GV, T1MC, T3MC, T1MV, T3MV, T1RC, T1RV, ...
    T3RC, T3RV, 'VariableNames', {'T1_GRC', 'T3_GRC', 'T1_GRV', 'T3_GRV',...
    'T1_GC', 'T3_GC', 'T1_GV', 'T3_GV', 'T1_MC', 'T3_MC', 'T1_MV','T3_MV',...
    'T1_RC', 'T1_RV', 'T3_RC', 'T3_RV'});
full = [datacsv, tab];
writetable(full, filename);
out = full;
