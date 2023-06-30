function index = getChargeIndex(ep, charingLocation)
    index = -1;
    for i=1:6
        if ep==charingLocation(i,:)
            index = i;
            return;
        end
    end

end

