
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Tasks {

    uint8 newTaskId = 0;

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
    }

    function openTaskNumber() public view checkOwnerAndAccept returns (uint8) 
    {
        uint8 num = 0;
        for (uint8 i = 0; i < newTaskId; i++)
            if(taskList[i].timeAddition != 0 && !taskList[i].isDone)
                num++;

        return num;
    }

    function getTaskList() public view checkOwnerAndAccept returns (mapping (uint8=>string))
    {
        mapping (uint8 => string) list;

        for (uint8 i = 0; i < newTaskId; i++)
        {
            if(taskList[i].timeAddition != 0)
                list[i] = taskList[i].name;
        }

        return list;
    }

    function getTaskDescription(uint8 taskId) public view checkOwnerAndAccept returns (task)
    {
        require(taskList[taskId].timeAddition != 0, 104, "Task with this id is not exist.");

        return taskList[taskId];
    }

    function deleteTask(uint8 taskId) public checkOwnerAndAccept
    {
        require(taskList[taskId].timeAddition != 0, 104, "Task with this id is not exist.");

        delete taskList[taskId];
    }

    function mapTaskAsDone(uint8 taskId) public checkOwnerAndAccept
    {
        require(taskList[taskId].timeAddition != 0, 104, "Task with this id is not exist.");
        require(!taskList[taskId].isDone, 105, "Task is already done.");
        
        taskList[taskId].isDone = true;
    }
}