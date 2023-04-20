pragma solidity 0.8.10;

contract MyBank{
    mapping(address => uint) private balances;

    function deposit() external payable{
        balances[msg.sender] += msg.value;
    }

    function getBalance() public view returns (uint){
        return balances[msg.sender];
    }

    function withdraw(uint amount) public payable{
        require( balances[msg.sender] >= amount , "Insufficient Funds" );
        payable (msg.sender).transfer(amount);
        balances[msg.sender] -= amount;
    }
}