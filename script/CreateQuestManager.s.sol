// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {QuestManagerFactory} from "../src/QuestManagerFactory.sol";
import {QuestManager} from "../src/QuestManager.sol";

// import {DeployQuestSystem} from "./DeployQuestSystem.s.sol";
/**
forge script script/CreateQuestManager.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
  --account beam-test-1 \
  --password 123 \
  --sender 0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87 \
   --sig "run(address,string)" 0xd24969c44d7e4c7b54239d18232405246db39538 xyz \
  --broadcast  
  */
contract CreateQuestManager is Script {
    function run(address factoryAddress, string memory gameId) external {
        address sender = msg.sender;
        console.log("sender");
        console.log(sender);
        vm.startBroadcast();
        QuestManagerFactory factory = QuestManagerFactory(factoryAddress);

        // Create a new QuestManager clone
        address questManagerAddress = factory.createQuestManager(gameId);
        console.log("QuestManager clone created at:", questManagerAddress);

        // Verify the clone
        QuestManager questManager = QuestManager(questManagerAddress);

        // Test single mint
        uint256 tokenId = 1;
        uint256 amount = 100;
        questManager.mint(sender, tokenId, amount, "");
        console.log("Minted");
        console.log(amount);
        console.log("tokens of ID");
        console.log(tokenId);
        console.log("to");
        console.log(sender);

        require(
            questManager.balanceOf(sender, tokenId) == amount,
            "Mint failed"
        );

        // Test batch mint
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 2;
        tokenIds[1] = 3;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 200;
        amounts[1] = 300;

        questManager.mintBatch(sender, tokenIds, amounts, "");
        console.log("Batch minted tokens to", sender);
        require(
            questManager.balanceOf(sender, tokenIds[0]) == amounts[0],
            "Batch mint 1 failed"
        );
        require(
            questManager.balanceOf(sender, tokenIds[1]) == amounts[1],
            "Batch mint 2 failed"
        );

        console.log(
            "Clone creation and minting operations completed successfully"
        );

        vm.stopBroadcast();
    }
}
