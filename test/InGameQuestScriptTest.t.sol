// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {InGameQuest} from "src/InGameQuest.sol";
import {InGameQuestScript} from "script/InGameQuestScript.s.sol";
import {GrantMinterRole} from "script/GrantMinterRole.s.sol";

contract InGameQuestScriptTest is Test {
    InGameQuestScript deployScript;
    GrantMinterRole gratRoleScript;
    InGameQuest instance;

    function setUp() public {
        // vm.stopPrank();
        // vm.startPrank(address(this));
        deployScript = new InGameQuestScript();
        gratRoleScript = new GrantMinterRole();
        deployScript.run();
        instance = deployScript.instance();
    }

    function testDeployment() public view {
        // Check if the contract was deployed
        assertTrue(address(instance) != address(0), "Contract was not deployed");

        // Check if the deployer has the admin role
        assertTrue(instance.hasRole(instance.DEFAULT_ADMIN_ROLE(), address(this)), "Deployer does not have admin role");

        // Check if the deployer has the minter role (since deployer is set as minter in the script)
        assertTrue(instance.hasRole(instance.MINTER_ROLE(), address(this)), "Deployer does not have minter role");
    }

    function testGrantRole() public {
        gratRoleScript.run(address(instance), address(1));
    }
}
