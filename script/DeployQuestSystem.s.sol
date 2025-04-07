// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {QuestManagerFactory} from "../src/QuestManagerFactory.sol";
import {QuestManager} from "../src/QuestManager.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract DeployQuestSystem is Script {
    function deploy(address sender) external returns (address) {
        vm.startBroadcast(sender);
        // Deploy QuestManager implementation
        QuestManager questManagerImpl = new QuestManager();
        console.log(
            "QuestManager Implementation deployed at:",
            address(questManagerImpl)
        );

        // Prepare initial game creators array with the sender
        address[] memory gameCreators = new address[](1);
        gameCreators[0] = sender;

        // Deploy QuestManagerFactory proxy
        address proxy = Upgrades.deployUUPSProxy(
            "QuestManagerFactory.sol",
            abi.encodeCall(
                QuestManagerFactory.initialize,
                (
                    sender, // default admin
                    address(questManagerImpl), // implementation
                    gameCreators // initial game creators
                )
            )
        );

        console.log("QuestManagerFactory Proxy deployed at:", proxy);

        // Get and log implementation address
        address implementation = Upgrades.getImplementationAddress(proxy);
        console.log(
            "QuestManagerFactory Implementation deployed at:",
            implementation
        );

        // Verify initialization
        QuestManagerFactory factory = QuestManagerFactory(proxy);
        require(
            factory.hasRole(factory.DEFAULT_ADMIN_ROLE(), sender),
            "Admin role not set"
        );
        require(
            factory.implementation() == address(questManagerImpl),
            "Implementation not set correctly"
        );
        require(
            factory.hasRole(factory.GAME_CREATOR_ROLE(), sender),
            "Game creator role not set"
        );

        console.log("Deployment and initialization verified successfully");
        vm.stopBroadcast();
        return proxy;
    }
}
