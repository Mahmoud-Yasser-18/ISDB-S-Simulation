%% Reading and Encoding:
% --- Steps:
% ----- Read Video to gray scaled frames
% ----- Convet 
% ----- Read audio sequence right
clear;
clc
video_name= "IMG_0991.MP4";
%%
% Read Audio
[audio,fs]= audioread("IMG_0991.MP4");
audio=audio(:,1);
audio=audio(40000:90000);
[audio_quantized,audio_levels] = Quantizer(audio(:,1), 2^8);
audio_bit_stream= Encode(audio_quantized, audio_levels);
%%
% Read Video
v = VideoReader(video_name);
video_vector=[];
for i =1:1
    frame = rgb2gray(readFrame(v)); % Getting each frame in order
    frame_size=size(frame); % Getting the frame size
    frame = reshape(frame ,[1,(frame_size(1))*(frame_size(2))]); % converting frame from NxM to 1x(M*N)
    video_vector=[video_vector,frame]; % Concatinating to main video vector
end

video_levels=uint8(0:255);
video_bit_stream= Encode(video_vector, video_levels);
% Encoding Done (Results: audio_bit_stream , video_bit_stream)
%% Modulation
% % ----- Video modulation
custMap=[0 2 4 6 7 5 3 1];
pskModulator = comm.PSKModulator(8,'BitInput',true, ...
    'SymbolMapping','Custom', ...
    'CustomSymbolMapping',custMap);

video_mod = pskModulator(video_bit_stream');
%% Adding Carrier

%% AWGN Channel
awgnchannel = comm.AWGNChannel('EbNo',2,'BitsPerSymbol',3);
video_mod_awgn= awgnchannel(video_mod);

figure;
scatterplot(video_mod_awgn)

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


video_mod_re= rayleighchan(video_mod);
figure;
scatterplot(video_mod_re)

%% 
% ricianchan = comm.RicianChannel(...
%     'SampleRate',1e6,...
%     'PathDelays',[0.0 0.5]*1e-6,...
%     'AveragePathGains',[0.1 0.5 ],...
%     'KFactor',0.8,...
%     'DirectPathDopplerShift',5.0,...
%     'DirectPathInitialPhase',0.5,...
%     'MaximumDopplerShift',2,...
%     'DopplerSpectrum',doppler('Bell', 8),...
%     'RandomStream','mt19937ar with seed', ...
%     'Seed',22, ...
%     'PathGainsOutputPort',true);
ricianchan = comm.RicianChannel
video_mod_ri= ricianchan(video_mod);

figure;
scatterplot(video_mod_ri)
%%
scatterplot(video_mod)

%% Demodulation
pskDemodulator = comm.PSKDemodulator(8,'BitOutput',true, ...
    'SymbolMapping','Custom', ...
    'CustomSymbolMapping',custMap);
out=(pskDemodulator(video_mod_ri)');
out = sprintf('%d', out);
video_decoded= Decode(out, video_levels);
video_decoded= reshape(video_decoded ,[frame_size(1),frame_size(2)]); % converting frame from NxM to 1x(M*N)
out = out-'0';
imshow(video_decoded);
%%
[nu,r]=biterr(out,video_bit_stream)
