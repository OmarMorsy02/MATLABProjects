clc 
close all 
clear all 

A = 4;
%% Generating an ensemble consists of 500 realization , each 101 bits
Data = randi( [0 1] , 500 , 101 );

%% Mapping the 1 to be 'A' and 0 to be '-1'
Tx = ((2*Data)-1) * A;

%% Activating the DAC for 70ms
Tx_out = repelem ( Tx , 1 , 7 );

%% Generating the random time delay 
Td = randi( [0 6] , 500 , 1 );
L = length( Tx_out );

%% Generating zeros for the NRZ signaling
for i=1:500
    for j=4:7:101*7
        for k=0:3
        Tx_out (i,j+k) = 0;
        end
    end
end

%% Adding the delay time by the concept of circular shifting:
% Tx_row stores every realizations of the generated ensemple and then use circular
% shifting to add the random delay to each realization
for i=1:500
     Tx_row = Tx_out(i,:);
     Tx_col = Tx_row';
     Tx_col= circshift(Tx_col,Td(i));
     Tx_row = Tx_col';
     Tx_out(i,:) = Tx_row;
end

%remove last bit after taking the random delay and add it to the realization using circular shifting  
final_array = Tx_out(1:500,1:700); 

%% Statistical Mean
sum = 0;
for i = 1 : 500
    sum = sum + final_array(i,60);
end
RZ_Mean = zeros(1,700);
for t = 1:700
    sum1 = 0;
    for i=1:500
        sum1 = sum1+final_array(i,t);
    end
    RZ_Mean(t) = sum1/500;
end
figure
plot(RZ_Mean,'r');
xlabel('time instant');
ylabel('mean across realizations'); 
grid on;
ylim( [-5 5] );

mean = sum/500;
fprintf('the Statistical Mean of Return to Zero Is Equal: %.03f \n' , mean );

 %% ensemble autocorrelation function Rx(τ)
 Rx = zeros( 1 , 700 );
 
 for tau = 0 : 699
     sum_auto = 0;
     for i = 1 : 500
         auto_corr = final_array( i , 1)*final_array( i , tau + 1);
         sum_auto = sum_auto + auto_corr;
     end
     Rx(tau+1) = sum_auto/size(final_array , 1);
 end
temp = fliplr( Rx(2:end) ); %flip the autocorrelation in the negative part
flipped_Rx = [temp Rx];     %concatinate the positive part and the negative part 

%plotting the ensemple autocorrelation
subplot( 3 , 1 , 1);
plot( -(length(flipped_Rx)-1)/2:(length(flipped_Rx)-1)/2 , flipped_Rx, 'b');
xlabel('\tau');
ylabel('Rx(tau)');
title('Return to Zero Ensemple Autocorrelation');
grid on;
axis([-21 21 0 inf]);    %Review the first three bits
ylim( [0 10] );


%% Time Mean:
sum_time = 0;
for i=1:700
    sum_time=sum_time+(final_array(4,i));
end
time_mean = sum_time/(700);
fprintf('The time mean of Return to Zero is equal : %0.3f  \n' , time_mean );

%% time autocorrelation
Rx_time = zeros( 1 , 700 );

%The outer loop changes the time differnce between the two RVs 
%The inner loop sum across the time
for tau = 0 : 699
    sum1 = 0;
    for i = 1 : 700-tau
        sum1 = sum1 + final_array(1 , i) * final_array(1 , i + tau );
    end
    Rx_time ( tau + 1 ) = sum1/(700-tau);
end

temp_time = fliplr( Rx_time(2:end) );    %flip the autocorrelation in the negative part
flipped_Rx_time = [temp_time Rx_time];   %concatinate the positive part and the negative part 

subplot( 3 , 1 , 2 ); 
plot( -(length(flipped_Rx_time)-1)/2:(length(flipped_Rx_time)-1)/2 , flipped_Rx_time , 'b');
xlabel('\tau');
ylabel('RT(tau)');
title('Return to Zero time autocorrelation');
grid on;
axis([-21 21 0 inf]);   %Review the first three bits
ylim( [0 10] );

%% Power Spectral density for Return to Zero
autocorr_len = length( Rx ) ;
frequency = -autocorr_len/2 : autocorr_len/2-1;

subplot( 3 , 1 , 3);
plot( frequency , fftshift( abs( fft(Rx) )) , 'r' );
xlabel('frequency in Hz');
ylabel('Amplitude');
grid on;
title('PSD of the Return to Zero');
axis([-1000 1000 0 inf]);

%% Drawing 5 realizations as an example
%note: Td is delay time and is made for plotting only!!
L = length( Tx_out );
T = 0:1/7:101-1/7;

y = zeros( 1 , length(T) );
for i = 0:4
    for j = 0 : 1 :7*101-1
        if Tx_out(i+1 , j+1 ) == 4
            y( 1 , j+1 ) = 4;
        elseif Tx_out(i+1 , j+1 ) == 0
            y(1, j+1 ) =0;
        else
            y( 1, j+1 ) = -4;
        end
    end
   t = Td(i+1) : 1/7 : (101-1/7)+Td(i+1);
    figure;
    plot( t , y , 'lineWidth' , 3);
end