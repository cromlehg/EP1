pragma solidity ^0.4.18;

import './ownership/Ownable.sol';

contract LockedFeature is Ownable {

  bool public locked;

  modifier notLocked() {
    require(!locked);
    _;
  }

  function lock() public onlyOwner {
    locked = true;
  }

}
