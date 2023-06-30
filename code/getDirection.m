function dir = getDirection(CL,NL)
%GETDIRECTION 此处显示有关此函数的摘要
%   此处显示详细说明
    if CL(1,2)-1 == NL(1,2) % y坐标减1等于下一个点，要往下走
        dir=1;
    elseif CL(1,1)+1 == NL(1,1) % x坐标加1等于下一个点，要往右走
        dir=2;
    elseif CL(1,2)+1 == NL(1,2) % y坐标加1等于下一个点，要往上走
        dir=3;
    elseif CL(1,1)-1 == NL(1,1) % x坐标减1等于下一个点，要往左走
        dir=4;
    end
end

