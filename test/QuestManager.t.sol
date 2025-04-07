// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import {QuestManager} from "../src/QuestManager.sol";
import {QuestManagerFactory} from "../src/QuestManagerFactory.sol";
import {QuestManagerFactoryV2} from "./mock/QuestManagerFactoryV2.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Upgrades} from "../lib/openzeppelin-foundry-upgrades/src/Upgrades.sol";

contract QuestManagerTest is Test {
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    QuestManagerFactory factory;
    QuestManager questManagerImpl;
    address public proxy;
    address admin = address(0x1);
    address gameCreator = address(0x2);
    address user = address(0x3);
    address[] gameCreators;

    event QuestManagerCreated(uint256 indexed gameId, address indexed contractAddress);

    function setUp() public {
        vm.startPrank(admin);
        gameCreators.push(gameCreator);
        questManagerImpl = new QuestManager();
        proxy = Upgrades.deployUUPSProxy(
            "QuestManagerFactory.sol",
            abi.encodeCall(QuestManagerFactory.initialize, (admin, address(questManagerImpl), gameCreators))
        );
        factory = QuestManagerFactory(proxy);
    }

    function test_FactoryInitialization() public {
        vm.stopPrank();
        vm.startPrank(admin);
        assertTrue(factory.hasRole(factory.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(factory.hasRole(factory.GAME_CREATOR_ROLE(), gameCreator));
        assertEq(factory.implementation(), address(questManagerImpl));
    }

    function test_CreateQuestManager() public {
        vm.stopPrank();
        vm.startPrank(gameCreator);
        uint256 gameId = 1;

        address clone = factory.createQuestManager(gameId);

        assertEq(factory.gameIdToContract(gameId), clone);
        assertEq(factory.contractToGameId(clone), gameId);

        QuestManager questManager = QuestManager(clone);
        assertEq(questManager.gameId(), gameId);
        assertTrue(questManager.hasRole(questManager.DEFAULT_ADMIN_ROLE(), gameCreator));
    }

    function test_CannotReuseGameId() public {
        vm.stopPrank();
        vm.startPrank(gameCreator);
        uint256 gameId = 1;
        factory.createQuestManager(gameId);
        vm.expectRevert(QuestManagerFactory.GameIdNotValid.selector);
        factory.createQuestManager(gameId);
    }

    function test_QuestManagerInitialization() public {
        vm.stopPrank();
        vm.startPrank(gameCreator);
        uint256 gameId = 1;
        address proxy = factory.createQuestManager(gameId);
        QuestManager questManager = QuestManager(proxy);

        assertEq(questManager.gameId(), gameId);
        assertTrue(questManager.hasRole(questManager.DEFAULT_ADMIN_ROLE(), gameCreator));
        assertTrue(questManager.hasRole(questManager.URI_SETTER_ROLE(), gameCreator));
        assertTrue(questManager.hasRole(questManager.MINTER_ROLE(), gameCreator));
    }

    function test_QuestManagerCannotReinitialize() public {
        vm.stopPrank();
        vm.startPrank(gameCreator);

        uint256 gameId = 1;
        address proxy = factory.createQuestManager(gameId);
        QuestManager questManager = QuestManager(proxy);

        vm.expectRevert(QuestManager.AlreadyInitialized.selector);
        questManager.initialize(admin, gameId);
    }

    function test_Minting() public {
        vm.stopPrank();
        vm.startPrank(gameCreator);
        uint256 gameId = 1;
        address proxy = factory.createQuestManager(gameId);
        QuestManager questManager = QuestManager(proxy);

        questManager.mint(user, 1, 10, "");

        assertEq(questManager.balanceOf(user, 1), 10);
    }

    function test_SoulboundTransferFails() public {
        vm.stopPrank();
        vm.startPrank(gameCreator);
        uint256 gameId = 1;
        address proxy = factory.createQuestManager(gameId);
        QuestManager questManager = QuestManager(proxy);

        questManager.mint(user, 1, 10, "");
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert(QuestManager.SoulboundTokensCannotBeTransferred.selector);
        questManager.safeTransferFrom(user, address(0x4), 1, 1, "");
    }

    function test_SoulboundApprovalFails() public {
        vm.stopPrank();
        vm.startPrank(gameCreator);

        uint256 gameId = 1;
        address proxy = factory.createQuestManager(gameId);
        QuestManager questManager = QuestManager(proxy);

        vm.expectRevert(QuestManager.SoulboundTokensCannotBeApproved.selector);
        questManager.setApprovalForAll(address(0x4), true);

        assertFalse(questManager.isApprovedForAll(gameCreator, address(0x4)));
    }

    function test_FactoryUpgrade() public {
        vm.stopPrank();
        vm.startPrank(admin);
        Upgrades.upgradeProxy(
            proxy, "QuestManagerFactoryV2.sol", abi.encodeCall(QuestManagerFactoryV2.initializeV2, ())
        );

        QuestManagerFactoryV2 factoryV2 = QuestManagerFactoryV2(proxy);
        assertEq(factoryV2.version(), 2);
        assertEq(factoryV2.getVersion(), 2);
        vm.stopPrank();

        vm.startPrank(gameCreator);
        uint256 gameId = 1;
        address proxy = factoryV2.createQuestManager(gameId);
        assertEq(factoryV2.gameIdToContract(gameId), proxy);

        QuestManager questManager = QuestManager(proxy);
        assertEq(questManager.gameId(), gameId);
        vm.stopPrank();
    }
}
