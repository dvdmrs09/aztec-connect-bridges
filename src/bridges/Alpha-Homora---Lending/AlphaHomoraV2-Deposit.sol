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

  
    struct Path {
        address tokenA;
        address tokenB;       
        bytes AmountsInStruct;
    }

    struct SplitPath {
    address tokenA;
    address tokenB;
        bytes AmountRepayStruct;
    }

    struct AmountsInStruct {
        uint256 amountAUser; // Supplied tokenA amount
        uint256 amountBUser; // Supplied tokenB amount
        uint256 amountLPUser; // Supplied LP token amount
        uint256 amountABorrow; // Borrow tokenA amount
        uint256 amountBBorrow; // Borrow tokenB amount
        uint256 amountLPBorrow; // Borrow LP token amount
        uint256 amountAMin; // Desired tokenA amount (slippage control)
        uint256 amountBMin; // Desired tokenB amount (slippage control)
    }


    struct AmountRepayStruct {
        uint256 amountLPTake; // LP amount being taken out from Homora.
        uint256 amountLPWithdraw; // LP amount that we transfer to caller (owner).
        uint256 amountARepay; // Repay tokenA amount
        uint256 amountBRepay; // Repay tokenB amount
        uint256 amountLPRepay; // Repay LP token amount
        uint256 amountAMin; // Desired tokenA amount
        uint256 amountBMin; // Desired tokenB amount
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
            IERC20(tokenOut).safeApprove(address(ROLLUP_PROCESSOR), 0);
            IERC20(tokenOut).safeApprove(address(ROLLUP_PROCESSOR), type(uint256).max);
            unchecked {
                ++i;
            }
        }
    }

  
    function convert(
        AztecTypes.AztecAsset calldata _inputAssetA,
        AztecTypes.AztecAsset calldata _inputAssetB,
        AztecTypes.AztecAsset calldata, 
        AztecTypes.AztecAsset calldata,
        uint256, 
        uint256, 
        address
    )
        external
        payable
        onlyRollup
        returns (uint256, uint256, bool)
    {
        uint256 tokenInDecimals = 18;
        bool inputIsEth = _inputAssetA.assetType == AztecTypes.AztecAssetType.ETH;

        uint256 t;
    }
    function encodePath(
        address spell,
        address _tokenA,
        address _tokenB,
        bytes calldata AmountsInStruct
    
    ) public payable{ 
          (bool success, bytes memory data) = 
                spell.delegatecall(
            abi.encodeWithSignature("addLiquidityWERC20()", _tokenA, _tokenB, AmountsInStruct));
    }

  
    function _encodeSplitPath(
        address spell,
        address _tokenA,
        address _tokenB,
        bytes calldata AmountRepayStruct
    
       ) public payable{ 
          
            (bool success, bytes memory data) = 
            spell.delegatecall(abi.encodeWithSignature("removeLiquidityWERC20()", _tokenA, _tokenB, AmountRepayStruct));        
       }
    function encodeRepayAmounts(
        uint256 amountLPTake, // LP amount being taken out from Homora.
        uint256 amountLPWithdraw, // LP amount that we transfer to caller (owner).
        uint256 amountARepay, // Repay tokenA amount
        uint256 amountBRepay, // Repay tokenB amount
        uint256 amountLPRepay, // Repay LP token amount
        uint256 amountAMin, // Desired tokenA amount
        uint256 amountBMin // Desired tokenB amount
    ) public view returns(bytes memory _data) {  
        abi.encodePacked(amountLPTake, amountLPWithdraw, amountARepay, amountBRepay, amountLPRepay, amountAMin, amountBMin); 
    }
    function encodeAmountsIn(
        uint256 amountAUser, // Supplied tokenA amount
        uint256 amountBUser, // Supplied tokenB amount
        uint256 amountLPUser, // Supplied LP token amount
        uint256 amountABorrow, // Borrow tokenA amount
        uint256 amountBBorrow, // Borrow tokenB amount
        uint256 amountLPBorrow, // Borrow LP token amount
        uint256 amountAMin, // Desired tokenA amount (slippage control)
        uint256 amountBMin 
       
    ) public view returns(bytes memory _data) {  
        abi.encodePacked(amountAUser, amountBUser, amountLPUser, amountBUser, amountLPBorrow, amountAMin, amountBMin); 
    }
}
    

