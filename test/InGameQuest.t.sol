// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Test, console2} from "forge-std/Test.sol";
import {InGameQuestMock} from "./mock/InGameQuestMock.sol";

contract InGameQuestTest is Test {
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    error GameIdsDontMatchIds();
    error SoulboundTokensCannotBeTransferred();
    error SoulboundTokensCannotBeApproved();
    error TokenIdMustBeExactly11Cyphers();
    error GameIdMustBe4Cyphers();
    error IdDoesNotMatchGameId();
    error MinterNotTiedToGameId();

    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    InGameQuestMock public inGameQuest;
    address public constant DEFAULT_ADMIN = address(1);
    address public constant MINTER = address(2);
    address public constant USER = address(3);

    uint256 public constant INITIAL_GAME_ID = 1234;
    uint256 public constant INITIAL_TOKEN_ID = 12341234567;

    function setUp() public {
        inGameQuest = new InGameQuestMock(DEFAULT_ADMIN, MINTER);
    }

    function testInitialSetup() public view {
        assertEq(inGameQuest.hasRole(inGameQuest.DEFAULT_ADMIN_ROLE(), DEFAULT_ADMIN), true);
        assertEq(inGameQuest.hasRole(inGameQuest.MINTER_ROLE(), MINTER), true);
    }

    function testAddAndRemoveMinter() public {
        uint256 gameId1 = 1234;
        uint256 gameId2 = 1235;

        vm.startPrank(DEFAULT_ADMIN);
        inGameQuest.addGameIdAndMinter(gameId1, MINTER);
        inGameQuest.addGameIdAndMinter(gameId2, MINTER);
        assertEq(inGameQuest.s_gameToMinter(gameId1), MINTER);
        assertEq(inGameQuest.s_gameToMinter(gameId2), MINTER);

        inGameQuest.removeGameIdAndMinter(gameId1);
        inGameQuest.removeGameIdAndMinter(gameId2);
        assertEq(inGameQuest.s_gameToMinter(gameId1), address(0));
        assertEq(inGameQuest.s_gameToMinter(gameId2), address(0));

        vm.stopPrank();
    }

    function testRevertIf_AddMinterGameID_has_Wrong_Cyphers() public {
        uint256 gameId1 = 123;
        uint256 gameId2 = 12345;

        vm.startPrank(DEFAULT_ADMIN);
        vm.expectRevert(GameIdMustBe4Cyphers.selector);
        inGameQuest.addGameIdAndMinter(gameId1, MINTER);

        vm.expectRevert(GameIdMustBe4Cyphers.selector);
        inGameQuest.addGameIdAndMinter(gameId2, MINTER);

        vm.stopPrank();
    }

    function testMintToken() public {
        uint256 amount = 10;

        vm.prank(DEFAULT_ADMIN);
        inGameQuest.addGameIdAndMinter(INITIAL_GAME_ID, MINTER);

        // Only the minter should be able to mint
        vm.prank(MINTER);
        inGameQuest.mint(USER, INITIAL_TOKEN_ID, INITIAL_GAME_ID, amount, "");
        assertEq(inGameQuest.balanceOf(USER, INITIAL_TOKEN_ID), amount);

        // Non-minter should not mint
        vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, address(this), MINTER_ROLE));
        inGameQuest.mint(USER, INITIAL_TOKEN_ID, INITIAL_GAME_ID, amount, "");
    }

    function testBatchMintToken() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 12341234567;
        tokenIds[1] = 12351234567;
        uint256[] memory gameIds = new uint256[](2);
        gameIds[0] = 1234;
        gameIds[1] = 1235;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 10;
        amounts[1] = 20;

        vm.startPrank(DEFAULT_ADMIN);
        inGameQuest.addGameIdAndMinter(gameIds[0], MINTER);
        inGameQuest.addGameIdAndMinter(gameIds[1], MINTER);
        vm.stopPrank();

        vm.prank(MINTER);
        inGameQuest.mintBatch(USER, tokenIds, gameIds, amounts, "");
    }

    function testSetURI() public {
        string memory newUri = "new-uri";

        // Only URI_SETTER_ROLE can set URI
        vm.expectRevert(
            abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, address(this), URI_SETTER_ROLE)
        );
        inGameQuest.setURI(newUri);

        // Grant the role to an address and test
        vm.startPrank(DEFAULT_ADMIN);
        inGameQuest.grantRole(inGameQuest.URI_SETTER_ROLE(), USER);
        vm.stopPrank();

        vm.prank(USER);
        inGameQuest.setURI(newUri);

        assertEq(inGameQuest.uri(0), newUri);
    }

    function testRevertTransferSoulbound() public {
        uint256 amount = 10;

        vm.startPrank(DEFAULT_ADMIN);
        inGameQuest.addGameIdAndMinter(1234, MINTER);
        inGameQuest.addGameIdAndMinter(1235, MINTER);
        vm.stopPrank();

        vm.prank(MINTER);
        inGameQuest.mint(USER, INITIAL_TOKEN_ID, INITIAL_GAME_ID, amount, "");

        // This should fail because tokens are soulbound
        vm.prank(USER);
        vm.expectRevert(SoulboundTokensCannotBeTransferred.selector);
        inGameQuest.safeTransferFrom(USER, address(4), INITIAL_TOKEN_ID, 1, "");
    }

    function testRevertBatchTransferSoulbound() public {
        vm.startPrank(DEFAULT_ADMIN);
        inGameQuest.addGameIdAndMinter(1234, MINTER);
        inGameQuest.addGameIdAndMinter(1235, MINTER);
        vm.stopPrank();

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 12341234567;
        tokenIds[1] = 12351234567;
        uint256[] memory gameIds = new uint256[](2);
        gameIds[0] = 1234;
        gameIds[1] = 1235;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 10;
        amounts[1] = 20;

        vm.prank(MINTER);
        inGameQuest.mintBatch(USER, tokenIds, gameIds, amounts, "");

        // This should fail because tokens are soulbound
        vm.prank(USER);
        vm.expectRevert(SoulboundTokensCannotBeTransferred.selector);
        inGameQuest.safeBatchTransferFrom(USER, address(4), tokenIds, amounts, "");
    }

    function testRevertIfMintBatchIfIdsMismatch() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 12341234567;
        tokenIds[1] = 12351234567;
        uint256[] memory gameIds = new uint256[](3);
        gameIds[0] = 1234;
        gameIds[1] = 1235;
        gameIds[2] = 1236;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 10;
        amounts[1] = 20;

        vm.startPrank(MINTER);
        vm.expectRevert(GameIdsDontMatchIds.selector);
        inGameQuest.mintBatch(USER, tokenIds, gameIds, amounts, "");
        vm.stopPrank();
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

    function testRevertCheckMinter() public {
        vm.prank(DEFAULT_ADMIN);
        inGameQuest.addGameIdAndMinter(INITIAL_GAME_ID, MINTER);

        // Only the minter should be able to mint
        vm.startPrank(MINTER);

        // tokenID < 1e11
        vm.expectRevert(TokenIdMustBeExactly11Cyphers.selector);
        inGameQuest.checkMinter(INITIAL_GAME_ID, 10000000000 - 1);

        // tokenID >= 1e12
        vm.expectRevert(TokenIdMustBeExactly11Cyphers.selector);
        inGameQuest.checkMinter(INITIAL_GAME_ID, 99999999999 + 1);

        // gameID >= 1e4
        vm.expectRevert(GameIdMustBe4Cyphers.selector);
        inGameQuest.checkMinter(9999 + 1, INITIAL_TOKEN_ID);

        // gameID < 1e3
        vm.expectRevert(GameIdMustBe4Cyphers.selector);
        inGameQuest.checkMinter(1000 - 1, INITIAL_TOKEN_ID);

        // firstFourDigitsOfId != gameID
        vm.expectRevert(IdDoesNotMatchGameId.selector);
        inGameQuest.checkMinter(1235, INITIAL_TOKEN_ID);

        // s_gameToMinter[gameID] != msg.sender
        vm.stopPrank();
        vm.prank(DEFAULT_ADMIN);
        inGameQuest.removeGameIdAndMinter(INITIAL_GAME_ID);

        vm.prank(MINTER);
        vm.expectRevert(MinterNotTiedToGameId.selector);
        inGameQuest.checkMinter(INITIAL_GAME_ID, INITIAL_TOKEN_ID);
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
