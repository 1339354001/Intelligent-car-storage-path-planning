function res = IsInPlace(CL, place)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
    for i=1:length(place)
        if CL==place(i,:)
            res = true;
            return;
        end
    end
    res = false;
end

