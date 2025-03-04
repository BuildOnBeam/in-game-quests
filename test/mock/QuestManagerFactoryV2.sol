// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import {QuestManagerFactory} from "../../src/QuestManagerFactory.sol";

/// @custom:oz-upgrades-from QuestManagerFactory
contract QuestManagerFactoryV2 is QuestManagerFactory {
    uint256 public version;

    function getVersion() external view returns (uint256) {
        return version;
    }

    function initializeV2() public reinitializer(2) {
        version = 2;
    }
}
