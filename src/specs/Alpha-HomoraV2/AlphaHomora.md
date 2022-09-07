# Aztec Connect Bridges AlphaHomoraV2

_Help the Aztec community make Aztec Connect easier to build on and interact with by documenting your work.
This spec template is meant to help you provide all of the information that a developer needs to work with your bridge.
Complete specifications will be linked in the official Aztec docs at https://docs.aztec.network._



1. What does this bridge do? Why did you build it?
Multi assets lending and borrowing (with huge leverage for stablecoin farming!)
More farming pools beyond just Uniswap (think Balancer, Curve, etc)
No more EOA only = more composability
You can bring your own LP tokens 
Native flashloan support
3. Alpha Homora v2 is an upgrade from Alpha Homora v1, a leveraged yield-farming product. Here are some key features:

In v2, other assets are borrow-able (not only ETH like in v1), including stablecoins like USDT, USDC, DAI.
In v2, users may also borrow supported LP tokens to farm more.
Users can also bring their own LP tokens and add on to their positions.
Each "spell" defines how the protocol interacts with farming pools, e.g. Uniswap spell, Sushiswap spell, Curve spell.
Spell functions include e.g. addLiquidity, removeLiquidity.

![Alpha2](https://user-images.githubusercontent.com/14319303/188976156-4da479d3-ad76-4302-b11a-d70e98d411e1.svg)

2. What protocol(s) does the bridge interact with?
UniSwap, Curve, Sushiswap

HomoraBank
Store each position's collateral tokens (in the form of wrapped LP tokens)
Users can execute "spells", e.g. opening a new position, closing/adjusting existing position.
Caster
Intermediate contract that just calls another contract function (low-level call) with provided data (instead of bank), to prevent attack.
Doesn't store any funds
Spells (e.g. Uniswap/Sushiswap/Curve/...)
Define how to interact with each pool
![4](https://user-images.githubusercontent.com/14319303/188457047-384aa937-05f2-4652-acb8-4545e0855695.svg)


Execute borrow/repay assets by interacting with the bank, which will then interact with the lending protocol.


3. What is the flow of the bridge?
User -> HomoraBank. User calls execute to HomoraBank, specifying which spell and function to use, e.g. addLiquidity using Uniswap spell.
HomoraBank -> Caster. Forward low-level spell call to Caster (doesn't hold funds), to prevent attacks.
Caster -> Spell. Caster does low-level call to Spell.
Spell may call HomoraBank to e.g. doBorrow funds, doTransmit funds from users (so users can approve only the bank, not each spell), doRepay debt. Funds are then sent to Spell, to execute pool interaction.
Spells -> Pools. Spells interact with Pools (e.g. optimally swap before supplying to Uniswap, or removing liquidity from the pool and pay back some debts).
(Optional) Stake LP tokens in wrapper contracts (e.g. WMasterChef for Sushi, WLiquidityGauge for Curve, WStakingRewards for Uniswap + Balancer).
Spell may put collateral back to HomoraBank. If the spell funtion called is e.g. to open a new position, then the LP tokens will be stored in HomoraBank.

4. Please list any edge cases that may restrict the usefulness of the bridge or that the bridge prevents explicit.

5. How can the accounting of the bridge be impacted by interactions performed by other parties than the bridge? Example, if borrowing, how does it handle liquidations etc.
![cizves9](https://user-images.githubusercontent.com/14319303/188977243-2b921b00-b828-4a2e-bd12-c4acd868d39d.png)

6. What functions are available in [/src/client](./client)?

   - How should they be used?
User calls execute(0, USDT, WETH, data) on HomoraBank contract. data encodes UniswapSpell function call with arguments (including how much of each asset to supply, to borrow, and slippage control settings).
HomoraBank forwards data call to Caster.
Caster does low-level call (with data, which encodes addLiquidity function call with arguments) to UniswapSpell.
UniswapSpell executes addLiquidityWERC20
Refund leftover assets to the user.


General Properties of convert(...) function
The bridge is synchronous, and will always return isAsync = false.

The bridge uses _auxData to encode swap path. Details on the encoding are in the bridge's NatSpec documentation.

The Bridge perform token pre-approvals to allow the ROLLUP_PROCESSOR and BANK to pull tokens from it. This is to reduce gas-overhead when performing the actions. It is safe to do, as the bridge is not holding the funds itself.

7. Is the contract upgradeable?
No, the bridge is immutable without any admin role.

8. Does the bridge maintain state?
No, the bridge doesn't maintain a state. However, it keeps an insignificant amount of tokens (dust) in the bridge to reduce gas-costs of future transactions (in case the DUST was sent to the bridge). By having a dust, we don't need to do a sstore from 0 to non-zero.
