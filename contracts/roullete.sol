// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./moneypool.sol";
import "@oasisprotocol/sapphire-contracts/contracts/Sapphire.sol";

contract RouletteGame is MoneyPool {
    MoneyPool public poolContract;
    uint public matchEndTime;
    uint public maxFeePercent = 2;
    uint public matchFee;

    event MatchScheduled(uint endTime, uint matchFee);
    event MatchEnded(address indexed winner, uint payout);
   
    address[] internal winnerNumber; // list of the winners in the number category.
    address[] internal winnerColor; // list of the winners in the color category.
    address[] internal winnerEvenOdd; // list of the winners in the even odd category.


    modifier matchOpen() {
        require(block.timestamp < matchEndTime, "Match is closed");
        _;
    }

    constructor(address _poolAddress) {
        poolContract = MoneyPool(_poolAddress);
        owner = msg.sender;
    }

    function scheduleMatch(uint duration, uint feePercent) external payable  {
        require(feePercent <= maxFeePercent, "Fee exceeds max allowed percent");
        resetPool();
        matchEndTime = block.timestamp + duration;
        matchFee = (poolContract.poolBalance() * feePercent) / 100;
        emit MatchScheduled(matchEndTime, matchFee);
    }

    
    function getRandomBytes() internal view returns (uint256){
       bytes memory randomBytes = Sapphire.randomBytes(32, "");
       return uint256(keccak256(randomBytes));
    }

    function betOnNumber  (uint8 numberchosen,uint8 amount ) public payable {
       require(block.timestamp < matchEndTime, "Match is closed");
       require((numberchosen<36),"The number must not be greater than 36");
       require((amount>0),"The amount should be greater than 2");
       placeBet(MoneyPool.BetType.Number,numberchosen, amount); 
    }

    function betOnColor  (uint8 Colorchosen,uint8 amount ) public{
       placeBet(MoneyPool.BetType.Color,Colorchosen, amount); 
    }

    function betOnParity  (uint8 paritychosen,uint8 amount ) public{
       placeBet(MoneyPool.BetType.EvenOdd,paritychosen, amount); 
    }
    
    function isNumberWinner() public returns(address) {

    uint256 randomseed = getRandomBytes();
    uint8 winningNumber = uint8(randomseed % 37); 
    
    // Clear previous winners
    delete winnerNumber;
    
    // Find all winners
    for(uint i=0; i < contributorsNumber.length; i++) {
        address tocheckAddress = contributorsNumber[i]; 
        if(choiceNumber[tocheckAddress] == winningNumber) {
            winnerNumber.push(tocheckAddress);
        }
    }

    // If no winners, return zero address
    if(winnerNumber.length == 0) {
        return address(0);
    }
    
    // If only one winner, return that winner
    if(winnerNumber.length == 1) {
        return winnerNumber[0];
    }

    // If multiple winners, find the one who bet the most
    address mainWinner = winnerNumber[0];
    uint maxBet = contributionsNumber[mainWinner];

    for(uint i = 1; i < winnerNumber.length; i++) {
        address currentAddr = winnerNumber[i];
        uint currentBet = contributionsNumber[currentAddr];
        if(currentBet > maxBet) {
            maxBet = currentBet;
            mainWinner = currentAddr;
        }
    }
    
    return mainWinner;
}

    function isColorWinner(uint number, uint choice) internal pure returns (bool) {
        
    }

    function isEvenOddWinner(uint number, uint choice) internal pure returns (bool) {
        
    }

    function calculatePayout() internal view returns (uint) { 
    require(poolBalance > 0, "Pool is empty");
    uint fee = (poolBalance * 2) / 100; // 2% fee
    return poolBalance - fee;
}

    function gameEnded() public   {
        require((block.timestamp>matchEndTime),"The match is still open");
        address winner = isNumberWinner();
        require(winner != address(0), "No winner found");
        uint amountToWinner = calculatePayout();
        payout(winner, amountToWinner);
        emit MatchEnded(winner, amountToWinner);
    }
}
