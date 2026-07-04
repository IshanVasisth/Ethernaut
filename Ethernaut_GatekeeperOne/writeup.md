# Ethernaut #13 — GatekeeperOne

## Vulnerability
`enter()` is gated by three modifiers, each exploitable:

- **gateOne**: `msg.sender != tx.origin` — beaten by calling through an intermediate contract instead of an EOA.
- **gateTwo**: `gasleft() % 8191 == 0` — requires the *exact* gas remaining at that opcode to be a multiple of 8191. The caller can't predict this precisely because of call overhead (CALL opcode cost, calldata decoding, EIP-150's 63/64 forwarding rule).
- **gateThree**: bytes8 key must satisfy:
  - `uint32(key) == uint16(key)` → upper 16 bits of the lower 32 must be zero
  - `uint32(key) != uint64(key)` → upper 32 bits of the full key must be non-zero
  - `uint32(key) == uint16(tx.origin)` → lower 16 bits must match caller's address

## Exploit
- **gateOne**: call `enter()` from an attack contract, not directly.
- **gateThree**: construct key as `0xXXXXXXXX0000YYYY` where `YYYY` = last 2 bytes of `tx.origin` and `XXXXXXXX` is any non-zero value.
- **gateTwo**: can't compute the exact remainder analytically (unknown fixed overhead between gas specified and gas seen at the check). Instead, brute-force by looping over 8191 *consecutive* absolute gas values in a low-level `call`, guaranteeing one hits `% 8191 == 0`:

```solidity
for (uint256 i = 0; i < 8191; i++) {
    (bool success, ) = address(target).call{gas: baseGas + i}(
        abi.encodeWithSignature("enter(bytes8)", gatekey)
    );
    if (success) break;
}
```

`baseGas` should be set above the actual cost of one `enter()` call (measured empirically via `-vvvv` trace on a single non-loop call — here ~550k gas). Looping over *multiples* of 8191 or decrementing from `gasleft()` doesn't work — both fail to scan all residues mod 8191 due to overhead and EIP-150 gas-forwarding caps.

## Fix
Gas-dependent access control has no place in production contracts — `gasleft()` is not a secure randomness or gating mechanism; it's fully manipulable by the caller. Real gating should rely on role checks, signatures, or commit-reveal schemes, not incidental EVM gas accounting.

## Tools
Foundry (`forge create`, `cast send -vvvv` for trace inspection)
