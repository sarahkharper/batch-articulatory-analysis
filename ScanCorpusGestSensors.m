function out = ScanCorpusGestSensors(phone, subj, task)
%SCANCORPUSGEST  - scan x-ray microbeam data for pellet positions at
%gestural landmarks for desired phones using acoustically aligned labels
%and return x/y coordinates of ALL pellets at measure time points
%
%	usage:  p = ScanCorpus(phone, subj, task)
%
% finds each instance of PHONE within each SUBJ:TASK combination, calls
% DelimitGestXRMB to calculate gestural landmarks for desired PELLETs for
% each instance of PHONE, and returns a struct with information on each
% token, including the x/y coordinates of ALL pellet(s) in the data at the time of
% maximum constriction
%
% SUBJ is a cellstr list of talker IDs (e.g. {'JW11','JW13'})
% TASK is a cellstr list listener tasks (e.g. {'TP011','TP017'})
%
% assumes LABELS and MAT subdirectories available within CWD
%
% returns struct (each row = 1 token) with fields:
% SUBJ = talker ID for token
% TASK = task token taken from
% PHONE = phone of token
% WORD = word that token was taken from
% SENSOR = ID of sensor measured (e.g. {'T1', 'T2'})
% TIME_ms = time of MAXC in milliseconds
% TIME_frame = frame where MAXC measured
% X_POS = position of sensor on X axis
% Y_POS = position of sensor on Y axis
% PREV_PHONE = phone preceding measured token
% FOLL_PHONE = phone following measured token
% GEST = whether or not DelimitGest returned gestural landmarks. 1 =
% DelimitGest failure, 2 = DelimitGest success. If 1, indicates sensor
% malfunction (at least as far as I can tell - does not return x/y
% position)
%
% Pellet numbers (use in line 94 to change which pellets are measured):
% 3 = UL, 4 = LL, 5 = T1, 6 = T2, 7 = T3, 8 = T4, 9 = MNI, 10 = MNM

% modified from mkt function ScanCorpus by Sarah Harper 10/18

if nargin < 3,
	eval('help ScanCorpus');
	return;
end;
if ~iscellstr(subj), subj = {subj}; end;
if ~iscellstr(task), task = {task}; end;
phone = upper(phone);

idx = 1;				% into p

sbj = [];               % setting up future variables in struct
tsk = [];
phn = [];
wrd = [];
snsr = [];
xps = [];
yps = [];
prv = [];
fll = [];
gst = [];
mxf = [];
mxt = [];
ULx = [];
ULy = [];
LLx = [];
LLy = [];
T1x = [];
T1y = [];
T2x = [];
T2y = [];
T3x = [];
T3y = [];
T4x = [];
T4y = [];
MNIx = [];
MNIy = [];
MNMx = [];
MNMy = [];
T = [];

for si = 1 : length(subj),
	for ti = 1 : length(task),
% load data
		fn = sprintf('%s_%s',subj{si},task{ti});
		ln = sprintf('labels_task%s',task{ti}(3:5));
		try,
			data = LoadMAT(fullfile('mat',fn),fn);
		catch,
			fprintf('error attempting to load mat/%s (skipped)\n', fn);
			continue;
		end;
		try,
			labels = LoadMAT(fullfile('labels',ln),[fn,'_lbl']);
		catch,
			
			continue;
		end;

% match phones
		kk = strmatch(phone,{labels.NAME},'exact');
        wordlist = strmatch('word',{labels.HOOK},'exact');
		if isempty(kk), continue; end;
		
% get sensor positions
		for ki = 1 : length(kk),
            t = labels(kk(ki)).OFFSET;		% mean of labelled range (see VALUE)
            for w = 1 : length(wordlist),   %get the word the instance of the phoneme is from
                r = wordlist(w);
                begin = labels(r).VALUE(1); %get acoustically determined start and end point of segment
                ends = labels(r).VALUE(2);
                if t > begin && t < ends,
%                 if t > labels(w).VALUE(1) && t < labels(w).VALUE(2),
                    word = labels(r).NAME;
                end
            end
			for di = 4, %change this depending on which sensor(s) you want to analyze (will eventually be changed to be argument to function)
                s = data(di).SIGNAL; %get position signal for that sensor
                lims = labels(kk(ki)).VALUE; 
				k = floor(t*data(di).SRATE/1000)+1; % calculating sample in data corresponding to time of midpoint
                if k > length(s); %just making it so the script doesn't crash if mismatch between acoustic and articulatory samples
                        continue;
                    end
                ht = floor(lims*data(di).SRATE/1000)+1; %samples corresponding to times of onset and offset of segment in data
                % Set GONS/OFFS and NONS/OFFS velocity thresholds (default
                % to +/-10%
                threshg = 0.1;
                threshn = 0.1;
                %Run DelimitGestXRMB
                [g,v] = DelimitGestXRMB(s,k,ht,'THRGONS', threshg, ...
                    'THRNONS', threshn, 'THRNOFF', threshn, 'THRGOFF',...
                    threshg, 'ONSTHR', threshg, 'OFFSTHR', threshg);
                if isempty(g);  % if DelimitGest fails to find a gesture, take sensor positions at acoustic midpoint
                    %p(di-4,:,idx) = data(di).SIGNAL(k,:);
                    ULx = [ULx; data(3).SIGNAL(k,1)];
                    ULy = [ULy; data(3).SIGNAL(k,2)];
                    LLx = [LLx; data(4).SIGNAL(k,1)];
                    LLy = [LLy; data(4).SIGNAL(k,2)];
                    T1x = [T1x; data(5).SIGNAL(k,1)];
                    T1y = [T1y; data(5).SIGNAL(k,2)];
                    T2x = [T2x; data(6).SIGNAL(k,1)];
                    T2y = [T2y; data(6).SIGNAL(k,2)];
                    T3x = [T3x; data(7).SIGNAL(k,1)];
                    T3y = [T3y; data(7).SIGNAL(k,2)];
                    T4x = [T4x; data(8).SIGNAL(k,1)];
                    T4y = [T4y; data(8).SIGNAL(k,2)];
                    MNIx = [MNIx; data(9).SIGNAL(k,1)];
                    MNIy = [MNIy; data(9).SIGNAL(k,2)];
                    MNMx = [MNMx; data(10).SIGNAL(k,1)];
                    MNMy = [MNMy; data(10).SIGNAL(k,2)];
                    gst = [gst ; 1];
                    mxt = [mxt ; t];
                    mxf = [mxf ; k];
                    T = [T; t];
                    %gst = [gst ; 0];
                else    %get sensor positions at time of MAXC found by DelimitGest
                    MAXC = g.MAXC;
                    mxf = [mxf ; MAXC];
                    mxt = [mxt ; (MAXC/data(di).SRATE*1000)];
                    try,
                        %p(di-4,:,idx) = data(di).SIGNAL(MAXC,:);
                        ULx = [ULx; data(3).SIGNAL(MAXC,1)];
                        ULy = [ULy; data(3).SIGNAL(MAXC,2)];
                        LLx = [LLx; data(4).SIGNAL(MAXC,1)];
                        LLy = [LLy; data(4).SIGNAL(MAXC,2)];
                        T1x = [T1x; data(5).SIGNAL(MAXC,1)];
                        T1y = [T1y; data(5).SIGNAL(MAXC,2)];
                        T2x = [T2x; data(6).SIGNAL(MAXC,1)];
                        T2y = [T2y; data(6).SIGNAL(MAXC,2)];
                        T3x = [T3x; data(7).SIGNAL(MAXC,1)];
                        T3y = [T3y; data(7).SIGNAL(MAXC,2)];
                        T4x = [T4x; data(8).SIGNAL(MAXC,1)];
                        T4y = [T4y; data(8).SIGNAL(MAXC,2)];
                        MNIx = [MNIx; data(9).SIGNAL(MAXC,1)];
                        MNIy = [MNIy; data(9).SIGNAL(MAXC,2)];
                        MNMx = [MNMx; data(10).SIGNAL(MAXC,1)];
                        MNMy = [MNMy; data(10).SIGNAL(MAXC,2)];
                        gst = [gst ; 2];
                        T = [T; t];
                    catch,
                        fprintf('in %s : %s : %s\n %s\n', subj{si}, task{ti}, data(di).NAME, lasterr);
					continue;
                    end;
                end;
                %Now get metadata about the segment and add to output
                %arrays
                sbj = [sbj; subj{si}];
                tsk = [tsk ; task{ti}];
                phn = [phn ; phone];
                wrd = [char(wrd, word)];
                snsr = [char(snsr,data(di).NAME)];
                h = kk(ki)-1;
                while strcmp(labels(h).HOOK,'phone') == 0; %Find immediately preceding label with 'phone' (instead of 'word') identifier
                    h = h - 1;
                end
                prv = [char(prv,labels(h).NAME)];
                if kk(ki) < length(labels),
                    o = kk(ki)+1;
                    while strcmp(labels(o).HOOK,'phone') == 0; %Find immediately following label with 'phone' (instead of 'word') identifier
                        o = o + 1;
                    end
                    fll = [char(fll , labels(kk(ki)+1).NAME)];
                else
                    fll = [char(fll, 'end')];
                end
             end; 
		end;
	idx = idx + 1;
	end;  
end;
wrd = wrd([2:end],:);
snsr = snsr([2:end],:);
prv = prv([2:end],:);
fll = fll([2:end],:);
%Create output table
tab = table(sbj, tsk, phn, wrd, snsr, mxt, mxf, prv, fll, ...
         ULx, ULy, LLx, LLy, T1x, T1y, T2x, T2y, T3x, T3y, T4x, T4y, MNIx, MNIy, ...
         MNMx, MNMy, gst, T, 'VariableNames', {'SUBJ', 'TASK', 'PHONE', ...
         'WORD', 'SENSOR','TIME_ms', 'TIME_frame', 'PREV_PHONE', ...
          'FOLL_PHONE', 'ULx', 'ULy', 'LLx', 'LLy', 'T1x', 'T1y', ...
          'T2x', 'T2y', 'T3x', 'T3y', 'T4x', 'T4y', 'MNIx', 'MNIy', ...
          'MNMx', 'MNMy', 'GEST', 'MID'});
    if length(subj) > 1, %if analyzing more than one speaker, generic identifier
        fname = 'speakers_';
    else
        fname = strcat(subj{si}, '_');
    end
    writetable(tab, strcat(fname, phone)); %save table to file with speaker + phone as name
    out = table2struct(tab);
    fprintf('processed %s\n', subj{si});

%if ~isempty(p), p = permute(p,[3 2 1]); end;
