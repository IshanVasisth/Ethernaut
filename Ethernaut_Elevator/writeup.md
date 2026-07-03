## Elevator

**Vulnerability:** `goTo()` calls `isLastFloor()` twice, trusting an external contract's return value both times without enforcing consistency. Since `Building` is an interface, any implementation can return different values per call.

**Exploit:** Attack contract implements `isLastFloor()` to return `false` on the first call (passes the `Elevator.floor` update check) and `true` on the second (sets `top = true`), using a state toggle (`fraud` bool) to track call count.

**Fix:** Don't trust external `view`-declared calls for critical logic — cache the result once and reuse it, or restrict which contracts can implement `Building`.
