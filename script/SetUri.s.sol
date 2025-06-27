// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {QuestManagerFactory} from "../src/QuestManagerFactory.sol";
import {QuestManager} from "../src/QuestManager.sol";

contract SetUri is Script {
    function run(address questManagerAddress, string memory newUri) external {
        vm.startBroadcast();
        QuestManager questManager = QuestManager(questManagerAddress);
        questManager.setURI(newUri);
        vm.stopBroadcast();
    }
}
