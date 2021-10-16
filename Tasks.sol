
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Tasks {

    uint8 newTaskId = 0;
    uint8 taskCount = 0;

    struct task {
        string name;
        uint32 timeAddition;
        bool isDone;    
    }

    mapping (uint8 => task) taskList;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier checkOwnerAndAccept 
    {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }

    function addTask(string taskName) public checkOwnerAndAccept 
    {
        taskList[newTaskId] = task(taskName, now, false);
        newTaskId++;
        taskCount++;
    }

    function openTaskNumber() public view checkOwnerAndAccept returns (uint8) 
    {
        uint8 num = 0;
        for (uint8 i = 0; i < newTaskId; i++)
            if(taskList.exists(i) && !taskList[i].isDone)
                num++;

        return num;
    }

    function getTaskList() public view checkOwnerAndAccept returns (mapping (uint8=>string))
    {
        require(taskCount > 0, 106, "There is no tasks.");
        
        mapping (uint8 => string) list;

        for (uint8 i = 0; i < newTaskId; i++)
        {
            if(taskList.exists(i))
                list[i] = taskList[i].name;
        }

        return list;
    }

    function getTaskDescription(uint8 taskId) public view checkOwnerAndAccept returns (task)
    {
        require(taskList.exists(taskId), 104, "Task with this id is not exist.");

        return taskList[taskId];
    }

    function deleteTask(uint8 taskId) public checkOwnerAndAccept
    {
        require(taskList.exists(taskId), 104, "Task with this id is not exist.");

        delete taskList[taskId];
        taskCount--;
    }

    function mapTaskAsDone(uint8 taskId) public checkOwnerAndAccept
    {
        require(taskList.exists(taskId), 104, "Task with this id is not exist.");
        require(!taskList[taskId].isDone, 105, "Task is already done.");
        
        taskList[taskId].isDone = true;
    }
}
