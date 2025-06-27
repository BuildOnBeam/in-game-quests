// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {QuestManagerFactory} from "../src/QuestManagerFactory.sol";
import {QuestManager} from "../src/QuestManager.sol";

contract GrantRole is Script {
    function run(
        address questManagerAddress,
        address grantee,
        string memory role
    ) external {
        bytes32 ROLE = keccak256(abi.encodePacked(role));
        vm.startBroadcast();
        QuestManager questManager = QuestManager(questManagerAddress);
        questManager.grantRole(ROLE, grantee);
        vm.stopBroadcast();
    }
}
