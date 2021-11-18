clear
clc
[audio,fs]= audioread("IMG_0991.MP4");
audio=audio(:,1);
audio=audio(40000:100000);
[audio_quantized,audio_levels] = Quantizer(audio(:,1), 2^8);
audio_bit_stream= Encode(audio_quantized, audio_levels);

custMap=[0 2 4 6 7 5 3 1];
pskModulator = comm.PSKModulator(8,'BitInput',true, ...
    'SymbolMapping','Custom', ...
    'CustomSymbolMapping',custMap);

audio_mod = pskModulator(audio_bit_stream');

%% ricianchannel 
ricianchan = comm.RicianChannel
audio_mod_ri= ricianchan(audio_mod);
%% AWGN Channel
awgnchannel = comm.AWGNChannel('EbNo',2,'BitsPerSymbol',3);
audio_mod_awgn= awgnchannel(audio_mod);
%% Rayleigh Channel

rayleighchan = comm.RayleighChannel(...
    'SampleRate',100e3, ...
    'PathDelays',[0 1e-20], ...
    'AveragePathGains',[2 3], ...
    'NormalizePathGains',true, ...
    'MaximumDopplerShift',0.01, ...
    'RandomStream','mt19937ar with seed', ...
    'Seed',22, ...
    'PathGainsOutputPort',true);
% rayleighchan = comm.RayleighChannel()
% 


audio_mod_re= rayleighchan(audio_mod);

%% Demodulation
pskDemodulator = comm.PSKDemodulator(8,'BitOutput',true, ...
    'SymbolMapping','Custom', ...
    'CustomSymbolMapping',custMap);
out=(pskDemodulator(audio_mod_awgn)');
out_ = sprintf('%d', out);
audio_decoded= Decode(out_, audio_levels);
sound(audio_decoded,fs);
%%
[nu,r]=biterr(out,audio_bit_stream)

%%
audiowrite("ricien.wav",audio_decoded,fs)
% audiowrite("awgn.wav",audio_decoded,fs)
% audiowrite("re.wav",audio_decoded,fs)

%% BER Vs. SNR 
BER =[];
SNR = 0:1:12;
for i =1: length(SNR);
    awgnchannel = comm.AWGNChannel('EbNo',SNR(i),'BitsPerSymbol',3);
    audio_mod_awgn= awgnchannel(audio_mod);
    out=(pskDemodulator(audio_mod_awgn)');
    [nu,r]=biterr(out,audio_bit_stream);
    BER=[BER,r];
end
semilogy( SNR,BER);
title("BER vs. SNR");
xlabel("SNR(E_0/N_0)")
ylabel("BER")
%%

BER =[];
PathDelays = 0:1:12;
for i =1: length(PathDelays);
    rayleighchan = comm.RayleighChannel(...
    'SampleRate',100e3, ...
    'PathDelays',[0 0.01], ...
    'AveragePathGains',[12 PathDelays(i)], ...
    'NormalizePathGains',true, ...
    'MaximumDopplerShift',0.0000000001, ...
    'RandomStream','mt19937ar with seed', ...
    'Seed',22, ...
    'PathGainsOutputPort',true);
    audio_mod_re= rayleighchan(audio_mod);
    out=(pskDemodulator(audio_mod_re)');
    [nu,r]=biterr(out,audio_bit_stream);
    BER=[BER,r];
end
semilogy( PathDelays,BER);
title("BER vs. AveragePathGains");
xlabel("AveragePathGains")
ylabel("BER")
hold on
BER =[];
PathDelays = 0:1:12;
for i =1: length(PathDelays)
    rayleighchan = comm.RicianChannel(...
    'SampleRate',100e3, ...
    'PathDelays',[0 0.01], ...
    'AveragePathGains',[12 PathDelays(i)], ...
    'NormalizePathGains',true, ...
    'MaximumDopplerShift',0.0000000001, ...
    'RandomStream','mt19937ar with seed', ...
    'Seed',22, ...
    'PathGainsOutputPort',true);
    audio_mod_re= rayleighchan(audio_mod);
    out=(pskDemodulator(audio_mod_re)');
    [nu,r]=biterr(out,audio_bit_stream);
    BER=[BER,r];
end
semilogy( PathDelays,BER);

%%


BER =[];
PathDelays = 0:10:100;
for i =1: length(PathDelays);
    rayleighchan = comm.RayleighChannel(...
    'SampleRate',100e3, ...
    'PathDelays',[0 0.0001]*PathDelays(i), ...
    'AveragePathGains',[12 2], ...
    'NormalizePathGains',true, ...
    'MaximumDopplerShift',0.0000000001, ...
    'RandomStream','mt19937ar with seed', ...
    'Seed',22, ...
    'PathGainsOutputPort',true);
    audio_mod_re= rayleighchan(audio_mod);
    out=(pskDemodulator(audio_mod_re)');
    [nu,r]=biterr(out,audio_bit_stream);
    BER=[BER,r];
end
semilogy( PathDelays,BER);
title("BER vs. PathDelays");
xlabel("PathDelays")
ylabel("BER")
hold on
BER =[];
for i =1: length(PathDelays)
    rayleighchan = comm.RicianChannel(...
    'SampleRate',100e3, ...
    'PathDelays',[0 0.0001]*PathDelays(i), ...
    'AveragePathGains',[12 2], ...
    'NormalizePathGains',true, ...
    'MaximumDopplerShift',0.0000000001, ...
    'RandomStream','mt19937ar with seed', ...
    'Seed',22, ...
    'PathGainsOutputPort',true);
    audio_mod_re= rayleighchan(audio_mod);
    out=(pskDemodulator(audio_mod_re)');
    [nu,r]=biterr(out,audio_bit_stream);
    BER=[BER,r];
end
semilogy( PathDelays,BER);


    