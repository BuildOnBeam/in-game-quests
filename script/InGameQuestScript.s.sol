// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {InGameQuest} from "src/InGameQuest.sol";

contract InGameQuestScript is Script {
    InGameQuest public instance;

    function run() public {
        address deployer = msg.sender;
        vm.startBroadcast();
        instance = new InGameQuest(deployer, deployer);
        console.log("Contract deployed to %s", address(instance));
        vm.stopBroadcast();
    }
}
