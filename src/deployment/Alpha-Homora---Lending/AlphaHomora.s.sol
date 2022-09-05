// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Aztec.
pragma solidity >=0.8.4;

import {BaseDeployment} from "../base/BaseDeployment.s.sol";
import {AlphaHomorabridge1} from "../../bridges/Alpha-Homora---Lending/AlphaHomoraV2-Deposit.sol";

contract AlphaHomorabridge1Deployment is BaseDeployment {
    function deploy() public returns (address) {
        emit log("Deploying AlphaHomorabridge1 bridge");

        vm.broadcast();
        AlphaHomorabridge1 bridge = new AlphaHomorabridge1(ROLLUP_PROCESSOR);

        emit log_named_address("AlphaHomorabridge1 bridge deployed to", address(bridge));

        return address(bridge);
    }

    function deployAndList() public {
        address bridge = deploy();
        uint256 addressId = listBridge(bridge, 250000);
        emit log_named_uint("AlphaHomorabridge1 bridge address id", addressId);
    }
}
