clear all
close all
clc

%% ultrasound parameters

Fs = 15.00E6;                          % sampling frequency
TxFreq = 4;                            % MHz, Transmission frequency
depth = 160.2; %placenta               % mm 
SoS = 1540;                            % m/s
G=1;

%% read rf data 
% replace with your directory
filenameRF = '/MATLAB Drive/DSPFinalProject/Codes/Posterior_Placenta/raw_1/2024-04-19t21-56-53+0000_rf.raw';
numFrames = 1;
[dataRF_sample, headerSample] = rdataread(filenameRF, numFrames);
RF = permute(dataRF_sample,[2,3,1]);
envelope = abs(hilbert(RF));
Bmode = 20.*log10(envelope);

% diplay RF data
figure, plot(RF(:,100))
% diplay envelope data
figure, plot(envelope(:,100))

% Find the Fs1, Fs2, Fp1 and Fp2 from the following plot
figure, pwelch(RF(:,100),[],[],[],Fs)
% display Bmode image
figure; 
colormap(gray)
imagesc(Bmode); title('B-mode Image')

%% 
y = filtfilt(SoS, G, RF);
envelopeFilt = abs(hilbert(y));
BmodeFilt = 20.*log10(envelopeFilt);
figure; 
colormap(gray)
imagesc(BmodeFilt); title('B-mode Image')

%% power spectral analysis
% Reduce data size for quicker PSD estimation
signal = RF(1:1000, 100);  % Take the first 1000 samples for faster computation

% Compute the Power Spectral Density (PSD) using pwelch
[Pxx, f] = pwelch(signal, [], [], [], Fs);

% Convert the PSD to dB scale
Pxx_dB = 10 * log10(Pxx);

% Plot the PSD
figure;
plot(f, Pxx_dB);
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('Power Spectral Density of RF Signal');
grid on;

%%
% Find indices where PSD crosses -40 dB and -30 dB
[~, idx_40dB] = min(abs(Pxx_dB + 40));  % -40 dB crossing point
[~, idx_30dB] = min(abs(Pxx_dB + 30));  % -30 dB crossing point

% Get the corresponding frequencies
Fstop1 = f(idx_40dB);  % Stopband 1 frequency
Fpass1 = f(idx_30dB);  % Passband 1 frequency
Fstop2 = Fpass1;       % Second stopband is the same as the first passband
Fpass2 = f(idx_40dB);  % Passband 2 frequency

%% Correct frequency order if needed
frequencies = [Fstop1, Fpass1, Fpass2, Fstop2];
frequencies = sort(frequencies);  % Sort them in ascending order

% Assign sorted frequencies
Fstop1 = frequencies(1);
Fpass1 = frequencies(2);
Fpass2 = frequencies(3);
Fstop2 = frequencies(4);

% Plot the frequency markers
plot([Fstop1 Fstop1], [-70 0], 'r--', 'LineWidth', 2);  % Mark Fstop1
plot([Fpass1 Fpass1], [-70 0], 'g--', 'LineWidth', 2);  % Mark Fpass1
plot([Fstop2 Fstop2], [-70 0], 'r--', 'LineWidth', 2);  % Mark Fstop2
plot([Fpass2 Fpass2], [-70 0], 'g--', 'LineWidth', 2);  % Mark Fpass2

xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('Power Spectral Density with Filter Cutoffs');
legend('PSD', 'Fstop1', 'Fpass1', 'Fstop2', 'Fpass2');
grid on;

% Plot the PSD and mark the frequencies
figure;
plot(f, 10*log10(Pxx)); 
hold on;
plot([Fstop1 Fstop1], [-60 0], 'r--', 'LineWidth', 2);  % Mark Fstop1
plot([Fpass1 Fpass1], [-60 0], 'g--', 'LineWidth', 2);  % Mark Fpass1
plot([Fstop2 Fstop2], [-60 0], 'r--', 'LineWidth', 2);  % Mark Fstop2
plot([Fpass2 Fpass2], [-60 0], 'g--', 'LineWidth', 2);  % Mark Fpass2
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('Power Spectral Density with Filter Cutoffs');
legend('PSD', 'Fstop1', 'Fpass1', 'Fstop2', 'Fpass2');
grid on;

