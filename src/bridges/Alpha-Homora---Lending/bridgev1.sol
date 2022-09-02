

// SPDX-License-Identifier: Apache-2.0

// Copyright 2022 Aztec.

pragma solidity >=0.8.4;



import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AztecTypes} from "../../aztec/libraries/AztecTypes.sol";

import {ErrorLib} from "../base/ErrorLib.sol";

import {BridgeBase} from "../base/BridgeBase.sol";



/**

 * @title An example bridge contract.

 * @author Aztec Team

 * @notice You can use this contract to immediately get back what you've deposited.

 * @dev This bridge demonstrates the flow of assets in the convert function. This bridge simply returns what has been

 *      sent to it.

 */

contract ExampleBridgeContract is BridgeBase {

    /**

     * @notice Set address of rollup processor

     * @param _rollupProcessor Address of rollup processor

     */

    constructor(address _rollupProcessor) BridgeBase(_rollupProcessor) {

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



    /**

     * @notice A function which returns an _totalInputValue amount of _inputAssetA

     * @param _inputAssetA - Arbitrary ERC20 token

     * @param _outputAssetA - Equal to _inputAssetA

     * @param _rollupBeneficiary - Address of the contract which receives subsidy in case subsidy was set for a given

     *                             criteria

     * @return outputValueA - the amount of output asset to return

     * @dev In this case _outputAssetA equals _inputAssetA

     */

    function convertUniV3(

        AztecTypes.AztecAsset calldata _inputAssetA,

        AztecTypes.AztecAsset calldata _inputAssetB,

        AztecTypes.AztecAsset calldata _outputAssetA,

        AztecTypes.AztecAsset calldata _outputAssetB,

        uint256 _totalInputValue,

        uint256,

        uint64 _auxData,

        //address _rollupBeneficiary,

        address univ3

        //address sushi,

        //address curve

    )

        external

        payable

        override(BridgeBase)

        onlyRollup

        returns (

            uint256 outputValueA,

            uint256,

            bool

        )

    {

        // Check the input asset is ERC20

        if (_inputAssetA.assetType != AztecTypes.AztecAssetType.ERC20) revert ErrorLib.InvalidInputA();

        if (_outputAssetA.erc20Address != _inputAssetA.erc20Address) revert ErrorLib.InvalidOutputA();

        // Return the input value of input asset

        outputValueA = _totalInputValue;

        // Approve rollup processor to take input value of input asset

        IERC20(_outputAssetA.erc20Address).approve(univ3, _totalInputValue);



        // Pay out subsidy to the rollupBeneficiary

        SUBSIDY.claimSubsidy(

            computeCriteriaUniV3(_inputAssetA, _inputAssetB, _outputAssetA, _outputAssetB, _auxData),

            univ3

        );

    }



    /**

     * @notice Computes the criteria that is passed when claiming subsidy.

     * @param _inputAssetA The input asset

     * @param _outputAssetA The output asset

     * @return The criteria

     */

    function computeCriteriaUniV3(

        AztecTypes.AztecAsset calldata _inputAssetA,

        AztecTypes.AztecAsset calldata,

        AztecTypes.AztecAsset calldata _outputAssetA,

        AztecTypes.AztecAsset calldata,

        uint64

    ) public view override(BridgeBase) returns (uint256) {

        return uint256(keccak256(abi.encodePacked(_inputAssetA.erc20Address, _outputAssetA.erc20Address)));

    }

   function convertSushi(

        AztecTypes.AztecAsset calldata _inputAssetA,

        AztecTypes.AztecAsset calldata _inputAssetB,

        AztecTypes.AztecAsset calldata _outputAssetA,

        AztecTypes.AztecAsset calldata _outputAssetB,

        uint256 _totalInputValue,

        uint256,

        uint64 _auxData,

       // address _rollupBeneficiary,

       // address univ3,

        address sushi

       // address curve

    )

        external

        payable

        override(BridgeBase)

        onlyRollup

        returns (

            uint256 outputValueA,

            uint256,

            bool

        ) {

        // Check the input asset is ERC20

        if (_inputAssetA.assetType != AztecTypes.AztecAssetType.ERC20) revert ErrorLib.InvalidInputA();

        if (_outputAssetA.erc20Address != _inputAssetA.erc20Address) revert ErrorLib.InvalidOutputA();

        // Return the input value of input asset

        outputValueA = _totalInputValue;

        // Approve rollup processor to take input value of input asset

        IERC20(_outputAssetA.erc20Address).approve(univ3, _totalInputValue);



        // Pay out subsidy to the rollupBeneficiary

        SUBSIDY.claimSubsidy(

            computeCriteriaSushi(_inputAssetA, _inputAssetB, _outputAssetA, _outputAssetB, _auxData),

            sushi

        );

    }



    /**

     * @notice Computes the criteria that is passed when claiming subsidy.

     * @param _inputAssetA The input asset

     * @param _outputAssetA The output asset

     * @return The criteria

     */

    function computeCriteriaSushi(

        AztecTypes.AztecAsset calldata _inputAssetA,

        AztecTypes.AztecAsset calldata,

        AztecTypes.AztecAsset calldata _outputAssetA,

        AztecTypes.AztecAsset calldata,

        uint64

    ) public view override(BridgeBase) returns (uint256) {

        return uint256(keccak256(abi.encodePacked(_inputAssetA.erc20Address, _outputAssetA.erc20Address)));

    }

    function convertCurve(

        AztecTypes.AztecAsset calldata _inputAssetA,

        AztecTypes.AztecAsset calldata _inputAssetB,

        AztecTypes.AztecAsset calldata _outputAssetA,

        AztecTypes.AztecAsset calldata _outputAssetB,

        uint256 _totalInputValue,

        uint256,

        uint64 _auxData,

       // address _rollupBeneficiary,

       // address univ3,

        //address sushi

        address curve

    )

        external

        payable

        override(BridgeBase)

        onlyRollup

        returns (

            uint256 outputValueA,

            uint256,

            bool

        ) {

    

        // Check the input asset is ERC20

        if (_inputAssetA.assetType != AztecTypes.AztecAssetType.ERC20) revert ErrorLib.InvalidInputA();

        if (_outputAssetA.erc20Address != _inputAssetA.erc20Address) revert ErrorLib.InvalidOutputA();

        // Return the input value of input asset

        outputValueA = _totalInputValue;

        // Approve rollup processor to take input value of input asset

        IERC20(_outputAssetA.erc20Address).approve(univ3, _totalInputValue);



        // Pay out subsidy to the rollupBeneficiary

        SUBSIDY.claimSubsidyCurve(

            computeCriteriaCurve(_inputAssetA, _inputAssetB, _outputAssetA, _outputAssetB, _auxData),

            curve

        );

    }

}

interface univ3 {

struct AmountInStruct {

    uint amtAUser; // Supplied tokenA amount

    uint amtBUser; // Supplied tokenB amount

    uint amtLPUser; // Supplied LP token amount

    uint amtABorrow; // Borrow tokenA amount

    uint amtBBorrow; // Borrow tokenB amount

    uint amtLPBorrow; // Borrow LP token amount

    uint amtAMin; // Desired tokenA amount (slippage control)

    uint amtBMin; // Desired tokenB amount (slippage control)

}



struct RepayAmounts {

    uint amtLPTake; // LP amount being taken out from Homora.

    uint amtLPWithdraw; // LP amount that we transfer to caller (owner).

    uint amtARepay; // Repay tokenA amount

    uint amtBRepay; // Repay tokenB amount

    uint amtLPRepay; // Repay LP token amount

    uint amtAMin; // Desired tokenA amount

    uint amtBMin; // Desired tokenB amount

  }



function addLiquidityWERC20(

    address tokenA,

    address tokenB,

    AmountInStruct calldata amountIn

) external;



function addLiquidityWStakingRewards(

    address tokenA,

    address tokenB,

    AmountInStruct calldata amountIn,

    address wstaking // wrapped staking contract (see appendix A)

) external;



function removeLiquidityWERC20(

    address tokenA,

    address tokenB,

    AmountRepayStruct calldata amountRepay

) external;



function removeLiquidityWStakingRewards(

    address tokenA,

    address tokenB,

    AmountRepayStruct calldata amountRepay,

    address wstaking // wrapped staking contract (see appendix A)

) external;



function harvestWStakingRewards(address wstaking) external;

}

interface sushi {



//0xDc9c7A2Bae15dD89271ae5701a6f4DB147BAa44C

struct AmountInStruct {

    uint amtAUser; // Supplied tokenA amount

    uint amtBUser; // Supplied tokenB amount

    uint amtLPUser; // Supplied LP token amount

    uint amtABorrow; // Borrow tokenA amount

    uint amtBBorrow; // Borrow tokenB amount

    uint amtLPBorrow; // Borrow LP token amount

    uint amtAMin; // Desired tokenA amount (slippage control)

    uint amtBMin; // Desired tokenB amount (slippage control)

}



struct RepayAmounts {

    uint amtLPTake; // LP amount being taken out from Homora.

    uint amtLPWithdraw; // LP amount that we transfer to caller (owner).

    uint amtARepay; // Repay tokenA amount

    uint amtBRepay; // Repay tokenB amount

    uint amtLPRepay; // Repay LP token amount

    uint amtAMin; // Desired tokenA amount

    uint amtBMin; // Desired tokenB amount

  }



function addLiquidityWERC20(

    address tokenA,

    address tokenB,

    AmountInStruct calldata amountIn

) external;



function addLiquidityWMasterChef(

    address tokenA,

    address tokenB,

    AmountInStruct calldata amountIn,

    uint pid // masterchef pool id

) external;



function removeLiquidityWERC20(

    address tokenA,

    address tokenB,

    AmountRepayStruct calldata amountRepay

) external;



function removeLiquidityWMasterChef(

    address tokenA,

    address tokenB,

    AmountRepayStruct calldata amountRepay

) external;



function harvestWMasterChef() external;



}

interface curve {

0x8b947D8448CFFb89EF07A6922b74fBAbac219795

function addLiquidity3(

    address lp, 

    uint[3] calldata amtsUser, // User's provided amount (order of tokens are aligned with the registry).

    uint amtLPUser, // user's provided LP amount.

    uint[3] calldata amtsBorrow, // borrow amount (order of tokens are aligned with the registry).

    uint amtLPBorrow, // LP borrow amount.

    uint minLPMint, // minimum LP gain (slippage control).

    uint pid, // pool ID (curve).

    uint gid // gauge ID (curve).

) external;



function removeLiquidity3(

    address lp,

    uint amtLPTake, // LP amount being taken out from Homora.

    uint amtLPWithdraw, // LP amount that we transfer to caller (owner).

    uint[3] calldata amtsRepay, // Repay token amounts (order of tokens are aligned with the registry)

    uint amtLPRepay, // Repay LP amounts 

    uint[3] calldata amtsMin //minimum gain after removeLiquidity (slippage control; order of tokens are aligned with the registry)

) external;



function harvest() external;

}
