%% Random bits generation
Data = randi([0 1],10,1);
Data = Data';
Tx = 2*(Data)-1;

%% impulse generation
impulses = upsample(Tx,5);

%% Pulse generation
p=[5 4 3 2 1]/sqrt(55);

%% convolution of pulse with bit stream
y = conv(impulses,p);
plot(y);
%% reciever matched filter
matched_filt = fliplr(p);
MFoutput = conv(y,matched_filt);
figure
subplot(1,2,1);
plot(MFoutput);
ylabel('O/P of matched filter');
%% reciever rect filter
rect=[0.2697 0.2697 0.2697 0.2697 0.2697];
Rectoutput = conv(y,rect);
subplot(1,2,2);
plot(Rectoutput,'m');
ylabel('O/P of rect filter');

%% correlator 
lx = length(p);
ly = length(y);
corr = zeros(1, ly);
for k = 1:ly
    for n = 1:lx
        if (k-n+1 <= 0)
            corr(k) = corr(k) + 0;
        else
            corr(k) = corr(k) + p(n)*y(k-n+1);
        end
    end
end
figure
subplot(1,2,1);
plot(output2,'m');
ylabel('O/P of matched filter');
subplot(1,2,2);
plot(corr);
ylabel('O/P of correlator');