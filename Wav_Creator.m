function Wav_Creator(dirname);

%Function to create scaled .wav files from .mat files that contain audio
%data and audio sampling rate 
%Set up to work with structures in which there are fields NAME, SRATE and
%SIGNAL and in which NAME contains a value AUDIO that corresponds to the
%row of the struct that the audio data is stored in.
%
%No output variable in matlab; instead, scaled .wav files are created in
%the active directory
%
%Sarah Harper 11/2018

%If already in the directory, can use dirname = pwd to get the directory
%path
cd(dirname);

%Get a list of all .mat files in the directory
fileList = dir ('*.mat');

for i = 1:length(fileList),
    matname = fileList(i).name; %get the name of the mat file
    [~, fname, ext] = fileparts(matname);
    wavname = strcat(fname, '_scaled.wav'); %change if different name desired for output .wav files
    if exist(wavname, 'file') == 0, %checking if scaled .wav file corresponding to .mat file already exists in directory
       dat = load(matname, fname);
       matdat = dat.(fname);
       %Following three lines get the raw audio data and the sampling rate
       %from the .mat file
       index = find(strcmp({matdat.NAME}, 'AUDIO')==1);
       audio_raw = matdat(index).SIGNAL;
       sr = matdat(index).SRATE;
       %Scale the audio (currently set up to scale to bit depth of 16 bits)
       audio_scale = 2*(audio_raw-min(audio_raw))/(max(audio_raw)-min(audio_raw))-1;
       audiowrite(wavname, audio_scale, sr);
    end
end