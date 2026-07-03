# Ethernaut level 12 - Privacy
This contract has an `unlock` function which only opens when we pass the correct key.

# Exploit
The contract stores the key onchain as a private bytes32[3] array and the `unlock` function key is the 2nd index of the stored array. We can read the respective storage slot through terminal using the given code:
```javascript
await web3.eth.getStorageAt(instance, 5)
```
which returns a bytes32 but the unlock function typecasts it to bytes16 so we remove the last 16 bytes from the obtained hex value and call the `unlock` function and the `locked` bool returns false.
