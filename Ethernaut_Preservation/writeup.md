# Ethernaut #16 — Preservation

## Vulnerability
Preservation uses `delegatecall` to two "library" contracts for timezone logic. Storage layout mismatch: Preservation's slots are `timeZone1Library, timeZone2Library, owner, storedTime`, but the library contract's `setTime` writes to its own slot 0 (`storedTime`) — when delegatecalled, that write lands on Preservation's slot 0 instead, which is `timeZone1Library`. No type checking on storage slots means any address can be written there via a delegatecall from an attacker-controlled "library".

## Exploit
1. Deploy an attack contract with matching storage layout, where slot 0 is a dummy `setTime`-callable variable that actually writes an address.
2. Call `setFirstTime(<attackContractAddress>)` — this delegatecalls into your fake lib, overwriting Preservation's `timeZone1Library` (slot 0) with your attack contract's address.
3. Call `setFirstTime(<playerAddressAsUint>)` again — now Preservation delegatecalls into *your* contract, whose `setTime` writes to slot 2 (`owner` in Preservation's layout), overwriting `owner` with the player's address.

```solidity
contract attack {
    uint256 dummy1;
    uint256 dummy2;
    uint256 dummy3;
    function setTime(uint256 fakeTimeStamp) public {
        dummy3 = fakeTimeStamp;
    }
}
```

## Fix
Never `delegatecall` into user-controllable or upgradable addresses without strict storage layout enforcement (e.g. fixed structs, unstructured storage patterns like EIP-1967). Delegatecall execution context (including storage writes) is entirely determined by slot position, not variable names — mismatched layouts = silent corruption.

## Tools
Remix IDE (Injected Provider, Sepolia)
