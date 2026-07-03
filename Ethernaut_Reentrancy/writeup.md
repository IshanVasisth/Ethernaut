## Reentrance

**Vulnerability:** `withdraw()` sends ETH via low-level `call` before updating the sender's balance (violates CEI — Checks-Effects-Interactions). The balance decrement happens *after* the external call, so a malicious contract's `receive()` can call `withdraw()` again before the first call's state update completes, draining more than its actual balance.

**Exploit:** Deployed an attacker contract that:
1. Funds itself into `target` via `donate{value: amount}(address(this))`
2. Calls `target.withdraw(amount)` to trigger the first payout
3. `receive()` re-enters `target.withdraw(amount)` on every incoming call, repeating until `target`'s balance is drained

**Fix 1 — CEI:** decrement balance before external call.

**Fix 2 — ReentrancyGuard:**
```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
function withdraw(uint amount) public nonReentrant { ... }
```

**Fix 3 — Pull Payment:** don't push ETH in `withdraw`; just record `payments[msg.sender] += amount`, user claims via separate `withdrawPayment()` call. No external call inside state-changing logic → no reentrancy surface.
