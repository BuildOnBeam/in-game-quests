// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.22;

// import {Script} from "forge-std/Script.sol";
// import {console} from "forge-std/console.sol";
// import {InGameQuest} from "src/InGameQuest.sol";

// contract GrantAdminRole is Script {
//     address public inGameAddress = 0xBF05b6CF5dF3891327a601543719b37593047C00;
//     address public roleAddress = 0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87;

//     function run() public {
//         InGameQuest instance = InGameQuest(inGameAddress);
//         bytes32 role = instance.DEFAULT_ADMIN_ROLE();
//         vm.startBroadcast(msg.sender);
//         instance.grantRole(role, roleAddress);
//         vm.stopBroadcast();
//     }
// }
