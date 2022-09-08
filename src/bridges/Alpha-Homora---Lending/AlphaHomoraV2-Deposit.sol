// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Aztec.
pragma solidity >=0.6.12>=0.8.4;


import {HomoraBank} from "../../interfaces/AlphaHomora/IBank.sol"
import {ISpell} from "../../interfaces/AlphaHomora/ISpell.sol"
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {AztecTypes} from "../../aztec/libraries/AztecTypes.sol";
import {IRollupProcessor} from "../../aztec/interfaces/IRollupProcessor.sol";
import {ErrorLib} from "../base/ErrorLib.sol";
import {BridgeBase} from "../base/BridgeBase.sol";
import {ISubsidy} from "../../aztec/interfaces/ISubsidy.sol";
 /* 
 * @title AlphaHomoraV2 bridge contract.
 * @author dvdmrs09
 * @notice You can use this contract to deposit into liquidity pools and withdraw the assets.
 * @dev This bridge simply returns what has been
 * sent to it.
 */

contract AlphaHomorabridge1 is BridgeBase {
    using SafeERC20 for IERC20;
    
    error InvalidFeeTierEncoding();
    error InvalidFeeTier();
    error InvalidTokenEncoding();
    error InvalidToken();
    error InvalidPercentageAmounts();
    error InsufficientAmountOut();
    error Overflow();
    address internal constant TOKEN_ETH   = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant TOKEN_WETH  = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant TOKEN_WBTC  = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant TOKEN_DAI   = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant TOKEN_USDC  = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant TOKEN_USDT  = 0xdAC17F958D2ee523a2206206994597C13D831ec7;


    uint256 internal constant FLAG_WETH     = 0x1;
    uint256 internal constant FLAG_USDC     = 0x2;
    uint256 internal constant FLAG_DAI      = 0x4;
    uint256 internal constant FLAG_EXIT_WETH           = 0x8;

    uint256 internal constant FLAG_WETH_ACCOUNTING     = 0x10;
    uint256 internal constant FLAG_USDC_ACCOUNTING     = 0x20;
    uint256 internal constant FLAG_DAI_ACCOUNTING      = 0x40;

    uint256 internal constant FLAG_RETURN_WETH         = 0x1000;
    uint256 internal constant FLAG_RETURN_USDC         = 0x2000;
    uint256 internal constant FLAG_RETURN_DAI          = 0x4000;
    uint256 internal constant FLAG_RETURN_CUSTOM       = 0x8000;
    uint256 internal constant FLAG_RETURN_CUSTOM_SHIFT = 0x100000000000000000000;

    uint256 internal constant WRAP_FLAG_TRANSFORM_ETH_TO_WETH = 0x1;
    uint256 internal constant WRAP_FLAG_TRANSFORM_WETH_TO_ETH = 0x2;    struct AmountInStruct {
        uint256 amtAUser; // Supplied tokenA amount
        uint256 amtBUser; // Supplied tokenB amount
        uint256 amtLPUser; // Supplied LP token amount
        uint256 amtABorrow; // Borrow tokenA amount
        uint256 amtBBorrow; // Borrow tokenB amount
        uint256 amtLPBorrow; // Borrow LP token amount
        uint256 amtAMin; // Desired tokenA amount (slippage control)
        uint256 amtBMin; // Desired tokenB amount (slippage control)
    }

    struct AmountRepayStruct {
        uint256 amtLPTake; // LP amount being taken out from Homora.
        uint256 amtLPWithdraw; // LP amount that we transfer to caller (owner).
        uint256 amtARepay; // Repay tokenA amount
        uint256 amtBRepay; // Repay tokenB amount
        uint256 amtLPRepay; // Repay LP token amount
        uint256 amtAMin; // Desired tokenA amount
        uint256 amtBMin; // Desired tokenB amount
    }

    
    // @dev Event which is emitted when the output token doesn't implement decimals().
    event DefaultDecimalsWarning();

  
    IBank public constant BANK = IBank(0xba5eBAf3fc1Fcca67147050Bf80462393814E54B);
    ISpell public constant SPELL = ISpell(0x00b1a4E7F217380a7C9e6c12F327AC4a1D9B6A14);
   

    /**
     * @notice Set address of rollup processor
     * @param _rollupProcessor Address of rollup processor
     *
     */
    constructor(address _rollupProcessor, address SPELL, address BANK) BridgeBase(_rollupProcessor) {
       address dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

        uint256[] memory criterias = new uint256[](2);
        uint32[] memory gasUsage = new uint32[](2);
        uint32[] memory minGasPerMinute = new uint32[](2);

        criterias[0] = uint256(keccak256(abi.encodePacked(dai, dai)));
        criterias[1] = uint256(keccak256(abi.encodePacked(usdc, usdc)));

        gasUsage[0] = 72896;
        gasUsage[1] = 80249;

        minGasPerMinute[0] = 100;
        minGasPerMinute[1] = 150;

        // We set gas usage in the subsidy contract
        // We only want to incentivize the bridge when input and output token is Dai or USDC
        SUBSIDY.setGasUsageAndMinGasPerMinute(criterias, gasUsage, minGasPerMinute);
    }
    }

    receive() external payable {}
    /**
     * @notice Sets all the important approvals.
     * @param _tokensIn - An array of address of input tokens (tokens to later swap in the convert(...) function)
     * @param _tokensOut - An array of address of output tokens (tokens to later return to rollup processor)
     * @dev SwapBridge never holds any ERC20 tokens after or before an invocation of any of its functions. For this
     * reason the following is not a security risk and makes convert(...) function more gas efficient.
     */

    function preApproveTokens(address[] calldata _tokensIn, address[] calldata _tokensOut) external {
        uint256 tokensLength = _tokensIn.length;
        for (uint256 i; i < tokensLength;) {
            address tokenIn = _tokensIn[i];
            // Using safeApprove(...) instead of approve(...) and first setting the allowance to 0 because underlying
            // can be Tether
            IERC20(tokenIn).safeApprove(address(BANK), 0);
            IERC20(tokenIn).safeApprove(address(BANK), type(uint256).max);
            IERC20(tokenIn).safeApprove(address(SPELL), 0);
            IERC20(tokenIn).safeApprove(address(SPELL), type(uint256).max);
            IERC20(tokenIn).safeApprove(address(ROLLUP_PROCESSOR), 0);
            IERC20(tokenIn).safeApprove(address(ROLLUP_PROCESSOR), type(uint256).max);
            unchecked {
                ++i;
            }
        }
        tokensLength = _tokensOut.length;
        for (uint256 i; i < tokensLength;) {
            address tokenOut = _tokensOut[i];
            // Using safeApprove(...) instead of approve(...) and first setting the allowance to 0 because underlying
            // can be Tether
            IERC20(tokenOut).safeApprove(address(BANK), 0);
            IERC20(tokenOut).safeApprove(address(BANK), type(uint256).max);
            IERC20(tokenOut).safeApprove(address(SPELL), 0);
            IERC20(tokenOut).safeApprove(address(SPELL), type(uint256).max);
            IERC20(tokenOut).safeApprove(address(ROLLUP_PROCESSOR), 0);
            IERC20(tokenOut).safeApprove(address(ROLLUP_PROCESSOR), type(uint256).max);
            unchecked {
                ++i;
            }
        }
    }

  
    function convert(
        AztecTypes.AztecAsset calldata _inputAssetA,
        AztecTypes.AztecAsset calldata,
        AztecTypes.AztecAsset calldata _outputAssetA, 
        AztecTypes.AztecAsset calldata, 
         AztecTypes.AztecAsset calldata _inputAssetB,
        AztecTypes.AztecAsset calldata,
        AztecTypes.AztecAsset calldata _outputAssetB, 
        AztecTypes.AztecAsset calldata, 
         uint256 _totalInputValue,
        uint256 _interactionNonce,
        uint64 _auxData,
        address
    )
        external
        payable
         
        onlyRollup
        returns (
    
            uint256 outputValueA,
            uint256 outputValueB,
             uint256,
            bool

         )  
         
         // Check the input asset is ERC20
        if (_inputAssetA.assetType != AztecTypes.AztecAssetType.ERC20) revert ErrorLib.InvalidInputA();
        if (_outputAssetA.erc20Address != _inputAssetA.erc20Address) revert ErrorLib.InvalidOutputA();
        // Return the input value of input asset
        outputValueA = _totalInputValue;
        // Approve rollup processor to take input value of input asset
        IERC20(_outputAssetA.erc20Address).approve(ROLLUP_PROCESSOR, _totalInputValue);

        // Pay out subsidy to the rollupBeneficiary
        SUBSIDY.claimSubsidy(
            computeCriteria(_inputAssetA, _inputAssetB, _outputAssetA, _outputAssetB, _auxData),
            _rollupBeneficiary
        );
    }

 
}         { if (_auxData == 0) {
            // Mint
           
            address tokenAout = _outputAssetA.erc20Address;
            address tokenBout = _outputAssetB.erc20Address;
            uint256 amountAUser = outputValueA;
            uint256 amountBUser  = outputValueB;
            uint amountLPUser = 0;
            uint amountLPBorrow = 0;
            uint amountABorrow = 0;
            uint amountBBorrow = 0;
            uint amountAMin = 0;
            uint amountBMin = 0;
                 spell.delegatecall(
            abi.encodeWithSignature("addLiquidityWERC20()", tokenAout, tokenBout, (keccak256(abi.encodePacked(amountAUser, amountBUser, amountLPUser, amountABorrow, amountBBorrow, amountLPBorrow, amountAMin, amountBMin)))) 
);
               
         
        } else if (_auxData == 1) {
            // Redeem
             address _tokenA = _outputAssetA.erc20Address;
             address  _tokenB = _outputAssetB.erc20Address;
             uint amountLPTake = 0;
             uint amountLPWithdraw = 0;
             uint amountARepay = 0;
             uint amountBRepay = 0;
             uint amountLPRepay = 0;
             uint amountAMin = 0;
             uint amountBMin = 0;
            spell.delegatecall(abi.encodeWithSignature("removeLiquidityWERC20()", _tokenA, _tokenB, (keccak256(abi.encodePacked(amountLPTake, amountLPWithdraw, amountARepay, amountBRepay, amountLPRepay, amountAMin, amountBMin)))) 
            );         
        }
               
                IRollupProcessor(ROLLUP_PROCESSOR).receiveEthFromBridge{value: outputValueA}(_interactionNonce);
                 
                IRollupProcessor(ROLLUP_PROCESSOR).receiveEthFromBridge{value: outputValueB}(_interactionNonce);


    function bankCallback(bytes calldata data) external payable {eldddhzr(abi.decode(data,(uint256[])));}
    function bankCallback(
        address,
        uint wethToReturn,
        uint wbtcToReturn,
        uint daiToReturn,
        uint usdcToReturn,
        uint usdtToReturn,
        bytes calldata data
    ) external payable {
       
        eldddhzr(abi.decode(data,(uint256[])));

     
        uint256 selfBalance = address(this).balance;
        if (selfBalance > 1) {
            msg.sender.call{value:(selfBalance == msg.value ? selfBalance : selfBalance - 1)}(new bytes(0));
        }
        if (wethToReturn > 0) {
            uint256 tokenBalance = IERC20Token(TOKEN_WETH).balanceOf(address(this));
            if (tokenBalance > 1) {
                IERC20Token(TOKEN_WETH).transfer(
                    msg.sender,
                    tokenBalance == wethToReturn ? tokenBalance : tokenBalance - 1
                );
            }
        }
        if (wbtcToReturn > 0) {
            uint256 tokenBalance = IERC20Token(TOKEN_WBTC).balanceOf(address(this));
            if (tokenBalance > 1) {
                IERC20Token(TOKEN_WBTC).transfer(
                    msg.sender,
                    tokenBalance == wbtcToReturn ? tokenBalance : tokenBalance - 1
                );
            }
        }
        if (daiToReturn > 0) {
            uint256 tokenBalance = IERC20Token(TOKEN_DAI).balanceOf(address(this));
            if (tokenBalance > 1) {
                IERC20Token(TOKEN_DAI).transfer(
                    msg.sender,
                    tokenBalance == daiToReturn ? tokenBalance : tokenBalance - 1
                );
            }
        }
        if (usdcToReturn > 0) {
            uint256 tokenBalance = IERC20Token(TOKEN_USDC).balanceOf(address(this));
            if (tokenBalance > 1) {
                IERC20Token(TOKEN_USDC).transfer(
                    msg.sender,
                    tokenBalance == usdcToReturn ? tokenBalance : tokenBalance - 1
                );
            }
        }
        if (usdtToReturn > 0) {
            uint256 tokenBalance = IERC20Token(TOKEN_USDT).balanceOf(address(this));
            if (tokenBalance > 1) {
                IERC20Token(TOKEN_USDT).transfer(
                    msg.sender,
                    tokenBalance == usdtToReturn ? tokenBalance : tokenBalance - 1
                );
            }
        }
    }
    function callFunction(
        address,
        Types.AccountInfo memory,
        bytes calldata data
    ) external {
       
        eldddhzr(abi.decode(data,(uint256[])));
    }
    function executeOperation(
        address,
        uint256,
        uint256,
        bytes calldata _params
    ) external {
       
        eldddhzr(abi.decode(_params,(uint256[])));
    }
    function executeOperation(
        address[] calldata,
        uint256[] calldata,
        uint256[] calldata,
        address,
        bytes calldata params
    ) external returns (bool)
    {
      
        eldddhzr(abi.decode(params,(uint256[])));
        return true;
    }

    function uniswapV2Call(
        address,
        uint,
        uint,
        bytes calldata data
    ) external {
      
        eldddhzr(abi.decode(data,(uint256[])));
    }
    function uniswapV3FlashCallback(
        uint256,
        uint256,
        bytes calldata data
    ) external {
  
        eldddhzr(abi.decode(data,(uint256[])));
    }
    function uniswapV3MintCallback(
        uint256,
        uint256,
        bytes calldata data
    ) external {
     
        eldddhzr(abi.decode(data,(uint256[])));
    }
    function uniswapV3SwapCallback(
        int256,
        int256,
        bytes calldata data
    ) external {
    
        eldddhzr(abi.decode(data,(uint256[])));
    }
    function callbackWithReturn(address tokenToReturn, uint256 balanceToReturn, bytes calldata data) external payable {
        eldddhzr(abi.decode(data,(uint256[])));
        if (tokenToReturn != TOKEN_ETH) {
            IERC20Token(tokenToReturn).transfer(msg.sender, balanceToReturn);
        } else {
            msg.sender.call{value:balanceToReturn}(new bytes(0));
        }
    }


    // Function signature 0x00000000

    function wfjizxua(
        uint256 actionFlags,
        uint256[] calldata actionData
    ) public payable returns(int256 ethProfitDelta) {
        int256[4] memory balanceDeltas;
        balanceDeltas[0] = int256(address(this).balance - msg.value);
        if ((actionFlags & (FLAG_WETH_ACCOUNTING | FLAG_USDC_ACCOUNTING | FLAG_DAI_ACCOUNTING)) > 0) {
            // In general ACCOUNTING flags should be used only during simulation and not production to avoid wasting gas on oracle calls
            if ((actionFlags & FLAG_WETH_ACCOUNTING) > 0) {
                balanceDeltas[1] = int256(IERC20Token(TOKEN_WETH).balanceOf(address(this)));
            }
            if ((actionFlags & FLAG_USDC_ACCOUNTING) > 0) {
                balanceDeltas[2] = int256(IERC20Token(TOKEN_USDC).balanceOf(address(this)));
            }
            if ((actionFlags & FLAG_DAI_ACCOUNTING) > 0) {
                balanceDeltas[3] = int256(IERC20Token(TOKEN_DAI).balanceOf(address(this)));
            }
        }

        if ((actionFlags & (FLAG_WETH | FLAG_USDC | FLAG_DAI)) > 0) {
            // This simple logic only supports single token flashloans
            // For multiple tokens or multiple providers you should use general purpose logic using 'ape' function
            if ((actionFlags & FLAG_FLASH_DYDY_WETH) > 0) {
                uint256 balanceToFlash = IERC20Token(TOKEN_WETH).balanceOf(PROXY_DYDX);
                wrapWithDyDx(
                    TOKEN_WETH,
                    balanceToFlash - 1,
                    IERC20Token(TOKEN_WETH).allowance(address(this), ) < balanceToFlash,
                    abi.encode(actionData)
                );
            } else if ((actionFlags & FLAG_USDC) > 0) {
                uint256 balanceToFlash = IERC20Token(TOKEN_USDC).balanceOf();
                wrapWithDyDx(
                    TOKEN_USDC,
                    balanceToFlash - 1,
                    IERC20Token(TOKEN_USDC).allowance(address(this), ) < balanceToFlash,
                    abi.encode(actionData)
                );
            } else if ((actionFlags & FLAG_DAI) > 0) {
                uint256 balanceToFlash = IERC20Token(TOKEN_DAI).balanceOf();
                wrapWithDyDx(
                    TOKEN_DAI,
                    balanceToFlash - 1,
                    IERC20Token(TOKEN_DAI).allowance(address(this), ) < balanceToFlash,
                    abi.encode(actionData)
                );
            }
        } else {
            eldddhzr(actionData);
        }

        if ((actionFlags & FLAG_EXIT_WETH) > 0) {
            uint wethbalance = IERC20Token(TOKEN_WETH).balanceOf(address(this));
            if (wethbalance > 1) WETH9(TOKEN_WETH).withdraw(wethbalance - 1);
        }


        uint selfBalance = address(this).balance;
        if (selfBalance > 1 && msg.sender != address(this)) {
            msg.sender.call{value:selfBalance - 1}(new bytes(0));
        }
        if ((actionFlags & (FLAG_RETURN_WETH | FLAG_RETURN_USDC | FLAG_RETURN_DAI | FLAG_RETURN_CUSTOM)) > 0 && msg.sender != address(this)) {
            // Majority of simple atomic arbs should just need ETH
            if ((actionFlags & FLAG_RETURN_WETH) > 0) {
                uint tokenBalance = IERC20Token(TOKEN_WETH).balanceOf(address(this));
                if (tokenBalance > 1) IERC20Token(TOKEN_WETH).transfer(msg.sender, tokenBalance - 1);
            }
            if ((actionFlags & FLAG_RETURN_USDC) > 0) {
                uint tokenBalance = IERC20Token(TOKEN_USDC).balanceOf(address(this));
                if (tokenBalance > 1) IERC20Token(TOKEN_USDC).transfer(msg.sender, tokenBalance - 1);
            }
            if ((actionFlags & FLAG_RETURN_DAI) > 0) {
                uint tokenBalance = IERC20Token(TOKEN_DAI).balanceOf(address(this));
                if (tokenBalance > 1) IERC20Token(TOKEN_DAI).transfer(msg.sender, tokenBalance - 1);
            }
            if ((actionFlags & FLAG_RETURN_CUSTOM) > 0) {
                address tokenAddr = address(uint160(actionFlags / FLAG_RETURN_CUSTOM_SHIFT));
                if (tokenAddr != TOKEN_ETH) {
                    // We've already returned ETH above
                    uint tokenBalance = IERC20Token(tokenAddr).balanceOf(address(this));
                    if (tokenBalance > 1) IERC20Token(tokenAddr).transfer(msg.sender, tokenBalance - 1);
                }
            }
        }
    }

    // Function signature 0x0000000f
    function eldddhzr(uint256[] memory actionData) public {
        ape(actionData);

        if ((actionData[0] & (WRAP_FLAG_TRANSFORM_ETH_TO_WETH | WRAP_FLAG_TRANSFORM_WETH_TO_ETH)) > 0) {
            uint256 wrapFlags = actionData[0];
            if ((wrapFlags & WRAP_FLAG_TRANSFORM_WETH_TO_ETH_AFTER_APE) > 0) {
                uint wethbalance = IERC20Token(TOKEN_WETH).balanceOf(address(this));
                if (wethbalance > 1) WETH9(TOKEN_WETH).withdraw(wethbalance - 1);
            
                   
                }
            } else {
                uint selfBalance = address(this).balance;
                if ((wrapFlags & WRAP_FLAG_PAY_COINBASE) > 0) {
                    uint amountToPay = wrapFlags / WRAP_FLAG_PAY_COINBASE_BIT_SHIFT;
                    if (selfBalance < amountToPay) {
                        WETH9(TOKEN_WETH).withdraw(amountToPay - selfBalance);
                        selfBalance = 0;
                    } else {
                        selfBalance -= amountToPay;
                    }
                    
                }
                if (((wrapFlags & WRAP_FLAG_TRANSFORM_ETH_TO_WETH) > 0) && selfBalance > 1) {
                    WETH9(TOKEN_WETH).deposit{value: selfBalance - 1}();
                }
            }
        }
    }

    function wrap(uint256[] memory data) internal {
        // data[0] was used for wrapFlags inside 0x0000000f function
        uint callId = 1;
        for (; callId < data.length;) {
            assembly {
                let callInfo := mload(add(data, mul(add(callId, 1), 0x20)))
                let callLength := and(div(callInfo, 0x1000000000000000000000000000000000000000000000000000000), 0xffff)
                let p := mload(0x40)   // Find empty storage location using "free memory pointer"
                // Place signature at begining of empty storage, hacky logic to compute shift here
                let callSignDataShiftResult := mul(and(callInfo, 0xffffffff0000000000000000000000000000000000000000000000), 0x10000000000)
                switch callSignDataShiftResult
                case 0 {
                    callLength := mul(callLength, 0x20)
                    callSignDataShiftResult := add(data, mul(0x20, add(callId, 3)))
                    for { let i := 0 } lt(i, callLength) { i := add(i, 0x20) } {
                        mstore(add(p, i), mload(add(callSignDataShiftResult, i)))
                    }
                }
                default {
                    mstore(p, callSignDataShiftResult)
                    callLength := add(mul(callLength, 0x20), 4)
                    callSignDataShiftResult := add(data, sub(mul(0x20, add(callId, 3)), 4))
                    for { let i := 4 } lt(i, callLength) { i := add(i, 0x20) } {
                        mstore(add(p, i), mload(add(callSignDataShiftResult, i)))
                    }
                }

                mstore(0x40, add(p, add(callLength, 0x20)))
                // new free pointer position after the output values of the called function.

                let callContract := and(callInfo, 0xffffffffffffffffffffffffffffffffffffffff)
                // Re-use callSignDataShiftResult as success
                switch and(callInfo, 0xf000000000000000000000000000000000000000000000000000000000000000)
                case 0x1000000000000000000000000000000000000000000000000000000000000000 {
                    callSignDataShiftResult := delegatecall(
                                    and(div(callInfo, 0x10000000000000000000000000000000000000000), 0xffffff), // allowed gas to use
                                    callContract, // contract to execute
                                    p,    // Inputs are at location p
                                    callLength, //Inputs size
                                    p,    //Store output over input
                                    0x20) //Output is 32 bytes long
                }
                default {
                    callSignDataShiftResult := call(
                                    and(div(callInfo, 0x10000000000000000000000000000000000000000), 0xffffff), // allowed gas to use
                                    callContract, // contract to execute
                                    mload(add(data, mul(add(callId, 2), 0x20))), // wei value amount
                                    p,    // Inputs are at location p
                                    callLength, //Inputs size
                                    p,    //Store output over input
                                    0x20) //Output is 32 bytes long
                }

                callSignDataShiftResult := and(div(callInfo, 0x10000000000000000000000000000000000000000000000000000000000), 0xff)
                if gt(callSignDataShiftResult, 0) {
                    // We're copying call result as input to some futher call
                    mstore(add(data, mul(callSignDataShiftResult, 0x20)), mload(p))
                }
                callId := add(callId, add(and(div(callInfo, 0x1000000000000000000000000000000000000000000000000000000), 0xffff), 2))
                mstore(0x40, p) // Set storage pointer to empty space
            }
        }
    }

  
       
         /**
     * @notice Computes the criteria that is passed when claiming subsidy.
     * @param _inputAssetA The input asset
     * @param _outputAssetA The output asset
     * @return The criteria
     */
    function computeCriteria(
        AztecTypes.AztecAsset calldata _inputAssetA,
        AztecTypes.AztecAsset calldata,
        AztecTypes.AztecAsset calldata _outputAssetA,
        AztecTypes.AztecAsset calldata,
        uint64
    ) public view override(BridgeBase) returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_inputAssetA.erc20Address, _outputAssetA.erc20Address)));
    }
        }
    
}
