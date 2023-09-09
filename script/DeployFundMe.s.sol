// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperconfig = new HelperConfig();
        address ethUsdPrice = helperconfig.ActiveNetworkConfig();

        vm.startBroadcast();

        FundMe fundme = new FundMe(ethUsdPrice);

        vm.stopBroadcast();

        return fundme;
    }
}
