

function out = LAnalysis(filename)

subj = [];
tsk = [];
phone = [];
word = [];
frm = [];
ms = [];
prev=[];
foll = [];
t1xC = [];
t1yC = [];
t1xV = [];
t1yV = [];
t3xC = [];
t3yC = [];
t3xV = [];
t3yV = [];
r1C = [];
r1V = [];
lag = [];
r3C = [];
r3V = [];
a13C = [];
a13V = [];
gest = [];
F1C = [];
F2C = [];
F3C = [];
F1V = [];
F2V = [];
F3V = [];
F2F1C = [];
F2F1V = [];


data = readtable(filename);

for i = 1 : length(data.SUBJ),
    if isequal(data.SENSOR(i),{'T1'}),
       j = i+3;
       %Calculate retraction (distance between T1x and MNIx)
       %retr = sqrt((data.MNIx(i)-data.T1x(i))^2 + (data.MNIy(i)-dataT1y(1))^2);
       if data.GEST(i) == 2 && data.GEST(j) ==2,
       r1C = [r1C; abs(data.MNIx(i)-data.T1x(i))];
       r3C = [r3C; abs(data.MNIx(i)-data.T3x(i))];
       r1V = [r1V; abs(data.MNIx(j)-data.T1x(j))];
       r3V = [r3V; abs(data.MNIx(j)-data.T3x(j))];
       %Calculate lag between T1 and T3 MAXC 
       timC = data.TIME_ms(i);
       timV = data.TIME_ms(j);
       lagCV = timC - timV;
       lag = [lag; lagCV];
       %Calculate angles (inverse tang of y-diff/x-diff)
       a13C = [a13C; atan((data.T3y(i)-data.T1y(i))/(data.T3x(i)-data.T1x(i)))];
       a13V = [a13V; atan((data.T3y(j)-data.T1y(j))/(data.T3x(j)-data.T1x(j)))];
       %Get additional info from data file
       subj = [subj; data.SUBJ(i)];
       tsk = [tsk; data.TASK(i)];
       phone = [phone; data.PHONE(i)];
       word = [word; data.WORD(i)];
       frm = [frm; data.TIME_frame(i)];
       ms = [ms; data.TIME_ms(i)];
       prev=[prev; data.PREV_PHONE(i)];
       foll = [foll; data.FOLL_PHONE(i)];
       t1xC = [t1xC; data.T1x(i)];
       t1yC = [t1yC; data.T1y(i)];
       t1xV = [t1xV; data.T1x(j)];
       t1yV = [t1yV; data.T1y(j)];
       t3xC = [t3xC; data.T3x(i)];
       t3yC = [t3yC; data.T3y(i)];
       t3xV = [t3xV; data.T3x(j)];
       t3yV = [t3yV; data.T3y(j)]; 
       gest = [gest; data.GEST(i)];
       
       %Get F1-F3 for token
       fn = sprintf('%s_%s',char(data.SUBJ(i)),char(data.TASK(i)));
       wavname = strcat(fn, '_scaled.wav');
       if exist(wavname, 'file'),
           dir = which(wavname);
           dir = dir(1:end-numel(wavname));
           cd(dir);
       else
           matname = strcat(fn, '.mat');
           matdat = load(matname);
           dir = which(matname);
           dir = dir(1:end-numel(matname));
           cd(dir);
           audio_raw = matdat(1).SIGNAL;
           sr = matdat(1).SRATE;
           audio_scale = 2*(audio_raw-min(audio_raw))/(max(audio_raw)-min(audio_raw))-1;;
           audiowrite(wavname, audio_scale, sr);
       end
       [fmnts, step, skips] = PraatFmts(wavname);
       if isempty(fmnts),
        F1C = [F1C; NaN];
        F2C = [F2C; NaN];
        F3C = [F3C; NaN];
        F1V = [F1V; NaN];
        F2V = [F2V; NaN];
        F3V = [F3V; NaN];
        F2F1C = [F2F1C; NaN];
        F2F1V = [F2F1V; NaN];
       else
%        else
%        if gender == 1
%        fmnts = PraatFmts(wavname);
%        else
%        fmnts = PraatFmts(fn, 1);
%        end
    %   Isolate each of the formants of interest for each MAXC
              [~, sr] = audioread(wavname);
       timC_fmts = round((timC/step))-skips;
       timV_fmts = round((timV/step))-skips;
       F1C = [F1C; fmnts(timC_fmts, 1)];
       F2C = [F2C; fmnts(timC_fmts, 2)];
       F3C = [F3C; fmnts(timC_fmts, 3)];
       F1V = [F1V; fmnts(timV_fmts, 1)];
       F2V = [F2V; fmnts(timV_fmts, 2)];
       F3V = [F3V; fmnts(timV_fmts, 3)];
       %Calculate F2-F1 difference
       Cdiff = fmnts(timC_fmts, 2) - fmnts(timC_fmts,1);
       Vdiff = fmnts(timV_fmts, 2) - fmnts(timV_fmts,1);
       F2F1C = [F2F1C; Cdiff];
       F2F1V = [F2F1V; Vdiff];
       end
       end
    end
end
    
    %write to table
tab = table(subj, tsk, phone, word, frm, ms, prev, foll, t1xC, t1yC, ...
    t3xC, t3yC, t1xV, t1yV, t3xV, t3yV, r1C , r3C, r1V, r3V, a13C, ...
    a13V, lag, F1C, F2C, F3C, F2F1C, F1V, F2V, F3V, F2F1V, gest, ...
    'VariableNames', {'SUBJ', 'TASK', 'PHONE','WORD', 'TIME_frame_C', ...
    'TIME_ms_C', 'PREV_PHONE', 'FOLL_PHONE','T1x_C','T1y_C', 'T3x_C', ...
    'T3y_C', 'T1x_V', 'T1y_V', 'T3x_V', 'T3y_V','T1_retr_C',  ...
    'T3_retr_C', 'T1_retr_V','T3_retr_V','Angle_13_C','Angle_13_V', ...
    'MAXC_Lag', 'F1_C', 'F2_C', 'F3_C', 'F2F1_C', 'F1_V', 'F2_V',...
    'F3_V', 'F2F1_V','GEST'});
[~, fname] = fileparts(filename);
writetable(tab, strcat(fname, '_calculations_T4.csv'));
out = tab;

     
% for si = 1 : length(subj), %cycle through rows by subject
%     rows = strcmp(cellstr(data.SUBJ),subj); 
%     for ro = 1:length(rows),
%         if rows(ro,1) == 1,
%             
%         end
%     end
