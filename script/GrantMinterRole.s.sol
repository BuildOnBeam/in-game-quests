// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {QuestManagerFactory} from "../src/QuestManagerFactory.sol";
import {QuestManager} from "../src/QuestManager.sol";
/**
forge script script/GrantMinterRole.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
  --account beam-test-1 \
  --password 123 \
  --sender 0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87 \
   --sig "run(address,address)" 0xb343beb85f7b086a142986fdfe05fd2df7ac1838 0x0D6AeA86b0886586673719e922E56e70c5110457 \
  --broadcast  
  */
contract GrantMinterRole is Script {
    function run(address questManagerAddress, address grantee) external {
        bytes32 MINTER_ROLE = keccak256("MINTER_ROLE");
        vm.startBroadcast();
        QuestManager questManager = QuestManager(questManagerAddress);
        questManager.grantRole(MINTER_ROLE, grantee);
        vm.stopBroadcast();
    }
}
