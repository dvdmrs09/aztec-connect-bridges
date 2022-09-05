// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Aztec.
pragma solidity >=0.6.12>=0.8.4;


import "./UniswapV2SpellV1_flat.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {AztecTypes} from "../../aztec/libraries/AztecTypes.sol";
import {IRollupProcessor} from "../../aztec/interfaces/IRollupProcessor.sol";
import {ErrorLib} from "../base/ErrorLib.sol";
import {BridgeBase} from "../base/BridgeBase.sol";

/**
 * @title An example bridge contract.
 * @author Aztec Team
 * @notice You can use this contract to immediately get back what you've deposited.
 * @dev This bridge demonstrates the flow of assets in the convert function. This bridge simply returns what has been
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

    struct AmountInStruct {
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
    address public constant spell = 0x00b1a4E7F217380a7C9e6c12F327AC4a1D9B6A14;
   

    /**
     * @notice Set address of rollup processor
     * @param _rollupProcessor Address of rollup processor
     *
     */
    constructor(address _rollupProcessor) BridgeBase(_rollupProcessor) {}

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
            unchecked {
                ++i;
            }
        }
        tokensLength = _tokensOut.length;
        for (uint256 i; i < tokensLength;) {
            address tokenOut = _tokensOut[i];
            // Using safeApprove(...) instead of approve(...) and first setting the allowance to 0 because underlying
            // can be Tether
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
         { if (_auxData == 0) {
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

                   
       
      
        }
    
}
