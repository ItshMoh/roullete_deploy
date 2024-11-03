// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MoneyPool {
    address public owner;
    uint public poolEndTime;
    uint public poolBalance;
    mapping(address => uint) public contributionsNumber; //map for the amount donated by each participants in the resepective game.
    mapping(address => uint) public contributionsColor;
    mapping(address => uint) public contributionsEvenOdd;

    mapping(address => uint) public choiceNumber; // map for the choice made by the participant in the respective game.
    mapping(address => uint) public choiceColor;
    mapping(address => uint) public choiceEvenOdd;

    enum BetType { Number, Color, EvenOdd }
    struct Bet {
        address player;
        BetType betType;
        uint choice; // can represent number, color, or even/odd choice
        uint amount;
    }
    address[] internal contributorsNumber; // list of contributors for the number game
    address[] internal contributorsColor; // list of contributors for the color game.
    address[] internal contributorsEvenOdd; // list of contributors  for the even odd game.

    Bet[] internal bets;
    

    

    event PoolOpened(uint endTime);
    event ContributionReceived(address indexed player, uint amount);
    event BetPlaced(address indexed player, BetType betType, uint choice, uint amount);
    event Payout(address indexed winner, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier poolOpen() {
        require(block.timestamp < poolEndTime, "Pool is closed for new contributions");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
    function resetPool() internal {
        poolBalance = 0;
        // Reset all contributors arrays
        delete contributorsNumber;
        
        // Reset all mappings
        for(uint i = 0; i < contributorsNumber.length; i++) {
            address contributor = contributorsNumber[i];
            contributionsNumber[contributor] = 0;
            choiceNumber[contributor] = 0;
            
        
        delete bets;
        poolEndTime = 0;
    }
    }

    function openPool(uint duration) external  {
        poolEndTime = block.timestamp + duration;
        emit PoolOpened(poolEndTime);
    }

    function placeBet(BetType betType, uint8 choice,uint8 amount) public  payable {
        require(amount > 0, "Bet amount must be more than 0");
      
        // Store the bet information
        bets.push(Bet({
            player: msg.sender,
            betType: betType,
            choice: choice,
            amount: amount
        }));

        // Update pool and contributions
        if(betType== BetType.Number){
          contributionsNumber[msg.sender] += amount;
          choiceNumber[msg.sender] = choice;
          contributorsNumber.push(msg.sender);
        }
        else if(betType== BetType.Color){
            contributionsColor[msg.sender] += amount;
            choiceColor[msg.sender] = choice;
            contributorsColor.push(msg.sender);
        }
        else if(betType== BetType.EvenOdd){
            contributionsEvenOdd[msg.sender] += amount; 
            choiceEvenOdd[msg.sender] = choice;
            contributorsEvenOdd.push(msg.sender);
        }

        poolBalance += amount;
        
        emit BetPlaced(msg.sender, betType, choice, amount);
    }

    function payout(address winner, uint amount) internal {
        require(amount <= poolBalance, "Insufficient funds in the pool");
        payable(winner).transfer(amount);
        poolBalance -= amount;
        emit Payout(winner, amount);
    }
}

