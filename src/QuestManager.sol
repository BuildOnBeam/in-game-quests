// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract QuestManager is ERC1155, AccessControl, ERC1155Burnable {
    error SoulboundTokensCannotBeTransferred();
    error SoulboundTokensCannotBeApproved();
    error AlreadyInitialized();

    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public gameId;
    bool public initialized;

    constructor() ERC1155("") {}

    function initialize(
        address _defaultAdmin,
        address _gameCreator,
        uint256 _gameId
    ) external {
        if (initialized) {
            revert AlreadyInitialized();
        }

        initialized = true;

        gameId = _gameId;

        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(URI_SETTER_ROLE, _defaultAdmin);
        _grantRole(MINTER_ROLE, _defaultAdmin);
        _grantRole(URI_SETTER_ROLE, _gameCreator);
        _grantRole(MINTER_ROLE, _gameCreator);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mintBatch(to, ids, amounts, data);
    }

    function safeTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*id*/,
        uint256 /*amount*/,
        bytes memory /*data*/
    ) public virtual override {
        revert SoulboundTokensCannotBeTransferred();
    }

    function safeBatchTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256[] memory /*ids*/,
        uint256[] memory /*amounts*/,
        bytes memory /*data*/
    ) public virtual override {
        revert SoulboundTokensCannotBeTransferred();
    }

    function setApprovalForAll(
        address,
        /*operator*/ bool /*approved*/
    ) public virtual override {
        revert SoulboundTokensCannotBeApproved();
    }

    function isApprovedForAll(
        address,
        /*account*/ address /*operator*/
    ) public view virtual override returns (bool) {
        return false;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
