function res = IsCollision(whichagv ,nextp, currentp)
    for i=1:7
        if i == whichagv
            continue;
        else
            if nextp == currentp(i,:)
                res = true;
                return;
            end
        end
    end
    
    res = false;
end

