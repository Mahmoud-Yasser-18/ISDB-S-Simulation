clear 
clc
signal = '010000';
[mod, time_mod] = PSK(signal ,8, 1, 1, 100, 5);
[Constellation_x,Constellation_y]=QAMConstellation(mod, 1, 100, 5);
out = ML_reciver_vector(Constellation_x,Constellation_y,"8PSK");
disp(out)