function res = isNeedTurn(ND,SD)
%ND nowDir现在的方向
%SD shouldDir应该的方向
    if ND==SD
        res = false;
    else
        res = true;
    end
end

