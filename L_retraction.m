function out = L_retraction(filename);
%Measure retraction of T1 (TT) and T3 (TD) by calculating distance from 
%pharynx at time of gestural onset and maximum
%
%Input: filename of .csv file containing output from LAnalysis.m
%Output: .csv file that contains output of LAnalysis.m plus retraction
%distances

T1CLC = [];
T2CLC = [];
T3CLC = [];
T4CLC = [];
T1CLV = [];
T2CLV = [];
T3CLV = [];
T4CLV = [];
T1CRC = [];
T2CRC = [];
T3CRC = [];
T4CRC = [];
T1CRV = [];
T2CRV = [];
T3CRV = [];
T4CRV = [];
T1GRC = [];
T3GRC = [];
T1GRV = [];
T3GRV = [];
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
    %Get constriction degree (distance from pharynx) for each sensor for both timepoints
    T1CRC = [T1CRC; data(icl+1).SIGNAL(maxC)];
    T3CRC = [T3CRC; data(icl+5).SIGNAL(maxC)];
    T1CRV = [T1CRV; data(icl+1).SIGNAL(maxV)];
    T3CRV = [T3CRV; data(icl+5).SIGNAL(maxV)];
    T1GRC = [T1GRC; data(icl+1).SIGNAL(GmaxC)];
    T3GRC = [T3GRC; data(icl+5).SIGNAL(GmaxC)];
    T1GRV = [T1GRV; data(icl+1).SIGNAL(GmaxV)];
    T3GRV = [T3GRV; data(icl+5).SIGNAL(GmaxV)];
    frm_C = [frm_C; maxC];
    frm_V = [frm_V; maxC];
end
%write to table
tab = table(T1GRC, T3GRC, T1GRV, T3GRV, T1CRC, T3CRC, T1CRV, T3CRV, ...
    'VariableNames', {'T1_GRC', 'T3_GRC', 'T1_GRV', 'T3_GRV', 'T1_CRC',...
    'T3_CRC', 'T1_CRV', 'T3_CRV'});
full = [datacsv, tab];
writetable(full, filename);
out = full;
