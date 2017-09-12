function smoothedvec = smoothvector(inputvec,numpointstouse)
%Smoothes an arbitrary 1D column vector using 3-, 5-, 7-, 9-, or 15-point smoothing schemes

if size(inputvec,1)==1
    disp('Please input vector in column form');smoothedvec=NaN;return;
end

vecsize=size(inputvec,1);

if numpointstouse==3
    smoothedvec(1)=0.75*inputvec(1)+0.25*inputvec(2);
    for i=2:vecsize-1
        smoothedvec(i)=0.25*inputvec(i-1)+0.5*inputvec(i)+0.25*inputvec(i+1);
    end
    smoothedvec(vecsize)=0.75*inputvec(vecsize)+0.25*inputvec(vecsize-1);
elseif numpointstouse==5
    smoothedvec(1)=0.5*inputvec(1)+0.5*inputvec(2);
    smoothedvec(2)=0.25*inputvec(1)+0.5*inputvec(2)+0.25*inputvec(3);
    for i=3:vecsize-2
        smoothedvec(i)=0.1*inputvec(i-2)+0.2*inputvec(i-1)+0.4*inputvec(i)+...
            0.2*inputvec(i+1)+0.1*inputvec(i+2);
    end
    smoothedvec(vecsize-1)=0.25*inputvec(vecsize-2)+0.5*inputvec(vecsize-1)+0.25*inputvec(vecsize);
    smoothedvec(vecsize)=0.5*inputvec(vecsize)+0.5*inputvec(vecsize-1);
elseif numpointstouse==7
    smoothedvec(1)=NaN;
    smoothedvec(2)=0.25*inputvec(1)+0.5*inputvec(2)+0.25*inputvec(3);
    smoothedvec(3)=0.25*inputvec(2)+0.5*inputvec(3)+0.25*inputvec(4);
    for i=4:vecsize-3
        smoothedvec(i)=0.075*inputvec(i-3)+0.125*inputvec(i-2)+0.175*inputvec(i-1)+...
            0.25*inputvec(i)+0.175*inputvec(i+1)+0.125*inputvec(i+2)+0.075*inputvec(i+3);
    end
    smoothedvec(vecsize-2)=0.25*inputvec(vecsize-3)+0.5*inputvec(vecsize-2)+0.25*inputvec(vecsize-1);
    smoothedvec(vecsize-1)=0.25*inputvec(vecsize-2)+0.5*inputvec(vecsize-1)+0.25*inputvec(vecsize);
    smoothedvec(vecsize)=NaN;
elseif numpointstouse==9
    smoothedvec(1)=NaN;smoothedvec(2)=NaN;
    smoothedvec(3)=0.25*inputvec(2)+0.5*inputvec(3)+0.25*inputvec(4);
    smoothedvec(4)=0.25*inputvec(3)+0.5*inputvec(4)+0.25*inputvec(5);
    for i=5:vecsize-4
        smoothedvec(i)=0.04*inputvec(i-4)+0.08*inputvec(i-3)+0.12*inputvec(i-2)+0.16*inputvec(i-1)+...
            0.2*inputvec(i)+0.16*inputvec(i+1)+0.12*inputvec(i+2)+0.08*inputvec(i+3)+0.04*inputvec(i+4);
    end
    smoothedvec(vecsize-3)=0.25*inputvec(vecsize-4)+0.5*inputvec(vecsize-3)+0.25*inputvec(vecsize-2);
    smoothedvec(vecsize-2)=0.25*inputvec(vecsize-3)+0.5*inputvec(vecsize-2)+0.25*inputvec(vecsize-1);
    smoothedvec(vecsize-1)=NaN;smoothedvec(vecsize)=NaN;
elseif numpointstouse==15
    for j=1:5;smoothedvec(j)=NaN;end
    smoothedvec(6)=0.04*inputvec(2)+0.08*inputvec(3)+0.12*inputvec(4)+0.16*inputvec(5)+...
        0.2*inputvec(6)+0.16*inputvec(7)+0.12*inputvec(8)+0.08*inputvec(9)+0.04*inputvec(10);
    smoothedvec(7)=0.04*inputvec(3)+0.08*inputvec(4)+0.12*inputvec(5)+0.16*inputvec(6)+...
        0.2*inputvec(7)+0.16*inputvec(8)+0.12*inputvec(9)+0.08*inputvec(10)+0.04*inputvec(11);
    for i=8:vecsize-7
        smoothedvec(i)=0.02*inputvec(i-7)+0.03*inputvec(i-6)+0.04*inputvec(i-5)+...
            0.05*inputvec(i-4)+0.075*inputvec(i-3)+0.09*inputvec(i-2)+0.12*inputvec(i-1)+...
            0.15*inputvec(i)+0.12*inputvec(i+1)+0.09*inputvec(i+2)+0.075*inputvec(i+3)+...
            0.05*inputvec(i+4)+0.04*inputvec(i+5)+0.03*inputvec(i+6)+0.02*inputvec(i+7);
    end
    smoothedvec(vecsize-6)=0.04*inputvec(vecsize-10)+0.08*inputvec(vecsize-9)+0.12*inputvec(vecsize-8)+...
        0.16*inputvec(vecsize-7)+0.2*inputvec(vecsize-6)+0.16*inputvec(vecsize-5)+0.12*inputvec(vecsize-4)+...
        0.08*inputvec(vecsize-3)+0.04*inputvec(vecsize-2);
    smoothedvec(vecsize-5)=0.04*inputvec(vecsize-9)+0.08*inputvec(vecsize-8)+0.12*inputvec(vecsize-7)+...
        0.16*inputvec(vecsize-6)+0.2*inputvec(vecsize-5)+0.16*inputvec(vecsize-4)+0.12*inputvec(vecsize-3)+...
        0.08*inputvec(vecsize-2)+0.04*inputvec(vecsize-1);
    for j=vecsize-4:vecsize;smoothedvec(j)=NaN;end
else
    disp('Please input a valid number of points');return;
end

end

