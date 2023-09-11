clc 
close all 
clear all 

A = 4;
n = 7;   %number of samples

%% Generating an ensemble consists of 500 realizations , each 101 bits
Data = randi([0 1], 500, 101);

%% Mapping the 1 to be 'A' and 0 to be '-A' (Bipolar)
Tx = (Data - 0.5) * 2 * A;

%% Activating the DAC for 70ms
Tx_out = repelem(Tx, 1, 7);

%% Generating the random time delay 
Td = randi([0 6], 500, 1);
L = length(Tx_out);

%% Adding the delay time by the concept of circular shifting:
for i = 1:500
     Tx_row = Tx_out(i,:);
     Tx_col = Tx_row';
     Tx_col = circshift(Tx_col, Td(i));
     Tx_row = Tx_col';
     Tx_out(i,:) = Tx_row;
end

% Remove last bit after taking the random delay and add it to the realization using circular shifting  
final_array = Tx_out(:, 1:700); 

%% Statistical Mean
mean_val = mean(final_array(:, 60));
fprintf('The Statistical Mean of Bipolar NRZ is: %.03f \n', mean_val);

Bipolar_NRZ_Mean = zeros(1,700);
for t = 1:700
    sum1 = 0;
    for i=1:500
        sum1 = sum1+final_array(i,t);
    end
    Bipolar_NRZ_Mean(t) = sum1/500;
end
figure
plot(Bipolar_NRZ_Mean,'r');
xlabel('time instant');
ylabel('mean across realizations'); 
grid on;
ylim( [-5 5] );
%% Ensemble Autocorrelation Function Rx(τ)
Rx = zeros(1, 700);

for tau = 0:699
    sum_auto = 0;
    for i = 1:500
        auto_corr = final_array(i, 1) * final_array(i, tau + 1);
        sum_auto = sum_auto + auto_corr;
    end
    Rx(tau+1) = sum_auto/size(final_array, 1);
end

temp = fliplr(Rx(2:end)); % Flip the autocorrelation in the negative part
flipped_Rx = [temp Rx];   % Concatenate the positive part and the negative part 

% Plotting the ensemble autocorrelation
subplot(3, 1, 1);
plot(-(length(flipped_Rx)-1)/2:(length(flipped_Rx)-1)/2, flipped_Rx, 'b');
xlabel('\tau');
ylabel('Rx(tau)');
title('Bipolar NRZ Ensemble Autocorrelation');
grid on;
axis([-21 21 0 inf]);    % Review the first three bits
ylim([0 16]);

%% Time Mean:
time_mean = mean(final_array(4, :));
fprintf('The Time Mean of Bipolar NRZ is: %.03f  \n', time_mean);

%% Time Autocorrelation
Rx_time = zeros(1, 700);

for tau = 0:699
    sum1 = 0;
    for i = 1:700-tau
        sum1 = sum1 + final_array(1, i) * final_array(1, i + tau);
    end
    Rx_time(tau + 1) = sum1 / (700 - tau);
end

temp_time = fliplr(Rx_time(2:end)); % Flip the autocorrelation in the negative part
flipped_Rx_time = [temp_time Rx_time]; % Concatenate the positive part and the negative part 

subplot(3, 1, 2); 
plot(-(length(flipped_Rx_time)-1)/2:(length(flipped_Rx_time)-1)/2, flipped_Rx_time, 'b');
xlabel('\tau');
ylabel('RT(tau)');
title('Bipolar NRZ Time Autocorrelation');
grid on;
axis([-21 21 0 inf]);   % Review the first three bits
ylim([0 16]);

%% Power Spectral Density for Bipolar NRZ
autocorr_len = length(Rx);
frequency = -autocorr_len/2 : autocorr_len/2-1;
PSD = fftshift(abs(fft(Rx))).^2/length(Rx);

subplot(3, 1, 3);
plot(frequency, PSD, 'r');
xlabel('Frequency in Hz');
ylabel('PSD');
grid on;
title('PSD of Bipolar NRZ');
axis([-50 50 0 inf]);

% Calculate bandwidth
BW = sum(PSD > max(PSD)/2) / length(PSD) * abs(frequency(1) - frequency(end));
fprintf('The bandwidth of the Bipolar NRZ signal is: %.2f Hz\n', BW);