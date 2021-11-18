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
audio=audio(1:1000);
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
% ----- Audio modulation
% [audio_mod, time_audio_mod] = PSK(audio_bit_stream,8, 1, 1, 1000, 100);
% % ----- Video modulation
[video_mod, time_video_mod] = PSK(video_bit_stream,8, 1, 1, 30, 5);


    %%

rayleighchan = comm.RayleighChannel(...
    'SampleRate',30, ...
    'PathDelays',[0 1000], ...
    'AveragePathGains',[1 2], ...
    'NormalizePathGains',true, ...
    'MaximumDopplerShift',2, ...
    'RandomStream','mt19937ar with seed', ...
    'Seed',22, ...
    'PathGainsOutputPort',true);
video_mod_re= rayleighchan(video_mod');

%%
[Constellation_x,Constellation_y]=QAMConstellation(video_mod, 1, 30, 5);
figure;
%%
out = ML_reciver_vector(Constellation_x,Constellation_y,"8PSK");
video_decoded= Decode(out, video_levels);
video_decoded= reshape(video_decoded ,[frame_size(1),frame_size(2)]); % converting frame from NxM to 1x(M*N)
figure;
imshow(video_decoded);
