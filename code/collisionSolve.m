function [path,pl] = collisionSolve(map, currentLocation, sp,ep)
%COLLISIONSOLVE 此处显示有关此函数的摘要
%   此处显示详细说明
    for i=1:7
        map(currentLocation(i,1),currentLocation(i,2))=999;
    end
    [path,pl] = Djk(map,sp,ep);
end

