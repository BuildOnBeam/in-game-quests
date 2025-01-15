// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {InGameQuest} from "../../src/InGameQuest.sol";

contract InGameQuestMock is InGameQuest {
    constructor(address defaultAdmin, address minter) InGameQuest(defaultAdmin, minter) {}

    function checkMinter(uint256 gameID, uint256 id) public view {
        _checkMinter(gameID, id);
    }

    function test() public pure {}
}
