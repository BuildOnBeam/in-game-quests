// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import "../src/InGameQuest.sol"; // Adjust the path according to your project structure

contract InGameQuestTest is Test {
    InGameQuest public inGameQuest;
    address public constant DEFAULT_ADMIN = address(1);
    address public constant MINTER = address(2);
    address public constant USER = address(3);

    function setUp() public {
        inGameQuest = new InGameQuest(DEFAULT_ADMIN, MINTER);
    }

    function testInitialSetup() public view {
        assertEq(inGameQuest.hasRole(inGameQuest.DEFAULT_ADMIN_ROLE(), DEFAULT_ADMIN), true);
        assertEq(inGameQuest.hasRole(inGameQuest.MINTER_ROLE(), MINTER), true);
    }

    function testMintToken() public {
        uint256 tokenId = 1;
        uint256 amount = 10;

        // Only the minter should be able to mint
        vm.prank(MINTER);
        inGameQuest.mint(USER, tokenId, amount, "");
        assertEq(inGameQuest.balanceOf(USER, tokenId), amount);

        // Non-minter should not mint
        vm.expectRevert();
        inGameQuest.mint(USER, tokenId, amount, "");
    }

    function testSetURI() public {
        string memory newUri = "new-uri";

        // Only URI_SETTER_ROLE can set URI
        vm.expectRevert();
        inGameQuest.setURI(newUri);

        // Grant the role to an address and test
        vm.startPrank(DEFAULT_ADMIN);
        inGameQuest.grantRole(inGameQuest.URI_SETTER_ROLE(), USER);
        vm.stopPrank();

        vm.prank(USER);
        inGameQuest.setURI(newUri);

        assertEq(inGameQuest.uri(0), newUri);
    }

    function testFailTransferSoulbound() public {
        uint256 tokenId = 1;
        uint256 amount = 10;

        vm.prank(MINTER);
        inGameQuest.mint(USER, tokenId, amount, "");

        // This should fail because tokens are soulbound
        vm.prank(USER);
        inGameQuest.safeTransferFrom(USER, address(4), tokenId, 1, "");
    }

    function testFailBatchTransferSoulbound() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 1;
        tokenIds[1] = 2;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 10;
        amounts[1] = 20;

        vm.prank(MINTER);
        inGameQuest.mintBatch(USER, tokenIds, amounts, "");

        // This should fail because tokens are soulbound
        vm.prank(USER);
        inGameQuest.safeBatchTransferFrom(USER, address(4), tokenIds, amounts, "");
    }

    function testFailSetApproval() public {
        // Should fail because soulbound tokens cannot be approved for transfer
        vm.prank(USER);
        inGameQuest.setApprovalForAll(address(4), true);
    }

    function testIsApprovedForAllReturnsFalse() public view {
        // Should always return false for soulbound tokens
        assertFalse(inGameQuest.isApprovedForAll(USER, address(4)));
    }

    function testSupportsInterface() public view {
        // ERC165 Interface ID for ERC165
        bytes4 erc165InterfaceId = 0x01ffc9a7;
        // ERC1155 Interface ID
        bytes4 erc1155InterfaceId = 0xd9b67a26;
        // ERC1155Metadata_URI Interface ID
        bytes4 erc1155MetadataURIInterfaceId = 0x0e89341c;
        // AccessControl Interface ID
        bytes4 accessControlInterfaceId = 0x7965db0b;

        // Check if the contract supports ERC165
        assertTrue(inGameQuest.supportsInterface(erc165InterfaceId));

        // Check if the contract supports ERC1155
        assertTrue(inGameQuest.supportsInterface(erc1155InterfaceId));

        // Check if the contract supports ERC1155 Metadata URI extension
        assertTrue(inGameQuest.supportsInterface(erc1155MetadataURIInterfaceId));

        // Check if the contract supports AccessControl
        assertTrue(inGameQuest.supportsInterface(accessControlInterfaceId));

        // Check for a non-supported interface (using a random bytes4)
        bytes4 randomInterfaceId = 0xffffffff;
        assertFalse(inGameQuest.supportsInterface(randomInterfaceId));
    }
}
