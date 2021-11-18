function out = ML_reciver(Constellation_x,Constellation_y,type)
% ML_reciver: Maximum likelyhood reciver
% Takes the constellation of the signal and return the symbole based on the
% type of modulation by the Maximum likelyhood rule ( the output is the
% region which the constillation of the signal lies into
    if type=="BPSK"
        if Constellation_x>=0
            out=1;
        else
            out=0;
        end
    elseif type=="QPSK"
        out=[0,0];
        if Constellation_x>=0
            out(1)=1;
        else
            out(1)=0;
        end
        if Constellation_y>=0
            out(2)=1;
        else
            out(2)=0;
        end
    elseif type=="16QAM"
        out=[0,0,0,0];
        if Constellation_x>2
            out(1)=0;
            out(2)=1;
        elseif Constellation_x>0
            out(1)=1;
            out(2)=1;
        elseif Constellation_x>-2
            out(1)=1;
            out(2)=0;
        else 
            out(1)=0;
            out(2)=0;
        end
        if Constellation_y>2
            out(3)=0;
            out(4)=1;
        elseif Constellation_y>0
            out(3)=1;
            out(4)=1;
        elseif Constellation_y>-2
            out(3)=1;
            out(4)=0;
        else 
            out(3)=0;
            out(4)=0;
        end
        
       
    elseif type=="BFSK"
        if Constellation_y>Constellation_x
            out=0;
        else 
            out=1;
        end
    elseif type=="8PSK"
        out='';
        % third bit 3*pi/8
        if Constellation_y-tan(7*pi/8)*Constellation_x>0 
            out=[out,'0'];
        else
            out=[out,'1'];
        end 
                % second bit 3*pi/8
        if Constellation_y-tan(3*pi/8)*Constellation_x>0 
            out=[out,'1'];
        else
            out=[out,'0'];
        end 
                % first bit 3*pi/8
        if ((Constellation_y-tan(1*pi/8)*Constellation_x>0) &&(Constellation_y-tan(5*pi/8)*Constellation_x>0 ) ||(Constellation_y-tan(1*pi/8)*Constellation_x<0) &&(Constellation_y-tan(5*pi/8)*Constellation_x<0 ))
            out=[out,'1'];
        else
            out=[out,'0'];
        end 

    end 
    
end
