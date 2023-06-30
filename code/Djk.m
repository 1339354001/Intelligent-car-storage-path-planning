function [path, pl] = Djk(map, sp, ep)
    % 检查输入参数
    if ~isequal(size(map), [15, 15])
        error('地图大小不正确，请提供一个15x15的数组图。');
    end
    
    % 设置起点和终点的坐标
    sp_row = sp(1);
    sp_col = sp(2);
    ep_row = ep(1);
    ep_col = ep(2);
    
    % 检查起点和终点的坐标是否在有效范围内
    if ~isValidCoordinate(sp_row, sp_col) || ~isValidCoordinate(ep_row, ep_col)
        error('起点或终点的坐标无效。');
    end
    
    % 初始化距离矩阵和路径矩阵
    distance = Inf(15, 15);
    distance(sp_row, sp_col) = 0;
    visited = false(15, 15);
    prev = zeros(15, 15, 2);
    
    % 开始Dijkstra算法
    while true
        % 找到当前距离最小的未访问节点
        minDist = Inf;
        minDistRow = -1;
        minDistCol = -1;
        
        for i = 1:15
            for j = 1:15
                if ~visited(i, j) && distance(i, j) < minDist
                    minDist = distance(i, j);
                    minDistRow = i;
                    minDistCol = j;
                end
            end
        end
        
        % 如果找不到更小的距离，则结束算法
        if minDistRow == -1 || minDistCol == -1
            break;
        end
        
        % 标记该节点为已访问
        visited(minDistRow, minDistCol) = true;
        
        % 检查是否达到终点
        if minDistRow == ep_row && minDistCol == ep_col
            break;
        end
        
        % 更新相邻节点的距离
        neighbors = getNeighbors(minDistRow, minDistCol);
        for k = 1:size(neighbors, 1)
            neighborRow = neighbors(k, 1);
            neighborCol = neighbors(k, 2);
            
            if ~visited(neighborRow, neighborCol)
                newDist = distance(minDistRow, minDistCol) + map(neighborRow, neighborCol);
                
                if newDist < distance(neighborRow, neighborCol)
                    distance(neighborRow, neighborCol) = newDist;
                    prev(neighborRow, neighborCol, 1) = minDistRow;
                    prev(neighborRow, neighborCol, 2) = minDistCol;
                end
            end
        end
    end
    
    % 构建最短路径
    path = [];
    currentRow = ep_row;
    currentCol = ep_col;
    
    while true
        if currentRow == sp_row && currentCol == sp_col
            break;
        end
        
        path = [path; [currentRow, currentCol]];
        
        prevRow = prev(currentRow, currentCol, 1);
        prevCol = prev(currentRow, currentCol, 2);
        
        currentRow = prevRow;
        currentCol = prevCol;
    end
    
    % 翻转路径数组，使得终点到起点的顺序正确
    path = flipud(path);
    
    % 计算总长度，不包括终点ep的权重
    pl = distance(ep_row, ep_col) - map(ep_row, ep_col);
end

function isValid = isValidCoordinate(row, col)
    isValid = (row >= 1 && row <= 15) && (col >= 1 && col <= 15);
end

function neighbors = getNeighbors(row, col)
    neighbors = [row-1, col; row+1, col; row, col-1; row, col+1];
    validIndices = neighbors(:, 1) >= 1 & neighbors(:, 1) <= 15 & ...
        neighbors(:, 2) >= 1 & neighbors(:, 2) <= 15;
    neighbors = neighbors(validIndices, :);
end
