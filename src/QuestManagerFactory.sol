// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {QuestManager} from "./QuestManager.sol";

contract QuestManagerFactory is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable
{
    error GameIdNotValid();
    bytes32 public constant GAME_CREATOR_ROLE = keccak256("GAME_CREATOR_ROLE");

    address public implementation;
    mapping(uint256 => address) public gameIdToContract;
    mapping(address => uint256) public contractToGameId;

    event QuestManagerCreated(
        uint256 indexed gameId,
        address indexed contractAddress
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _defaultAdmin,
        address _implementation,
        address[] memory _gameCreators
    ) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();

        implementation = _implementation;

        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        addGameCreators(_gameCreators);
    }

    function createQuestManager(
        uint256 gameId
    ) external onlyRole(GAME_CREATOR_ROLE) returns (address) {
        if (gameIdToContract[gameId] != address(0)) {
            revert GameIdNotValid();
        }

        // Create EIP-1167 minimal proxy
        address clone = Clones.clone(implementation);

        QuestManager(clone).initialize(msg.sender, gameId);

        gameIdToContract[gameId] = clone;
        contractToGameId[clone] = gameId;

        emit QuestManagerCreated(gameId, clone);
        return clone;
    }

    function getQuestManagerContract(
        uint256 gameId
    ) external view returns (address) {
        return gameIdToContract[gameId];
    }

    function addGameCreators(
        address[] memory _gameCreators
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < _gameCreators.length; i++) {
            grantRole(GAME_CREATOR_ROLE, _gameCreators[i]);
        }
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
