//SPDX-License-Identifier: MIT



pragma solidity ^0.8.19;


import {FundMe} from "../src/FundMe.sol" ;
import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";


contract DeployFundMe is Script{

    function run() external returns (FundMe) {
        //before startBroadcast, it is not "Tx"
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        //after startBroadcast, it is real "Tx"
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }



}