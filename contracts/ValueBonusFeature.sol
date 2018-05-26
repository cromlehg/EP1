pragma solidity ^0.4.18;

import './math/SafeMath.sol';
import './LockedFeature.sol';

contract ValueBonusFeature is LockedFeature {

  using SafeMath for uint;

  struct ValueBonus {
    uint from;
    uint bonus;
  }

  ValueBonus[] public valueBonuses;

  modifier checkPrevBonus(uint number, uint from, uint bonus) {
    if(number > 0 && number < valueBonuses.length) {
      ValueBonus storage valueBonus = valueBonuses[number - 1];
      require(valueBonus.from < from && valueBonus.bonus < bonus);
    }
    _;
  }

  modifier checkNextBonus(uint number, uint from, uint bonus) {
    if(number + 1 < valueBonuses.length) {
      ValueBonus storage valueBonus = valueBonuses[number + 1];
      require(valueBonus.from > from && valueBonus.bonus > bonus);
    }
    _;
  }

  function addValueBonus(uint from, uint bonus) public onlyOwner checkPrevBonus(valueBonuses.length - 1, from, bonus) notLocked {
    valueBonuses.push(ValueBonus(from, bonus));
  }

  function getValueBonusIndex(uint value) public view returns(uint) {
    uint bonus = 0;
    for(uint i = 0; i < valueBonuses.length; i++) {
      if(value >= valueBonuses[i].from) {
        bonus = valueBonuses[i].bonus;
      } else {
        return i;
      }
    }
    revert();
  }

  function getValueBonus(uint value) public view returns(uint) {
    uint bonus = 0;
    for(uint i = 0; i < valueBonuses.length; i++) {
      if(value >= valueBonuses[i].from) {
        bonus = valueBonuses[i].bonus;
      } else {
        return bonus;
      }
    }
    revert();
  }

  function removeValueBonus(uint8 number) public onlyOwner notLocked {
    require(number < valueBonuses.length);

    delete valueBonuses[number];

    for (uint i = number; i < valueBonuses.length - 1; i++) {
      valueBonuses[i] = valueBonuses[i+1];
    }

    valueBonuses.length--;
  }

  function changeValueBonus(uint8 number, uint from, uint bonus) public onlyOwner checkPrevBonus(number, from, bonus) checkNextBonus(number, from, bonus) notLocked {
    require(number < valueBonuses.length);
    ValueBonus storage valueBonus = valueBonuses[number];
    valueBonus.from = from;
    valueBonus.bonus = bonus;
  }

  function insertValueBonus(uint8 numberAfter, uint from, uint bonus) public onlyOwner checkPrevBonus(numberAfter, from, bonus) checkNextBonus(numberAfter, from, bonus) notLocked {
    require(numberAfter < valueBonuses.length);

    valueBonuses.length++;

    for (uint i = valueBonuses.length - 2; i > numberAfter; i--) {
      valueBonuses[i + 1] = valueBonuses[i];
    }

    valueBonuses[numberAfter + 1] = ValueBonus(from, bonus);
  }

  function clearValueBonuses() public onlyOwner notLocked {
    require(valueBonuses.length > 0);
    for (uint i = 0; i < valueBonuses.length; i++) {
      delete valueBonuses[i];
    }
    valueBonuses.length = 0;
  }

}
