%% Code Start

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name: ECE_2312_Project2_Mithil_Amin
% By: Mithil Amin, WPI'25, ECE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Section End

%% Setting the stage
clear all
clc

% Section End

%% Variables
Fs = 44000;
nBits = 8;
nChannels = 1;
ID = 0;
recDuration = 5;
Freq = 5000;

%      >> Variable Info <<
% 
% Fs          = stores the initial sampling rate for this program
% nBits       = bitrate
% nChannels   = number of channels
% ID          = device identifier
% recDuration = duration for recording
% Freq = Frequency to produce the sine tone at

% Section End

%% Lines

line= "The quick brown fox jumps over the lazy dog";
L = "The quick brown fox jumps over the lazy dog.wav";
L_sine = "team[]-sinetone.wav";
L_chirp = "time[]-chirp.wav";
L_CETK = "team[]-cetk.wav";
L_speechchirp = "team[]-speechchirp.wav";
L_filter = "team[]-filteredspeechsine.wav";
L_stereo = "team[]-stereospeechsine.wav";

% Section End

%% Sine Tone

% Lets make the sine tone

sps = 1/Fs; % sps = Seconds per sample
T = (0:sps:recDuration);
F = 5000;

sine_tone = sin(2*pi*F*T);

figure(1)
grid on;
spectrogram(sine_tone, 256, [], [], Fs, 'yaxis');
title("Spectrogram of Sine Tone")
xlabel("Time")
ylabel("Frequency")
grid off;

sound(sine_tone, Fs, nBits);
pause(6)

% Storing the Sine Tone in WAV File
audiowrite(L_sine, sine_tone, Fs);

% Section EndLINE

%% Chirp Signal

F_Start = 0;
F_End = 8000;

chirp_sine_tone = chirp(T, F_Start, recDuration, F_End);

figure(2)
grid on;
spectrogram(chirp_sine_tone, 256, [], [], Fs, 'yaxis');
title("Spectrogram of Chirp Signal")
xlabel("Time")
ylabel("Frequency")
grid off;

sound(chirp_sine_tone, Fs, nBits);
pause(6)

% Storing the Chirp Signal in WAV File
audiowrite(L_chirp, chirp_sine_tone, Fs);

% Section End

%% Sine Tone CETK

% Duration for each tone in seconds
duration = [0.3, 0.7, 1.1, 0.5, 2.2];
% These values are approximates. NOTE: I was unable to produce the electric
% piano like sound as heard in the youtube video
Freq_CETK = [750, 830, 700, 480, 560];

sine_tone_CETK = [];

clear T;

i=1;
for freq = Freq_CETK
    T = 0:1/Fs:duration(i);
    i=i+1;
    sine_tone_CETK = [sine_tone_CETK, sin(1.3 * pi * freq * T)];
end

% Let's Plot the spectrogram of CETK Sine Tone
figure(3)
grid on;
spectrogram(sine_tone_CETK, 256, [], [], Fs, 'yaxis');
title("Spectrogram of Sine Tone CETK");
xlabel("Time");
ylabel("Frequency");
grid off;

% Now lets play the sound of CETK Sine Tone
sound(sine_tone_CETK, Fs, nBits);
pause (7)

% Storing the CETK Sine Tone in WAV File
audiowrite(L_CETK, sine_tone_CETK, Fs);

% Section End

%% Combining Sound Files

% We already have a 5000 Hz Sine tone stored in variable sine_tone

% Let's read the previously recorded speech file from Project 1
[y_wav, Fs_wav] = audioread(L);

% Now I know that y_wav does not match in rows or columns with sine_tone
% to fix this, we need to take transpose of y_wav and limit sine_tone

y_wav = transpose(y_wav);
Length = min(length(y_wav), length(sine_tone));
sine_tone = sine_tone(1:Length);
y_wav = y_wav(1:Length);
y_wav = y_wav/max(abs(y_wav));

SpeechChirp = y_wav + sine_tone;

figure(4)
grid on;
spectrogram(SpeechChirp, 256, [], [], Fs, 'yaxis');
title("Spectrogram of SpeechChirp");
xlabel("Time");
ylabel("Frequency");
grid off;

% Now lets play the the new signal
sound(SpeechChirp, Fs, nBits);
pause (7)

% Storing the CETK Sine Tone in WAV File
audiowrite(L_speechchirp, SpeechChirp, Fs);

% Section End

%% Audio Filtering

% Cutoff freq for the lowpass filter we are designing
cutoff_frequency = 4000;
filter_order = 100;

% This is our lowpass filter made using function designfilt
lowpass_filter = designfilt('lowpassfir', 'FilterOrder', filter_order, 'CutoffFrequency', cutoff_frequency, 'SampleRate', Fs);

filtered_audio = filter(lowpass_filter, SpeechChirp);

% Plot the spectrogram of the resulting signal
figure(5)
grid on;
spectrogram(filtered_audio, 256, [], [], Fs, 'yaxis');
title('Spectrogram of Filtered Signal (Lowpass Filter)');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
grid off;

% Now lets play the the filtered audio
sound(filtered_audio, Fs, nBits);
pause (7)

% Storing the Filtered audio in WAV File
audiowrite(L_filter, filtered_audio, Fs);

% Section End

%% Stereo Fun
% For this Section, I choose to read data from files and use different
% variables as for Recorded Audio from Project 1, The audio data has been
% changed for previous section.

% Reading the Recorded File from Project 1
[y_L, Fs_L] = audioread(L);

% Reading the SpeechChirp File
[y_R, Fs_R] = audioread(L_speechchirp);

% Let's make sure both left and right signals are of same length
Length = min(length(y_L), length(y_R));
y_L = y_L(1:Length);
y_R = y_R(1:Length);

% Now let's combine the mono signals into a singal stereo signal
stereo_signal = [y_L, y_R];

% Plot the spectrogram of Channel 1
figure(6)
grid on;
spectrogram(stereo_signal(:,1), 256, [], [], Fs_L, 'yaxis');
title("Spectrogram of Stereo Signal (Channel L)");
xlabel("Time");
ylabel("Frequency");
grid off;

% Plot the spectrogram of Channel 2
figure(7)
grid on;
spectrogram(stereo_signal(:,2), 256, [], [], Fs_L, 'yaxis');
title("Spectrogram of Stereo Signal (Channel R)");
xlabel("Time");
ylabel("Frequency");
grid off;

% Now lets play the the new signal
sound(stereo_signal, Fs, nBits);
pause (6)

% Storing the Filtered audio in WAV File
audiowrite(L_stereo, stereo_signal, Fs);

% Section End

%% Code End