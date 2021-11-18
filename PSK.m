function [output, time] = PSK(signal,M, E, T, Fs, Fc)
N = ceil(T*Fs); %samples per symbol
BPS = log2(M); %bit per symbol
output = zeros(1,ceil(length(signal)/BPS*N));
phase = 0:2*pi/M : (1-(1/M))*2*pi;
switch M
    case 2
        bits = [0 1];
    case 4
        bits = [0 1 3 2];
    case 8 
        bits = [0 1 3 2 6 7 5 4];
end
for i = 1:length(signal)/BPS
    t = linspace((i-1)*T,i*T-T/Fs,ceil(Fs*T));
    theta = phase(bits == bin2dec(signal((i-1)*BPS+1:i*BPS)));
    phi =  sqrt(2*E/T)*cos(2*pi*Fc*t-theta);
    output((i-1)*N+1:i*N) = phi;
end
time = linspace(0,N*length(signal)/M/Fs,length(output));
end