function [ep, path] = getClosedCharge(map, chargeLocation, sp)
    % 初始化最小距离为无穷大
    minDist = Inf;
    % 初始化最小距离对应的终点和路径
    ep = [];
    path = [];
    
    % 遍历所有可能的终点
    for i = 1:length(chargeLocation)
        % 调用 Djk 函数计算从起点到当前终点的最短路径和距离
        [curPath, curDist] = Djk(map, sp, chargeLocation{i});
        
        % 如果当前距离比最小距离小，则更新最小距离和对应的终点和路径
        if curDist < minDist
            minDist = curDist;
            ep = chargeLocation{i};
            path = curPath;
        end
    end
end
