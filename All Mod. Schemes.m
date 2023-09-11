%% Generating Data and parameters
data = randi([0 1],1,10000);
%% BPSK Mapper:
Eb = 1;
No = 1;
Tx_BPSK = 2*data-1;
%% BPSK Noise Generation:
un_BPSK = randn( 1 , 10000 );%unscaled noise of the AWGN channel
BER_BPSK = zeros(1,8);
%% BPSK Noise addition and DeMapper:
for SNR = -2:5
    %Noise addition
    No = Eb/( 10^(SNR/10) );
    n_BPSK = un_BPSK * sqrt(No/2);%scaled version of noise
    Rx_BPSK = Tx_BPSK+n_BPSK;
    %Demapping of symbols
    for k = 1 : 10000
        if Rx_BPSK(k) > 0 
            Rx_BPSK(k) = 1;
        else
            Rx_BPSK(k) = -1;
        end
    end
    %Calculating BER
    [error_BPSK , ratio_BPSK] = symerr( Rx_BPSK ,Tx_BPSK );
    BER_BPSK( SNR + 3) = ratio_BPSK;
end
%% Calculating Therotical BER for BPSK and QPSK:
theoretical_BPSK_QPSK = zeros(1,8);
for x = -2 : 5
    SNR =  10^( x/10 ) ;
    theoretical_BPSK_QPSK( 3 + x ) = 0.5*erfc( sqrt( SNR ) );
end



%% QPSK with and without Gray mapper:
Tx_QPSKG = zeros(1,5000); %QPSK with gray encoding
Tx_QPSKNG = zeros(1,5000);%QPSK without gray encoding
for j = 1 : 2 : 10000
    if data(j) == 1 && data( j+1 ) == 1
        Tx_QPSKG( (j+1)/2 ) = complex( 1 , 1 );
        Tx_QPSKNG( (j+1)/2 ) = complex(1 , -1); 
    elseif data(j) == 0 && data( j+1 ) == 0
        Tx_QPSKG( (j+1)/2 ) = complex( -1 , -1 );
        Tx_QPSKNG( (j+1)/2 ) = complex( -1 , -1);
    elseif data(j) == 1 && data( j+1 ) == 0
        Tx_QPSKG( (j+1)/2 ) = complex( 1 , -1 );
        Tx_QPSKNG( (j+1)/2 ) = complex(1 , 1);
    else
        Tx_QPSKG( (j+1)/2 ) = complex( -1 , 1 );
        Tx_QPSKNG( (j+1)/2 ) = complex( -1 , 1);
    end
end 
%% QPSK Noise Generation:
un_QPSK = complex( randn( 1 , 5000) , randn(1 , 5000) );
BER_QPSKG = zeros( 1 , 8);
BER_QPSKNG = zeros( 1 , 8);
Demapped_symbol_QPSK = zeros( 1 , 10000);%Returning the symbols into individual bits to calculate BER
Demapped_symbol_NG = zeros( 1 , 10000);
%% QPSK Noise addition and DeMapper:
for SNR = -2:5
    %Noise Addition
    No = Eb/( 10^(SNR/10) );
    n_QPSK = un_QPSK * sqrt(No/2);
    Rx_QPSKG = Tx_QPSKG + n_QPSK;
    Rx_QPSKNG = Tx_QPSKNG + n_QPSK;
    %Gray Encoding demapping
    for j = 1 : 5000
        if real( Rx_QPSKG(j) ) > 0 && imag( Rx_QPSKG(j) ) > 0
            Rx_QPSKG(j) = complex( 1 , 1 );
            Demapped_symbol_QPSK(2*j-1) = 1;
            Demapped_symbol_QPSK(2*j) = 1;
        elseif real( Rx_QPSKG(j) )< 0  && imag( Rx_QPSKG(j) ) < 0
            Rx_QPSKG(j) = complex( -1 , -1);
            Demapped_symbol_QPSK(2*j-1) = -1;
            Demapped_symbol_QPSK(2*j) = -1;
        elseif real( Rx_QPSKG(j) ) > 0  && imag( Rx_QPSKG(j) ) < 0
            Rx_QPSKG(j) = complex( 1 , -1);
            Demapped_symbol_QPSK(2*j-1) = 1;
            Demapped_symbol_QPSK(2*j) = -1;
        elseif real( Rx_QPSKG(j) ) < 0  && imag( Rx_QPSKG(j) ) > 0
            Rx_QPSKG(j) = complex( -1 , 1) ;
            Demapped_symbol_QPSK(2*j-1) = -1;
            Demapped_symbol_QPSK(2*j) = 1;
        end
    end
    %No Gray Encoding demapping:
    for j = 1 : 5000
        if real( Rx_QPSKNG(j) ) > 0 && imag( Rx_QPSKNG(j) ) > 0
            Rx_QPSKNG(j) = complex( 1 , -1 );
            Demapped_symbol_NG(2*j-1) = 1;
            Demapped_symbol_NG(2*j) = -1;
        elseif real( Rx_QPSKNG(j) )< 0  && imag( Rx_QPSKNG(j) ) < 0
            Rx_QPSKNG(j) = complex( -1 , -1);
            Demapped_symbol_NG(2*j-1) = -1;
            Demapped_symbol_NG(2*j) = -1;
        elseif real( Rx_QPSKNG(j) ) > 0  && imag( Rx_QPSKNG(j) ) < 0
            Rx_QPSKNG(j) = complex( 1 , 1);
            Demapped_symbol_NG(2*j-1) = 1;
            Demapped_symbol_NG(2*j) = 1;
        elseif real( Rx_QPSKNG(j) ) < 0  && imag( Rx_QPSKNG(j) ) > 0
            Rx_QPSKNG(j) = complex( -1 , 1) ;
            Demapped_symbol_NG(2*j-1) = -1;
            Demapped_symbol_NG(2*j) = 1;
        end
    end
    [errors_QPSK , ratio_QPSK] = symerr( Demapped_symbol_QPSK , Tx_BPSK );
    [errors_QPSK_NoGray , ratio_QPSK_NoGray] = symerr( Demapped_symbol_NG , Tx_BPSK);
    BER_QPSKG( SNR + 3) = ratio_QPSK;
    BER_QPSKNG( SNR + 3) = ratio_QPSK_NoGray;
end



%% 16QAM Mapper:
Tx_QAM = zeros(1,2500);
for i=1:4:10000
    %1st Quadrant    
    if data(i)==1 && data(i+1)==1 && data(i+2)==1 && data(i+3)==1
        Tx_QAM((i+3)/4) = complex(1,1);    
    elseif data(i)==1 && data(i+1)==0 && data(i+2)==1 && data(i+3)==1
        Tx_QAM((i+3)/4) = complex(3,1);
    elseif data(i)==1 && data(i+1)==1 && data(i+2)==1 && data(i+3)==0
        Tx_QAM((i+3)/4) = complex(1,3);
    elseif data(i)==1 && data(i+1)==0 && data(i+2)==1 && data(i+3)==0
        Tx_QAM((i+3)/4) = complex(3,3);
    %2nd Quadrant
    elseif data(i)==0 && data(i+1)==0 && data(i+2)==1 && data(i+3)==1
        Tx_QAM((i+3)/4) = complex(-3,1);
    elseif data(i)==0 && data(i+1)==1 && data(i+2)==1 && data(i+3)==1
        Tx_QAM((i+3)/4) = complex(-1,1);
    elseif data(i)==0 && data(i+1)==0 && data(i+2)==1 && data(i+3)==0
        Tx_QAM((i+3)/4) = complex(-3,3);
    elseif data(i)==0 && data(i+1)==1 && data(i+2)==1 && data(i+3)==0
        Tx_QAM((i+3)/4) = complex(-1,3);
    %3rd Quadrant
    elseif data(i)==0 && data(i+1)==0 && data(i+2)==0 && data(i+3)==0
        Tx_QAM((i+3)/4) = complex(-3,-3);
    elseif data(i)==0 && data(i+1)==0 && data(i+2)==0 && data(i+3)==1
        Tx_QAM((i+3)/4) = complex(-3,-1);
    elseif data(i)==0 && data(i+1)==1 && data(i+2)==0 && data(i+3)==0
        Tx_QAM((i+3)/4) = complex(-1,-3);
    elseif data(i)==0 && data(i+1)==1 && data(i+2)==0 && data(i+3)==1
        Tx_QAM((i+3)/4) = complex(-1,-1);
    %4th Quadrant
    elseif data(i)==1 && data(i+1)==1 && data(i+2)==0 && data(i+3)==0
        Tx_QAM((i+3)/4) = complex(1,-3);
    elseif data(i)==1 && data(i+1)==0 && data(i+2)==0 && data(i+3)==0
        Tx_QAM((i+3)/4) = complex(3,-3);
    elseif data(i)==1 && data(i+1)==1 && data(i+2)==0 && data(i+3)==1
        Tx_QAM((i+3)/4) = complex(1,-1);
    elseif data(i)==1 && data(i+1)==0 && data(i+2)==0 && data(i+3)==1
        Tx_QAM((i+3)/4) = complex(3,-1);   
    end
end
%% 16QAM Noise Generation:
un_QAM = complex( randn( 1 , 2500) , randn(1 , 2500) );
BER_QAM = zeros( 1 , 8);
Demapped_symbol_QAM = zeros( 1 , 10000);%Returning the symbols into individual bits to calculate BER
Eb_QAM = 2.5;
%% QAM Noise addition and DeMapper:
for SNR = -2:5
    %Noise Addition
    No = Eb_QAM/( 10^(SNR/10) );
    n_QAM = un_QAM * sqrt(No/2);
    Rx_QAM = Tx_QAM + n_QAM;
    y = 1;
    for j=1:2500
        if real(Rx_QAM(j))>2
            if imag(Rx_QAM(j))>2
                Demapped_symbol_QAM(y) = 1;
                Demapped_symbol_QAM(y+1) = -1;
                Demapped_symbol_QAM(y+2) = 1;
                Demapped_symbol_QAM(y+3) = -1;
            elseif imag(Rx_QAM(j))>0
                Demapped_symbol_QAM(y) = 1;
                Demapped_symbol_QAM(y+1) = -1;
                Demapped_symbol_QAM(y+2) = 1;
                Demapped_symbol_QAM(y+3) = 1;
            elseif imag(Rx_QAM(j))>-2
                Demapped_symbol_QAM(y) = 1;
                Demapped_symbol_QAM(y+1) = -1;
                Demapped_symbol_QAM(y+2) = -1;
                Demapped_symbol_QAM(y+3) = 1;
            else
                Demapped_symbol_QAM(y) = 1;
                Demapped_symbol_QAM(y+1) = -1;
                Demapped_symbol_QAM(y+2) = -1;
                Demapped_symbol_QAM(y+3) = -1;
            end
        elseif real(Rx_QAM(j))>0 
            if imag(Rx_QAM(j))>2
                Demapped_symbol_QAM(y) = 1;
                Demapped_symbol_QAM(y+1) = 1;
                Demapped_symbol_QAM(y+2) = 1;
                Demapped_symbol_QAM(y+3) = -1;
            elseif imag(Rx_QAM(j))>0
                Demapped_symbol_QAM(y) = 1;
                Demapped_symbol_QAM(y+1) = 1;
                Demapped_symbol_QAM(y+2) = 1;
                Demapped_symbol_QAM(y+3) = 1;
            elseif imag(Rx_QAM(j))>-2
                Demapped_symbol_QAM(y) = 1;
                Demapped_symbol_QAM(y+1) = 1;
                Demapped_symbol_QAM(y+2) = -1;
                Demapped_symbol_QAM(y+3) = 1;
            else
                Demapped_symbol_QAM(y) = 1;
                Demapped_symbol_QAM(y+1) = 1;
                Demapped_symbol_QAM(y+2) = -1;
                Demapped_symbol_QAM(y+3) = -1;
            end
        elseif real(Rx_QAM(j))>-2
             if imag(Rx_QAM(j))>2
                Demapped_symbol_QAM(y) = -1;
                Demapped_symbol_QAM(y+1) = 1;
                Demapped_symbol_QAM(y+2) = 1;
                Demapped_symbol_QAM(y+3) = -1;
            elseif imag(Rx_QAM(j))>0
                Demapped_symbol_QAM(y) = -1;
                Demapped_symbol_QAM(y+1) = 1;
                Demapped_symbol_QAM(y+2) = 1;
                Demapped_symbol_QAM(y+3) = 1;
            elseif imag(Rx_QAM(j))>-2
                Demapped_symbol_QAM(y) = -1;
                Demapped_symbol_QAM(y+1) = 1;
                Demapped_symbol_QAM(y+2) = -1;
                Demapped_symbol_QAM(y+3) = 1;
            else
                Demapped_symbol_QAM(y) = -1;
                Demapped_symbol_QAM(y+1) = 1;
                Demapped_symbol_QAM(y+2) = -1;
                Demapped_symbol_QAM(y+3) = -1;
            end
        else
            if imag(Rx_QAM(j))>2
                Demapped_symbol_QAM(y) = -1;
                Demapped_symbol_QAM(y+1) = -1;
                Demapped_symbol_QAM(y+2) = 1;
                Demapped_symbol_QAM(y+3) = -1;
            elseif imag(Rx_QAM(j))>0
                Demapped_symbol_QAM(y) = -1;
                Demapped_symbol_QAM(y+1) = -1;
                Demapped_symbol_QAM(y+2) = 1;
                Demapped_symbol_QAM(y+3) = 1;
            elseif imag(Rx_QAM(j))>-2
                Demapped_symbol_QAM(y) = -1;
                Demapped_symbol_QAM(y+1) = -1;
                Demapped_symbol_QAM(y+2) = -1;
                Demapped_symbol_QAM(y+3) = 1;
            else
                Demapped_symbol_QAM(y) = -1;
                Demapped_symbol_QAM(y+1) = -1;
                Demapped_symbol_QAM(y+2) = -1;
                Demapped_symbol_QAM(y+3) = -1;
            end
        end
        y = y+4;
    end
    [errors_QAM , ratio_QAM] = symerr( Demapped_symbol_QAM , Tx_BPSK );
    BER_QAM( SNR + 3) = ratio_QAM;
end
%% Calculating Therotical BER for QAM:
theoretical_QAM = zeros(1,8);
for x = -2 : 5
    SNR =  10^( x/10 ) ;
    theoretical_QAM( 3 + x ) = (1.5/4)*erfc( sqrt( SNR/2.5 ) );
end


%% 8PSK Mapper:
Tx_8PSK = zeros(1,3333);
for i=1:3:9999
    if data(i) == 0 && data(i+1) == 0 && data(i+2) == 0
        Tx_8PSK((i+2)/3) = complex(1,0);
    elseif data(i) == 0 && data(i+1) == 0 && data(i+2) == 1
        Tx_8PSK((i+2)/3) = complex(sqrt(1/2),sqrt(1/2));
    elseif data(i) == 0 && data(i+1) == 1 && data(i+2) == 1
        Tx_8PSK((i+2)/3) = complex(0,1);
    elseif data(i) == 0 && data(i+1) == 1 && data(i+2) == 0
        Tx_8PSK((i+2)/3) = complex(-sqrt(1/2),sqrt(1/2));
    elseif data(i) == 1 && data(i+1) == 1 && data(i+2) == 0
        Tx_8PSK((i+2)/3) = complex(-1,0);
    elseif data(i) == 1 && data(i+1) == 1 && data(i+2) == 1
        Tx_8PSK((i+2)/3) = complex(-sqrt(1/2),-sqrt(1/2));
    elseif data(i) == 1 && data(i+1) == 0 && data(i+2) == 1
        Tx_8PSK((i+2)/3) = complex(0,-1);
    elseif data(i) == 1 && data(i+1) == 0 && data(i+2) == 0
        Tx_8PSK((i+2)/3) = complex(sqrt(1/2),-sqrt(1/2));
    end 
end
data_8PSK = zeros(1,9999);
for j = 1:9999
    data_8PSK(j) = Tx_BPSK(j);
end
%% 8PSK Noise Generation:
un_8PSK = complex( randn( 1 , 3333) , randn(1 , 3333) );
BER_8PSK = zeros( 1 , 8);
Demapped_symbol_8PSK = zeros( 1 , 9999);%Returning the symbols into individual bits to calculate BER
Eb_8PSK = 1/3;
%% 8PSK Noise addition and DeMapper:
for SNR = -2:5
    %Noise Addition
    No = Eb_8PSK/( 10^(SNR/10) );
    n_8PSK = un_8PSK * sqrt(No/2);
    Rx_8PSK = Tx_8PSK + n_8PSK;
    y = 1;
    for i=1:3333
        if angle(Rx_8PSK(i))>-pi/8 && angle(Rx_8PSK(i))<pi/8
            Demapped_symbol_8PSK(y) = -1;
            Demapped_symbol_8PSK(y+1) = -1;
            Demapped_symbol_8PSK(y+2) = -1;
        elseif angle(Rx_8PSK(i))>pi/8 && angle(Rx_8PSK(i))<3*pi/8
            Demapped_symbol_8PSK(y) = -1;
            Demapped_symbol_8PSK(y+1) = -1;
            Demapped_symbol_8PSK(y+2) = 1;
        elseif angle(Rx_8PSK(i))>3*pi/8 && angle(Rx_8PSK(i))<5*pi/8
            Demapped_symbol_8PSK(y) = -1;
            Demapped_symbol_8PSK(y+1) = 1;
            Demapped_symbol_8PSK(y+2) = 1;    
        elseif angle(Rx_8PSK(i))>5*pi/8 && angle(Rx_8PSK(i))<7*pi/8
            Demapped_symbol_8PSK(y) = -1;
            Demapped_symbol_8PSK(y+1) = 1;
            Demapped_symbol_8PSK(y+2) = -1;
        elseif angle(Rx_8PSK(i))>7*pi/8 || angle(Rx_8PSK(i))<-7*pi/8
            Demapped_symbol_8PSK(y) = 1;
            Demapped_symbol_8PSK(y+1) = 1;
            Demapped_symbol_8PSK(y+2) = -1;
        elseif angle(Rx_8PSK(i))>-7*pi/8 && angle(Rx_8PSK(i))<-5*pi/8
            Demapped_symbol_8PSK(y) = 1;
            Demapped_symbol_8PSK(y+1) = 1;
            Demapped_symbol_8PSK(y+2) = 1;
        elseif angle(Rx_8PSK(i))>-5*pi/8 && angle(Rx_8PSK(i))<-3*pi/8
            Demapped_symbol_8PSK(y) = 1;
            Demapped_symbol_8PSK(y+1) = -1;
            Demapped_symbol_8PSK(y+2) = 1;
        elseif angle(Rx_8PSK(i))>-3*pi/8 && angle(Rx_8PSK(i))<-pi/8
            Demapped_symbol_8PSK(y) = 1;
            Demapped_symbol_8PSK(y+1) = -1;
            Demapped_symbol_8PSK(y+2) = -1;
        end
         y = y+3;
    end  
    [errors_8PSK , ratio_8PSK] = symerr( Demapped_symbol_8PSK , data_8PSK );
    BER_8PSK( SNR + 3) = ratio_8PSK;
end
%% Calculating Therotical BER for 8PSK:
theoretical_8PSK = zeros(1,8);
for x = -2 : 5
    SNR =  10^( x/10 ) ;
    theoretical_8PSK( 3 + x ) = (1/3)*erfc( sqrt( 3*SNR)*sin(pi/8) );
end
%% Plotting
figure
x_axis = -2 : 5 ;
semilogy( x_axis , BER_BPSK , 'r' ,'LineWidth' , 1.5 ) 
hold on
semilogy( x_axis , theoretical_BPSK_QPSK , '*g' ,'LineWidth' , 1.5 )
hold on
semilogy( x_axis , BER_QPSKG , 'b' ,'LineWidth' , 1.5 ) 
hold on
semilogy( x_axis , BER_QPSKNG , 'm' ,'LineWidth' , 1.5 ) 
hold on
semilogy( x_axis , BER_QAM , 'c' ,'LineWidth' , 1.5 ) 
hold on
semilogy( x_axis , theoretical_QAM , '*c' ,'LineWidth' , 1.5 ) 
hold on
semilogy( x_axis , BER_8PSK , 'y' ,'LineWidth' , 1.5 ) 
hold on
semilogy( x_axis , theoretical_8PSK , '*y' ,'LineWidth' , 1.5 ) 
xlabel( 'SNR in dB' );
ylabel( 'BER' );
grid on
legend( 'BPSK BER' , 'theoretical BPSK' , 'QPSK BER' , 'QPSK without gray encoding', 'QAM BER' , 'theoretical QAM', '8PSK BER' , 'theoretical 8PSK');
title( 'Bit Error Rates for the four modulation schemes overlaid');



%% Part 1.5: BFSK
Eb=1;
No=1;
Data_BFSK = 2*data-1;
%% BFSK Mapper
Tx_BFSK=zeros(1,10000);
for i = 1 : 10000
    if data(i)==1
        Tx_BFSK(i)=complex(0,1);
    else
        Tx_BFSK(i)=complex(1,0);
    end
end
%% BFSK Noise addition and Demapper:
un_BFSK = complex( randn( 1 , 10000) , randn(1 , 10000) );
BER_BFSK=zeros(1,8);
for SNR= -2 : 5
    No = Eb/( 10^(SNR/10) );
    n_BFSK = un_BFSK * sqrt(No/2);
    Rx_BFSK = Tx_BFSK + n_BFSK;
    for i = 1 : 10000
        if angle(Rx_BFSK(i))>pi/4 && angle(Rx_BFSK(i))<5*pi/4
            Demapped_BFSK(i) = 1;
        else
            Demapped_BFSK(i) =-1;
        end
    end
    [errors_BFSK , ratio_BFSK] = symerr( Demapped_BFSK , Data_BFSK );
    BER_BFSK( SNR + 3) = ratio_BFSK;
end
%% Calculating Therotical BER for BFSK:
theoretical_BFSK = zeros(1,8);
for x = -2 : 5
    SNR =  10^( x/10 ) ;
    theoretical_BFSK( 3 + x ) = (1/2)*erfc(sqrt(SNR/2));
end
%% Plotting:
 figure
x_axis = -2 : 5 ;
semilogy( x_axis , BER_BFSK , 'r' ,'LineWidth' , 2 ) 
hold on
semilogy( x_axis , theoretical_BFSK , '*g' ,'LineWidth' , 2 )   
legend( 'BFSK BER' , 'theoretical BFSK');

