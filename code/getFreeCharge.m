function freeCharge = getFreeCharge(chargeLocation, chargeOccupy)
    freeCharge = {};
    j = 1;
    for i=1:6
        if chargeOccupy(i)==0
            freeCharge{j} = chargeLocation(i,:);
            j = j+1;
        end
    end
end

