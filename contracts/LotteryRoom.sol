pragma solidity ^0.4.18;

import './ValueBonusFeature.sol';

contract LotteryRoom is ValueBonusFeature {
 
  bool public finished;

  uint public percentRate = 100;

  uint public start;

  uint public end;

  uint public feePercent;

  uint public fee;
 
  uint public membersLimit;

  uint public membersCount;

  mapping ( address => uint ) public valueRates;
 
  mapping ( address => uint ) public invested;

  mapping ( address => uint ) public investedClean;

  mapping ( address => uint ) public rewards;
  
  address[] members;

  function finish() public onlyOwner {
    finished = true;
  }

  function setMembersLimit(uint newMembersLimit) public onlyOwner notLocked {
    require(newMembersLimit > 0);
    membersLimit = newMembersLimit;
  }

  function setPercentRate(uint newPercentRate) public onlyOwner notLocked {
    percentRate = newPercentRate;
  }

  function setFeePercent(uint newFeePercent) public onlyOwner notLocked {
    feePercent = newFeePercent;
  }

  function setStart(uint newStart) public onlyOwner notLocked {
    start = newStart;
  }

  function setEnd(uint newEnd) public onlyOwner notLocked {
    end = newEnd;
  }

  modifier checkLimits() {
    require(now >= start && now < end && membersCount < membersLimit && !finished);
    _;
  }

  function refundFee(address to) public {
    require(finished);
    to.transfer(fee);
  }

  function setRewards(address[] addresses, uint[] values) {
    require(locked && !finished);
    for(uint i = 0; i < addresses.length; i++) {
      rewards[addresses[i]] = values[i];
    }
  }

  function setReward(address to, uint value) {
    require(locked && !finished);
    rewards[to] = value;
  }

  function refund() public {
    require(finished && rewards[msg.sender] > 0);
    msg.sender.transfer(rewards[msg.sender]);
  }

  function fallback() internal checkLimits {
    if(invested[msg.sender] == 0) {
       membersCount = membersCount.add(1);
       members.push(msg.sender);
    }
    invested[msg.sender] = invested[msg.sender].add(msg.value);
    uint personFee = msg.value.mul(feePercent).div(percentRate);
    fee = fee.add(personFee);
    uint personInvestedClean = msg.value.sub(personFee);
    investedClean[msg.sender] = invested[msg.sender].add(personInvestedClean);
    valueRates[msg.sender] = getValueBonusIndex(invested[msg.sender]);
  }

  function () public payable {
    fallback();
  }

}
