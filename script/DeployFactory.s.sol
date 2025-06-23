// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {QuestManagerFactory} from "../src/QuestManagerFactory.sol";
/**
forge script script/DeployFactory.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
  --account beam-test-1 \
  --password 123 \
  --sender 0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87 \
  --broadcast  
   */
contract DeployFactory is Script {
    function run() external returns (address) {
        vm.startBroadcast();
        console.log("msg.sender");
        console.log(msg.sender);
        // Prepare initial game creators array with the sender
        address[] memory gameCreators = new address[](2);
        gameCreators[0] = msg.sender;
        gameCreators[1] = 0xfe49573fFc8A2d4863a318C1Afafde8cfdECe782;

        QuestManagerFactory questManagerFactory = new QuestManagerFactory(
            gameCreators,
            msg.sender
        );

        console.log(
            "QuestManagerFactory deployed at:",
            address(questManagerFactory)
        );

        console.log("Deployment and initialization verified successfully");
        vm.stopBroadcast();
        return address(questManagerFactory);
    }
}
