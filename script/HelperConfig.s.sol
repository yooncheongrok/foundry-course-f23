// SPDX-License-Identifier: MIT

//1. Deploy mocks when we are on loacl anvil chain
//2. Deploy real contracts when we are on live network
//3. keep track of the contract address across different networks(chain)
//   Goerli ETD/USD
//   Mainnet ETD/USD


pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // If we are on a local network, use mock
    // Otherwise, grab the exisiting address from live network

NetworkConfig public activeNetworkConfig;

uint8 public constant DECIMALS = 8;
int256 public constant INITIAL_PRICE = 2000e8;

struct NetworkConfig {
    address priceFeed;
}

constructor() {
    if(block.chainid == 5){
        activeNetworkConfig = getGoerliEthUsdConfig();
    } else if(block.chainid == 1){
        activeNetworkConfig = getMainnetEthUsdConfig();
    }
    else {
        activeNetworkConfig = getOrCreateAnvilEthUsdConfing();
    }
}

function getGoerliEthUsdConfig() public pure returns(NetworkConfig memory) {
    //price feed address
    NetworkConfig memory goerliConfig = NetworkConfig({priceFeed : 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e});
    return goerliConfig;
}

function getMainnetEthUsdConfig() public pure returns(NetworkConfig memory) {
    //price feed address
    NetworkConfig memory mainnetConfig = NetworkConfig({priceFeed : 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    return mainnetConfig;
}

function getOrCreateAnvilEthUsdConfing() public returns(NetworkConfig memory){

    if (activeNetworkConfig.priceFeed != address(0)){
        return activeNetworkConfig;
    }
    //price feed address

    //1. Deploy mocks when we are on loacl anvil chain
    //2. Return the mock address 

    vm.startBroadcast();
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({priceFeed : address(mockPriceFeed)}); 

    return anvilConfig;


}





}
