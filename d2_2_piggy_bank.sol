pragma solidity ^0.8.0;

contract DeFiPiggyBank {
    address public kid;
    uint private balances;

    constructor() {
        kid = msg.sender;
    }

    function deposit() public payable {
        balances += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(msg.sender == kid, "Only kid can withdraw");
        require(amount <= balances, "Insufficient balance");
        payable(kid).transfer(amount);
        balances -= amount;
    }

    function balance() public view returns (uint256) {
        return balances;
    }
}
