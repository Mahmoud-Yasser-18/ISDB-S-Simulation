function out = ML_reciver_vector(Constellation_x,Constellation_y,type)

out='';
for i =1: length(Constellation_x)
    out =[out,(ML_reciver(Constellation_x(i),Constellation_y(i),type))];
end 
end 
