function index = getAgvIndex(currentLocation, np)
    index = -1;
    for i=1:7
        if np == currentLocation(i,:)
            index = i;
        end
    end
end

