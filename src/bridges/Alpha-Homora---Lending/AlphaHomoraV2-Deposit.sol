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
struct addLiquidityWERC20 {
      address tokenInA;
      address tokenInB;
      bytes AmountsIn;
      }
struct removeLiquidityWERC20 {
       address tokenOutA;
      address tokenOutB;
      bytes RepayAmts;
      }
struct execute {
      uint256 positionId;
      address SPELL;
      bytes data;
      }
struct AmountsIn {
        uint256 amtAUser; // Supplied tokenA amount
        uint256 amtBUser; // Supplied tokenB amount
        uint256 amtLPUser; // Supplied LP token amount
        uint256 amtABorrow; // Borrow tokenA amount
        uint256 amtBBorrow; // Borrow tokenB amount
        uint256 amtLPBorrow; // Borrow LP token amount
        uint256 amtAMin; // Desired tokenA amount (slippage control)
        uint256 amtBMin; // Desired tokenB amount (slippage control)
    }

    struct RepayAmts {
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
          
 
         { if (_interactionNonce == even) {
            // Deposit
              
             IBank.execute({
                    positionId: _execute.positionId,
                    spell: SPELL,
                    data: addLiquidityWERC20.AmountsIn
                    })
            
            
            else if (_interactionNonce == odd) {    
                    
                IBank.execute({
                 positionId: _execute.positionId,
                 spell: SPELL,
                 data: removeLiquidityWERC20.Repay
            
            
            
            
            
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
