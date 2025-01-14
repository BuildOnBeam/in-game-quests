// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {InGameQuest} from "src/InGameQuest.sol";

contract InGameQuestTest is Test {
  InGameQuest public instance;

  function setUp() public {
    address initialOwner = vm.addr(1);
    instance = new InGameQuest(initialOwner);
  }

  function testUri() public view {
    assertEq(instance.uri(0), "");
  }
}
