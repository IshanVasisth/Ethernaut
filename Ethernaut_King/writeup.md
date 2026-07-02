# Ethernaut Level 9 - King
King contract is a fun game where the deployer of the contract is set as the king and the value of eth deposited is set as the prize. To dethrone the king, user has to deposit ETH more than prize. The 'receive()' function checks if 'msg.value' is more than 'prize' and then dethrones the king transferring the amount of eth sent by the user to the previous king giving him some extra eth.

# Goal of the exploit
When we submit the instance, the goal was to avoid the owner from taking back his throne.

# Exploit
If the calling contract doesn't have a receive or a fallback function any eth transferred to the contract will revert and the transaction won't pass hence barring the owner from taking back the throne.
