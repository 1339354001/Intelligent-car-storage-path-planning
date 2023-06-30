function [res,nextDir] = doTurn(ND,SD)
%ND nowDir现在的方向
%SD shouldDir应该的方向
    res = true;
    if ND==1
        if SD==3
            nextDir = 2;
        else
            nextDir = SD;
        end
    elseif ND==2
        if SD==4
            nextDir = 3;
        else
            nextDir = SD;
        end
    elseif ND==3
        if SD==1
            nextDir = 4;
        else
            nextDir = SD;
        end
    elseif ND==4
        if SD==2
            nextDir = 1;
        else
            nextDir = SD;
        end
    else
        res = false;
    end

end

