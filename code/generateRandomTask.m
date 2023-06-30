%随机生成任务落点
function A = generateRandomTask(taskL) 
A=[];
% 定义坐标
shelves = [
    [4,3]; [4,5]; [4,7]; [4,9]; [4,11]; [4,13]; [6,3]; [6,5]; [6,7]; [6,9]; [6,11]; [6,13];
    [8,3]; [8,5]; [8,7]; [8,9]; [8,11]; [8,13]; [10,3]; [10,5]; [10,7]; [10,9]; [10,11]; [10,13];
    [12,3]; [12,5]; [12,7]; [12,9]; [12,11]; [12,13]; [14,3]; [14,5]; [14,7]; [14,9]; [14,11]; [14,13]
    ];

% 随机选择坐标
for i = 1:taskL
    random_index = randi([1, 36]);
    random_coordinate = shelves(random_index, :);
    A(i,:)=random_coordinate;
%     A(i,1)=16-random_coordinate(1);                   %终止点横坐标
%     A(i,2)=16-random_coordinate(2);                   %终止点纵坐标
   
   % disp(['任务' num2str(i) ': (' num2str(A(i,1)) ', ' num2str(A(i,2)) ')']);
end
end
