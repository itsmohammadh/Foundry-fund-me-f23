// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public ActiveNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            ActiveNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            ActiveNetworkConfig = getMainNetConfig();
        } else {
            ActiveNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory SepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return SepoliaConfig;
    }

    function getMainNetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainNetconfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainNetconfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (ActiveNetworkConfig.priceFeed != address(0)) {
            return ActiveNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMAL,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory AnvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return AnvilConfig;
    }
}
