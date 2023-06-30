clc; close all; clear;
% 创建15x15的方格地图
map = ones(15, 15);

% 设置拿取货物和接受任务的区域
pickupLocations = [[2,2]; [2,4]; [2,6]; [2,8]; [2,10]; [2,12]; [2,14]];


% 设置充电区域
chargingStations = [[4,1]; [4,15]; [8,1]; [8,15]; [12,1]; [12,15]];
chargingOccupy = zeros(6,1);

% 设置当前位置，初始为拿取获取的区域
currentLocation = pickupLocations;

% 设置货架位置
shelves = [
    [4,3]; [4,5]; [4,7]; [4,9]; [4,11]; [4,13]; [6,3]; [6,5]; [6,7]; [6,9]; [6,11]; [6,13];
    [8,3]; [8,5]; [8,7]; [8,9]; [8,11]; [8,13]; [10,3]; [10,5]; [10,7]; [10,9]; [10,11]; [10,13];
    [12,3]; [12,5]; [12,7]; [12,9]; [12,11]; [12,13]; [14,3]; [14,5]; [14,7]; [14,9]; [14,11]; [14,13]
    ];

% 设置AGV初始位置
agvPositions = pickupLocations;

% 设置任务队列，每个任务对应多个货架位置
taskQueue={};
taskL = 100;

% 设置每个单元格的占用情况，初始状态为0表示空闲
occupiedCells = zeros(15, 15);

% 设置每辆AGV的任务和状态
agvTasks = {};

agvWaitTime = zeros(7,1);

agvTasksWhich = ones(7, 1);% 当前任务的第几个点
agvStates = zeros(7, 1); % 0表示空闲，1表示忙碌,2表示忙碌但是已经算好路径了, 3表示充电中，4表示充电排队
agvChargeTime = zeros(7, 1);
agvChargeNum = 0;
agvPath = {};
agvPathLength = zeros(7,1);
agvPathNum = ones(7,1);% 走到了路径中的第几个点
agvDir = ones(7,1);% 1代表向下，2代表向右，3代表向上，4代表向左
agvWhichCharge = zeros(7,1);
agvMaxEnergy = zeros(7,1);
for i=1:7
    agvMaxEnergy(i) = i^2+200;
end
agvEnergyUsed = zeros(7,1);

% 导入任务
A = generateRandomTask(taskL);
for i=1:taskL
    taskQueue{i} = A(i,:);
end


% 开始模拟拣货过程
unFinishedTasksNum = length(taskQueue);
taskQueueNum = 1;% 目前还没被分配的任务的序号

timeCost=0;
turnTime = 0;
totalTime=0;
collsionTime = 0;

%% 将货架设置为不可通行
    for i=1:length(shelves)
        map(shelves(i,1),shelves(i,2)) = 999;
    end
    for i=1:7
        map(1,2*i)=999;
    end
   
%% 主循环
while unFinishedTasksNum>0
    timeCost=timeCost+1;
    fprintf("t=%d\n",timeCost);
%% 分配任务
    for i=1:7%遍历每一辆车
        %车是否在派发任务的地方，是否还有任务可以分配
        if IsInPlace(currentLocation(i,:), pickupLocations) && taskQueueNum <= length(taskQueue) && agvStates(i)==0
                fprintf("第%d辆小车可以分配任务捏~\n",i)
                agvTasks{i} = taskQueue{taskQueueNum};% 任务分配
                agvStates(i) = 1;% 状态改为忙碌
                taskocc(i) = taskQueueNum;
                taskQueueNum = taskQueueNum + 1;% 已安排的任务数加1
                
        end
    end

%% 计算最短路径
    for i=1:7
        if agvStates(i) == 1 % 工作状态的车才计算路径
            ep = [agvTasks{i}(agvTasksWhich(i),1),agvTasks{i}(agvTasksWhich(i),2)];% 获取终点
            sp = [currentLocation(i,1), currentLocation(i,2)];% 获取起点
            [agvPath{i}, pl] = Djk(map, sp, ep);
            if isempty(agvPath{i})
                fprintf("空！\n");
                return;
            end
            agvPathNum(i) = 1;
            agvStates(i) = 2;
        end
    end


%% 走路与碰撞处理
    for i=1:7
        if agvStates(i) == 2 % 忙碌
            % 无碰撞，继续走
            agvEnergyUsed(i) = agvEnergyUsed(i) +1;
            if IsCollision(i,agvPath{i}(agvPathNum(i),:),currentLocation) == false
                % 判断方向
                dir = getDirection(currentLocation(i,:),agvPath{i}(agvPathNum(i),:));
                if dir~=1 && dir~=2 && dir~=3 && dir~=4
                    fprintf("问题！\n");
                    return;
                end
                turn = isNeedTurn(agvDir(i),dir);
                if turn == true % 需要转方向
                    [check, agvDir(i)] = doTurn(agvDir(i),dir);
                    if check==false
                        fprintf("转弯出错！！！\n");
                        return;
                    end
                    fprintf("第%d辆小车转个头~\n",i)
                    turnTime = turnTime+1;
                    continue
                end


                currentLocation(i,:)= agvPath{i}(agvPathNum(i),:);
                agvPathNum(i) = agvPathNum(i)+1 ;
                agvPathLength(i) = agvPathLength(i) + 1;
            else % 发生碰撞，重新规划路径
                 fprintf("第%d辆小车要与别的小车相撞了！\n",i);
                 %collsionTime = collsionTime+1;
                 currentLocation;
                agvIndex = getAgvIndex(currentLocation, agvPath{i}(agvPathNum(i),:));
                if agvStates(agvIndex) == 2 %对方小车在运行状态
                    collsionTime = collsionTime+1;
                    agvStates(i) = 4;% 本小车进入等待状态
                    agvWaitTime(i) = 3;
                elseif agvStates(agvIndex) == 0 %对方小车在起点不动
                    sp = [currentLocation(i,1), currentLocation(i,2)];
                    ep = [agvTasks{i}(agvTasksWhich(i),1),agvTasks{i}(agvTasksWhich(i),2)];
                    [agvPath{i}, pl] = collisionSolve(map,currentLocation,sp,ep);
                    agvPathNum(i) = 1;
                    agvPath{i}(agvPathNum(i),:);
                    if isempty(agvPath{i})
                        fprintf("空！\n");
                        return;
                    end
                elseif agvStates(i) == 4 %对方小车等待状态
                    sp = [currentLocation(i,1), currentLocation(i,2)];
                    ep = [agvTasks{i}(agvTasksWhich(i),1),agvTasks{i}(agvTasksWhich(i),2)];
                    [agvPath{i}, pl] = collisionSolve(map,currentLocation,sp,ep);
                    agvPathNum(i) = 1;
                    agvPath{i}(agvPathNum(i),:);
                    if isempty(agvPath{i})
                        fprintf("空！\n");
                        return;
                    end
                end
                agvStates(agvIndex);

            end


            %% 终点处理
            if currentLocation(i,:) ==  [agvTasks{i}(agvTasksWhich(i),1),agvTasks{i}(agvTasksWhich(i),2)]
                % 判断是否是大终点
                if currentLocation(i,:) ==  [agvTasks{i}(end,1),agvTasks{i}(end,2)]
                    % 到了大终点，分支处理
                    fprintf("第%d辆小车到了大终点\n",i)
                    if IsInPlace(currentLocation(i,:), chargingStations)% 大终点是充电站，开始充电
                        agvChargeTime(i) = ceil((agvPathLength(i)-1)/10);
                        fprintf("第%d辆小车到充电站了，充电时间为%d\n",i,agvChargeTime(i))
                        agvStates(i) = 3;

                    elseif IsInPlace(currentLocation(i,:), pickupLocations)% 大终点是分配任务的区域
                        fprintf("第%d辆小车回到分发任务的地方了！！\n",i)
                        agvStates(i) = 0;

                    else %大终点只是一个货架，为其分配到充电站
                        unFinishedTasksNum = unFinishedTasksNum - 1;
                        % 检测是否达到时间阈值
                        if agvEnergyUsed(i) > agvMaxEnergy(i)
                            % 去充电
                            fprintf("第%d辆小车的任务做完了，任务号是%d，现在要去充电站充电\n",i,taskocc(i));
                            taskfinfish(taskocc(i)) = 1;
                            freeCharge = getFreeCharge(chargingStations,chargingOccupy);
                            if isempty(freeCharge)% 充电位置满了，这辆小车给我罚站
                                fprintf("充电位置满了，第%d辆小车只能罚站了\n",i)
                                agvStates(i) = 5;% 本小车进入等待状态
                                agvWaitTime(i) = 3;
                            else
                                [ep,agvPath{i}] = getClosedCharge(map, freeCharge, currentLocation(i,:));
                                chargeIndex = getChargeIndex(ep,chargingStations);
                                agvWhichCharge(i) = chargeIndex;
                                chargingOccupy(chargeIndex) = 1;
                                %将任务设定为去充电站
                                agvTasks{i}=ep;
                                agvTasksWhich(i)=1;
                                agvStates(i) = 2;
                                agvPathNum(i)=1;
                            end
                        else
                            % 继续运行，到接任务的地方拿任务
                            fprintf("第%d辆小车电还够，暂时不充电\n",i)
                            sp = [currentLocation(i,1), currentLocation(i,2)];% 获取起点
                            ep = pickupLocations(i,:);
                            [agvPath{i},pl] = Djk(map,sp,ep);  
            
                            % 必要参数重置
                            agvTasks{i} = ep;
                            agvPathLength(i) = 0;
                            agvPathNum(i) = 1;
                            agvStates(i) = 2;
                            agvTasksWhich(i)=1;
                        end
                        
                        

                    end
                else %只是个小终点
                    fprintf("第%d辆小车到了小终点\n",i)
                    agvTasksWhich(i) = agvTasksWhich(i)+1;
                    ep = [agvTasks{i}(agvTasksWhich(i),1),agvTasks{i}(agvTasksWhich(i),2)];% 获取终点
                    sp = [currentLocation(i,1), currentLocation(i,2)];% 获取起点
                    [agvPath{i}, pl] = Djk(map, sp, ep);
                    agvPathNum(i) = 1;
                    if isempty(agvPath{i})
                        fprintf("空！\n");
                        return;
                    end
                end
            end
        
        
        
        
        
        
        elseif agvStates(i) == 4 || agvStates(i) == 5
            agvWaitTime(i) = agvWaitTime(i)-1;
            if agvWaitTime(i) == 0
                if agvStates(i)==4
                    sp = [currentLocation(i,1), currentLocation(i,2)];
                    ep = [agvTasks{i}(agvTasksWhich(i),1),agvTasks{i}(agvTasksWhich(i),2)];
    
                    [agvPath{i}, pl] = collisionSolve(map,currentLocation,sp,ep);
                    agvPathNum(i) = 1;
                    agvStates(i) = 2;
                else %这是等待充电的罚站结束了
                    fprintf("第%d辆小车的任务做完了，现在要去充电站充电\n",i);
                    freeCharge = getFreeCharge(chargingStations,chargingOccupy);
                    if isempty(freeCharge)% 充电位置满了，这辆小车给我罚站
                        fprintf("充电位置满了，第%d辆小车只能罚站了\n",i)
                        agvStates(i) = 5;% 本小车进入等待状态
                        agvWaitTime(i) = 3;
                    else
                        [ep,agvPath{i}] = getClosedCharge(map, freeCharge, currentLocation(i,:));
                        chargeIndex = getChargeIndex(ep,chargingStations);
                        chargingOccupy(chargeIndex) = 1;
                        %将任务设定为去充电站
                        agvTasks{i}=ep;
                        agvTasksWhich(i)=1;
                        agvStates(i) = 2;
                        agvPathNum(i)=1;
                    end
                end

            end
        end
        
    end



%% 充电过程
    for i=1:7%遍历每一辆车
        if IsInPlace(currentLocation(i,:), chargingStations) &&  agvStates(i)==3 % 找到正在充电的车
            agvChargeTime(i) = agvChargeTime(i)-1;
            if agvChargeTime(i) == 0
                fprintf("第%d辆小车充好电了，现在去重新接受任务\n",i);
                %分配到起点的任务
                chargeIndex = getChargeIndex(currentLocation(i,:),chargingStations);
                chargingOccupy(chargeIndex)=0;
                sp = [currentLocation(i,1), currentLocation(i,2)];% 获取起点
                ep = pickupLocations(i,:);
                [agvPath{i},pl] = Djk(map,sp,ep);  

                % 必要参数重置
                agvTasks{i} = ep;
                agvPathLength(i) = 0;
                agvPathNum(i) = 1;
                agvStates(i) = 2;
                agvTasksWhich(i)=1;
                totalTime=totalTime+agvEnergyUsed(i);
                agvEnergyUsed(i)=0;
            end
        end
    end


end

fprintf("\n任务完成！！！！！！！！！！！！！！！\n")




currentLocation
timeCost
%map

