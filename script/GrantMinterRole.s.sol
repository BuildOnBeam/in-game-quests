// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {InGameQuest} from "src/InGameQuest.sol";

contract GrantMinterRole is Script {
    function run(address inGameQuest, address minter) public {
        InGameQuest instance = InGameQuest(inGameQuest);
        bytes32 minterRole = instance.MINTER_ROLE();
        vm.startBroadcast(msg.sender);
        instance.grantRole(minterRole, minter);
        vm.stopBroadcast();
    }
}
