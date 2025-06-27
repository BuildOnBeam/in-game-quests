// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {QuestManager} from "./QuestManager.sol";

/// @title QuestManagerFactory
/// @notice Factory contract to create and manage QuestManager instances for games
contract QuestManagerFactory is AccessControl {
    /// @notice Error thrown when a game ID is already in use
    error GameIdAlreadyUsed();
    /// @notice Error thrown when an invalid address is provided
    error InvalidAddress();

    bytes32 public constant GAME_CREATOR_ROLE = keccak256("GAME_CREATOR_ROLE");

    mapping(string => address) public gameIdToContract;
    mapping(address => string) public contractToGameId;

    /// @notice Emitted when a new QuestManager is created
    /// @param gameId The ID of the game
    /// @param contractAddress The address of the created QuestManager
    event QuestManagerCreated(
        string indexed gameId,
        address indexed contractAddress
    );

    /// @notice Constructor to initialize the factory
    /// @param _gameCreators Array of addresses to grant GAME_CREATOR_ROLE
    /// @param _defaultAdmin Address to grant DEFAULT_ADMIN_ROLE
    constructor(address[] memory _gameCreators, address _defaultAdmin) {
        if (_defaultAdmin == address(0)) revert InvalidAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _addGameCreators(_gameCreators);
    }

    /// @notice Creates a new QuestManager contract for a game
    /// @param gameId Unique ID for the game
    /// @return Address of the created QuestManager
    function createQuestManager(
        string memory gameId
    ) external onlyRole(GAME_CREATOR_ROLE) returns (address) {
        if (gameIdToContract[gameId] != address(0)) revert GameIdAlreadyUsed();

        QuestManager questManager = new QuestManager(msg.sender, gameId);
        address questManagerAddress = address(questManager);

        gameIdToContract[gameId] = questManagerAddress;
        contractToGameId[questManagerAddress] = gameId;

        emit QuestManagerCreated(gameId, questManagerAddress);
        return questManagerAddress;
    }

    /// @notice Retrieves the QuestManager address for a game ID
    /// @param gameId The ID of the game
    /// @return Address of the QuestManager contract
    function getQuestManagerContract(
        string memory gameId
    ) external view returns (address) {
        return gameIdToContract[gameId];
    }

    /// @notice Adds game creators with GAME_CREATOR_ROLE
    /// @param _gameCreators Array of addresses to grant the role
    function addGameCreators(
        address[] memory _gameCreators
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _addGameCreators(_gameCreators);
    }

    /// @notice Removes game creators by revoking GAME_CREATOR_ROLE
    /// @param _gameCreators Array of addresses to revoke the role
    function removeGameCreators(
        address[] memory _gameCreators
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < _gameCreators.length; i++) {
            if (_gameCreators[i] == address(0)) revert InvalidAddress();
            revokeRole(GAME_CREATOR_ROLE, _gameCreators[i]);
        }
    }

    /// @dev Internal function to add game creators
    function _addGameCreators(address[] memory _gameCreators) internal {
        for (uint256 i = 0; i < _gameCreators.length; i++) {
            if (_gameCreators[i] == address(0)) revert InvalidAddress();
            grantRole(GAME_CREATOR_ROLE, _gameCreators[i]);
        }
    }
}
