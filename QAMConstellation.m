function [si1,si2]=QAMConstellation(signal, T, Fs, Fc)
    figure
    si1 = [];
    si2 = [];
for i = 1:length(signal)/ceil(Fs*T)
    t = linspace((i-1)*T,i*T-T/Fs,ceil(Fs*T));
    phi1 = sqrt(2/T)*cos(2*pi*Fc*t);
    phi2 = sqrt(2/T)*sin(2*pi*Fc*t);
    si1 = [si1, sum(signal((i-1)*ceil(Fs*T)+1:i*ceil(Fs*T)).*phi1)/Fs];
    si2 = [si2, sum(signal((i-1)*ceil(Fs*T)+1:i*ceil(Fs*T)).*phi2)/Fs];
    if(sum(signal((i-1)*ceil(Fs*T)+1:i*ceil(Fs*T)).*phi1)/Fs == 0)
        disp(i)
    end
end
scatter(si1,si2,'filled')
grid on
xlim('auto')
ylim('auto')
hold off
end