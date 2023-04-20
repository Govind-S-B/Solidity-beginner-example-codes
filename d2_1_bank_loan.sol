pragma solidity ^0.8.0;

contract Lending {
    mapping(address => uint256) private balances;
    mapping(address => uint256) private loans;
    
    uint256 private constant INTEREST_RATE = 5; // 5% interest rate per year
    
    event Deposit(address indexed account, uint256 amount);
    event Borrow(address indexed account, uint256 amount);
    event Repayment(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);
    
    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    function borrow(uint256 amount) public {
        require(amount > 0, "Invalid loan amount");
        require(loans[msg.sender] == 0, "Already has a loan");
        require(amount <= getCreditLimit(msg.sender), "Loan amount exceeds credit limit");
        loans[msg.sender] = amount;
        balances[msg.sender] += amount;
        emit Borrow(msg.sender, amount);
    }
    
    function repay(uint256 amount) public {
        require(amount > 0, "Invalid repayment amount");
        require(loans[msg.sender] > 0, "No active loan");
        require(amount <= getRepaymentAmount(msg.sender), "Repayment amount exceeds outstanding loan balance");
        loans[msg.sender] -= amount;
        balances[msg.sender] -= amount;
        emit Repayment(msg.sender, amount);
    }
    
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
    
    function getCreditLimit(address account) public view returns (uint256) {
        return balances[account] / 2 - loans[account];
    }
    
    function getLoanStartTime(address account) public view returns (uint256) {
        return block.timestamp;
    }
    
    function getRepaymentAmount(address account) public view returns (uint256) {
        uint256 interest = (block.timestamp - getLoanStartTime(account)) * INTEREST_RATE / 31536000; // 1 year = 31536000 seconds
        return loans[account] + interest;
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    
    function getLoan() public view returns (uint256) {
        return loans[msg.sender];
    }
}
