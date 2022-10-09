// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {ZKGovToken} from "../src/ERC20.sol";
import {VotingBridge} from "../src/VotingBridge.sol";
import { IERC20 } from "openzeppelin-contracts/token/ERC20/IERC20.sol";


contract DeployScript is Script {
    IERC20 token;
    VotingBridge bridge;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        
        token = new ZKGovToken();
        bridge = new VotingBridge(address(0x614957a8aE7B87f18fa3f207b6619C520A022b4F), address(token), 1 hours);

        vm.stopBroadcast();
    }
}
