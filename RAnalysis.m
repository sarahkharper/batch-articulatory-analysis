

function out = RAnalysis(filename)

subj = [];
tsk = [];
phone = [];
word = [];
frm_c = [];
ms_c = [];
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
F1C = [];
F2C = [];
F3C = [];
F4C = [];
F5C = [];
F1V = [];
F2V = [];
F4V = [];
F5V = [];
F1Mid = [];
F2Mid = [];
F3Mid = [];
F4Mid = [];
F5Mid = [];
F5F4C = [];
F5F4V = [];
F5F4M = [];
F4F3V = [];
F4F3C = [];
F4F3M = [];
ms_v =[];
fr_v = [];
sensor = [];


data = readtable(filename);

for i = 1 : length(data.SUBJ),
    if isequal(data.SENSOR(i), {'T1'}),
    fn = sprintf('%s_%s',char(data.SUBJ(i)),char(data.TASK(i)));
    try,
        datamat = LoadMAT(fullfile('mat',fn),fn);
        pal = LoadMAT(fullfile('mat',fn),'pal');
        dataCD = TTCD_CL(datamat,pal);
    catch,
        fprintf('error attempting to load mat/%s (skipped)\n',fn);
         continue;
    end;
    icl = find(strcmp({dataCD.NAME}, 'T1CL')==1);
    T1CDC = dataCD(icl+1).SIGNAL(data.TIME_frame(i));
    T2CDC = dataCD(icl+3).SIGNAL(data.TIME_frame(i+1));
    T3CDC = dataCD(icl+5).SIGNAL(data.TIME_frame(i+2));
    if T1CDC < T2CDC && T1CDC < T3CDC,
        sens = 'T1';
        j = i+3;
        t = i;
        yn = strcat(sens,'y');
        xn = strcat(sens,'x');
        x = find(strcmp(data.Properties.VariableNames, xn)==1);
        y = find(strcmp(data.Properties.VariableNames, yn)==1);
    elseif T2CDC < T1CDC && T2CDC < T3CDC,
        sens = 'T2';
        j = i+2;
        t = i+1;
        yn = strcat(sens,'y');
        xn = strcat(sens,'x');
        x = find(strcmp(data.Properties.VariableNames, xn)==1);
        y = find(strcmp(data.Properties.VariableNames, yn)==1);
    else
        sens = 'T3';
        j = i+1;
        t = i+2;
        yn = strcat(sens,'y');
        xn = strcat(sens,'x');
        x = find(strcmp(data.Properties.VariableNames, xn)==1);
        y = find(strcmp(data.Properties.VariableNames, yn)==1);
    end
       %Calculate retraction (distance between T1x and MNIx)
       %retr = sqrt((data.MNIx(i)-data.T1x(i))^2 + (data.MNIy(i)-dataT1y(1))^2);
       if data.GEST(t) == 2 && data.GEST(j) ==2,
       r1C = [r1C; abs(data.MNIx(t)-data{t,x})];
       r3C = [r3C; abs(data.MNIx(t)-data.T4x(t))];
       r1V = [r1V; abs(data.MNIx(j)-data{j,x})];
       r3V = [r3V; abs(data.MNIx(j)-data.T4x(j))];
       %Calculate lag between T1 and T3 MAXC 
       timC = data.TIME_ms(t);
       timV = data.TIME_ms(j);
       lag = [lag; timC - timV];
       %Calculate angles (inverse tang of y-diff/x-diff)
       a13C = [a13C; atan((data.T4y(t)-data{t,y})/(data.T4x(t)-data{t,y}))];
       a13V = [a13V; atan((data.T4y(j)-data{j,y})/(data.T4x(j)-data{j,y}))];
       %Get additional info from data file
       subj = [subj; data.SUBJ(t)];
       tsk = [tsk; data.TASK(t)];
       phone = [phone; data.PHONE(t)];
       word = [word; data.WORD(t)];
       frm_c = [frm_c; data.TIME_frame(t)];
       ms_c = [ms_c; data.TIME_ms(t)];
       fr_v = [fr_v; data.TIME_frame(j)];
       ms_v = [ms_v; data.TIME_ms(j)];
       prev=[prev; data.PREV_PHONE(t)];
       foll = [foll; data.FOLL_PHONE(t)];
       t1xC = [t1xC; data{t,x}];
       t1yC = [t1yC; data{t,y}];
       t1xV = [t1xV; data{j,x}];
       t1yV = [t1yV; data{j,y}];
       t3xC = [t3xC; data.T4x(t)];
       t3yC = [t3yC; data.T4y(t)];
       t3xV = [t3xV; data.T4x(j)];
       t3yV = [t3yV; data.T4y(j)]; 
       gest = [gest; data.GEST(t)];
       sensor = [sensor; sens];
       
%      Get F1-F3 for token
       wavname = strcat(fn, '_scaled.wav');
       if exist(wavname, 'file'),
           dir = which(wavname);
           dir = dir(1:end-numel(wavname));
           cd(dir);
       else
           matname = strcat(fn, '.mat');
           matdat = LoadMAT(fullfile('mat',fn),fn);
           dir = which(matname);
           dir = dir(1:end-numel(matname));
           cd(dir);
           audio_raw = matdat(1).SIGNAL;
           sr = matdat(1).SRATE;
           audio_scale = 2*(audio_raw-min(audio_raw))/(max(audio_raw)-min(audio_raw))-1;
           audiowrite(wavname, audio_scale, sr);
       end
       timCround = timC*10^-3;
       timVround = timV*10^-3;
       timMround = data.MID(t)*10^-3;
       [fmnts] = PraatFmts(wavname, timCround, timVround, timMround, 0);
       if isempty(fmnts),
        F1C = [F1C; NaN];
        F2C = [F2C; NaN];
        F3C = [F3C; NaN];
        F4C = [F4C; NaN];
        F5C = [F5C; NaN];
%         F4C = [F4C; NaN];
%         F5C = [F5C; NaN];
        F1V = [F1V; NaN];
        F2V = [F2V; NaN];
        F3V = [F3V; NaN];
        F4V = [F4V; NaN];
        F5V = [F5V; NaN];
        F1Mid = [F1Mid; NaN];
        F2Mid = [F2Mid; NaN];
        F3Mid = [F3Mid; NaN];
        F4Mid = [F4Mid; NaN];
        F5Mid = [F5Mid; NaN];
%         F4V = [F4V; NaN];
%         F5V = [F5V; NaN];
%         F5F4C = [F5F4C; NaN];
%         F5F4V = [F5F4V; NaN];
%         F4F3V = [F4F3V; NaN];
%         F4F3C = [F4F3C; NaN];
       else
% %        if gender == 1
% %        fmnt_ts = PraatFmts(wavname);
% %        else
% %         fmnt_ts = PraatFmts(fn, 1);
% %        end
       %Isolate each of the formants of interest for each MAXC
       [~, sr] = audioread(wavname);
%        timC_fmts = round(((timC)/step))-skips;
%        timV_fmts = round(((timV)/step))-skips;
%        mid_fmt = round(((data.MID(t))/step))-skips;
%        if timC_fmts > length(fmnts) && timV_fmts > length(fmnts),
%            F1C = [F1C; NaN];
%            F2C = [F2C; NaN];
%            F3C = [F3C; NaN];
%            F1V = [F1V; NaN];
%            F2V = [F2V; NaN];
%            F3V = [F3V; NaN];
%            F1Mid = [F1Mid; fmnts(mid_fmt, 1)];
%            F2Mid = [F2Mid; fmnts(mid_fmt, 2)];
%            F3Mid = [F3Mid; fmnts(mid_fmt, 3)];
%        continue; end;
%        if timC_fmts > length(fmnts),
%            F1C = [F1C; NaN];
%            F2C = [F2C; NaN];
%            F3C = [F3C; NaN];
%            F1V = [F1V; fmnts(timV_fmts, 1)];
%            F2V = [F2V; fmnts(timV_fmts, 2)];
%            F3V = [F3V; fmnts(timV_fmts, 3)];
%            F1Mid = [F1Mid; fmnts(mid_fmt, 1)];
%            F2Mid = [F2Mid; fmnts(mid_fmt, 2)];
%            F3Mid = [F3Mid; fmnts(mid_fmt, 3)];
%        continue; end;
%        if timV_fmts > length(fmnts),
%            F1C = [F1C; fmnts(timC_fmts, 1)];
%            F2C = [F2C; fmnts(timC_fmts, 2)];
%            F3C = [F3C; fmnts(timC_fmts, 3)];
%            F1V = [F1V; NaN];
%            F2V = [F2V; NaN];
%            F3V = [F3V; NaN];
%            F1Mid = [F1Mid; fmnts(mid_fmt, 1)];
%            F2Mid = [F2Mid; fmnts(mid_fmt, 2)];
%            F3Mid = [F3Mid; fmnts(mid_fmt, 3)];
%        continue;end;
%        if length(fmnts) < 15,
%            for f = length(fmnts):15,
%                fmnts(f) = 0;
%            end
%        end
       F1C = [F1C; fmnts(1)];
       F2C = [F2C; fmnts(2)];
       F3C = [F3C; fmnts(3)];
       F4C = [F4C; fmnts(4)];
       F5C = [F5C; fmnts(5)];
%        F4C = [F4C; fmnts(timC_fmts, 4)];
%        F5C = [F5C; fmnts(timC_fmts, 5)];
       F1V = [F1V; fmnts(6)];
       F2V = [F2V; fmnts(7)];
       F3V = [F3V; fmnts(8)];
       F4V = [F4V; fmnts(9)];
       F5V = [F5V; fmnts(10)];
       F1Mid = [F1Mid; fmnts(11)];
       F2Mid = [F2Mid; fmnts(12)];
       F3Mid = [F3Mid; fmnts(13)];
       F4Mid = [F4Mid; fmnts(14)];
       F5Mid = [F5Mid; fmnts(15)];
%        F4V = [F4V; fmnts(timC_fmts, 4)];
%        F5V = [F5V; fmnts(timC_fmts, 5)];
      %Calculate formant differences
      Cdiff45 = fmnts(5) - fmnts(4);
      Vdiff45 = fmnts(10) - fmnts(9);
      Mdiff45 = fmnts(15) - fmnts(14);
      Cdiff34 = fmnts(4) - fmnts(3);
      Vdiff34 = fmnts(9) - fmnts(8);
      Mdiff34 = fmnts(14) - fmnts(13);
      F5F4C = [F5F4C; Cdiff45];
      F5F4V = [F5F4V; Vdiff45];
      F5F4M = [F5F4M; Mdiff45];
      F4F3M = [F4F3M; Mdiff34];
      F4F3C = [F4F3C; Cdiff34];
      F4F3V = [F4F3V; Vdiff34];
      end
        end
     end
 end
    
    %write to table
tab = table(subj, tsk, sensor, phone, word, frm_c, ms_c, fr_v, ms_v, prev, foll, t1xC, t1yC, ...
    t3xC, t3yC, t1xV, t1yV, t3xV, t3yV, r1C , r3C, r1V, r3V, a13C, ...
    a13V, lag, F1C, F2C, F3C, F4C, F5C, F1V, F2V, F3V, F4V, F5V, F1Mid, F2Mid, F3Mid, F4Mid, F5Mid,...
    F4F3C, F4F3V, F4F3M, F5F4C, F5F4V, F5F4M,gest, ...
    'VariableNames', {'SUBJ', 'TASK', 'SENSOR','PHONE','WORD', 'TIME_frame_C', ...
    'TIME_ms_C', 'TIME_frame_V', 'TIME_ms_V','PREV_PHONE', 'FOLL_PHONE','T1x_C','T1y_C', 'T3x_C', ...
    'T3y_C', 'T1x_V', 'T1y_V', 'T3x_V', 'T3y_V','T1_retr_C',  ...
    'T3_retr_C', 'T1_retr_V','T3_retr_V','Angle_13_C','Angle_13_V', ...
    'MAXC_Lag', 'F1C', 'F2C','F3C', 'F4C', 'F5C', 'F1V', 'F2V', 'F3V', 'F4V', ...
    'F5V', 'F1M', 'F2M', 'F3M', 'F4M', 'F5M', 'F4F3C', 'F4F3V', 'F4F3M', ...
    'F5F4C', 'F5F4V', 'F5F4M','GEST'});
[~, fname] = fileparts(filename);
writetable(tab, strcat(fname, '_calculations.csv'));
out = tab;

     
% for si = 1 : length(subj), %cycle through rows by subject
%     rows = strcmp(cellstr(data.SUBJ),subj); 
%     for ro = 1:length(rows),
%         if rows(ro,1) == 1,
%             
%         end
%     end
