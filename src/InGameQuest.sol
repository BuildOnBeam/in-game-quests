// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract InGameQuest is ERC1155, AccessControl, ERC1155Burnable {
    error GameIdsDontMatchIds();
    error SoulboundTokensCannotBeTransferred();
    error SoulboundTokensCannotBeApproved();
    error TokenIdMustBeExactly11Cyphers();
    error GameIdMustBe4Cyphers();
    error IdDoesNotMatchGameId();
    error MinterNotTiedToGameId();

    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => address) public s_gameToMinter;

    event MinterSet(uint256 indexed gameID, address indexed minter);
    event MinterRemoved(uint256 indexed gameID, address indexed minter);

    constructor(address defaultAdmin, address minter) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    /// tie the minter to the gameID and grant necessary role to minter
    function addGameIdAndMinter(uint256 gameID, address minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        //check that the game id is exactly 4 cyphers
        if (gameID < 1e3 || gameID >= 1e4) {
            revert GameIdMustBe4Cyphers();
        }
        s_gameToMinter[gameID] = minter;
        _grantRole(MINTER_ROLE, minter);
        emit MinterSet(gameID, minter);
    }

    /// remove the minter from the gameID and revoke role
    function removeGameIdAndMinter(uint256 gameID) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address minter = s_gameToMinter[gameID];
        s_gameToMinter[gameID] = address(0);
        _revokeRole(MINTER_ROLE, minter);
        emit MinterRemoved(gameID, minter);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 gameID, uint256 amount, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _checkMinter(gameID, id);
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory gameIDs,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        if (ids.length != gameIDs.length) {
            revert GameIdsDontMatchIds();
        }

        for (uint256 i = 0; i < ids.length; i++) {
            _checkMinter(gameIDs[i], ids[i]);
        }

        _mintBatch(to, ids, amounts, data);
    }

    // Override to prevent transfers
    function safeTransferFrom(
        address, /*from*/
        address, /*to*/
        uint256, /*id*/
        uint256, /*amount*/
        bytes memory /*data*/
    ) public virtual override {
        revert SoulboundTokensCannotBeTransferred();
    }

    // Override to prevent batch transfers
    function safeBatchTransferFrom(
        address, /*from*/
        address, /*to*/
        uint256[] memory, /*ids*/
        uint256[] memory, /* amounts*/
        bytes memory /*data*/
    ) public virtual override {
        revert SoulboundTokensCannotBeTransferred();
    }

    // Override to prevent setting approval for all
    function setApprovalForAll(address, /*operator*/ bool /*approved*/ ) public virtual override {
        revert SoulboundTokensCannotBeApproved();
    }

    // Override to prevent checking approval for all
    function isApprovedForAll(address, /*account*/ address /*operator*/ ) public view virtual override returns (bool) {
        return false; // Always return false since no approvals are allowed
    }

    /// gameID is 4 cyphers
    /// id is 4+7 cyphers
    /// max tokenId 11 cyphers
    function _checkMinter(uint256 gameID, uint256 tokenID) internal view {
        if (tokenID < 1e10 || tokenID >= 1e11) {
            revert TokenIdMustBeExactly11Cyphers();
        }

        // Ensure gameID fits within 4 digits
        if (gameID < 1e3 || gameID >= 1e4) {
            revert GameIdMustBe4Cyphers();
        }

        uint256 firstFourDigitsOfId = tokenID / 1e7;

        if (firstFourDigitsOfId != gameID) {
            revert IdDoesNotMatchGameId();
        }

        // check minter is tied to that gameid
        if (s_gameToMinter[gameID] != msg.sender) {
            revert MinterNotTiedToGameId();
        }
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
