// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.26;
import "./NPCLibrary.sol";

contract NPCAccessControls {
    string public symbol;
    string public name;
    address[] private _erc20Addresses;
    address[] private _erc721Addresses;

    mapping(address => bool) private _admins;
    mapping(address => bool) private _npcs;
    mapping(address => NPCLibrary.Token) private _erc20Values;
    mapping(address => NPCLibrary.Token) private _erc721Values;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event NPCAdded(address indexed npc);
    event NPCRemoved(address indexed npc);

    error AddressInvalid();
    error Existing();
    error CantRemoveSelf();

    modifier OnlyAdmin() {
        if (!_admins[msg.sender]) {
            revert AddressInvalid();
        }
        _;
    }

    constructor() {
        _admins[msg.sender] = true;
        symbol = "NPCAC";
        name = "NPCAccessControls";
    }

    function addAdmin(address _admin) external OnlyAdmin {
        if (_admins[_admin] || _admin == msg.sender) {
            revert Existing();
        }
        _admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) external OnlyAdmin {
        if (_admin == msg.sender) {
            revert CantRemoveSelf();
        }
        if (!_admins[_admin]) {
            revert AddressInvalid();
        }
        _admins[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function addNPC(address _npc) external OnlyAdmin {
        if (_npcs[_npc]) {
            revert Existing();
        }
        _npcs[_npc] = true;
        emit NPCAdded(_npc);
    }

    function removeNPC(address _npc) external OnlyAdmin {
        if (!_npcs[_npc]) {
            revert AddressInvalid();
        }
        _npcs[_npc] = false;
        emit NPCRemoved(_npc);
    }

    function setERC20Addresses(address[] memory _addresses) public OnlyAdmin {
        _erc20Addresses = _addresses;
    }

    function setERC721Addresses(address[] memory _addresses) public OnlyAdmin {
        _erc721Addresses = _addresses;
    }

    function setERC721Value(
        address _erc721Address,
        uint256 _weight,
        uint256 _threshold
    ) public OnlyAdmin {
        _erc721Values[_erc721Address] = NPCLibrary.Token({
            weight: _weight,
            threshold: _threshold
        });
    }

    function setERC20WeightValue(
        address _erc20Address,
        uint256 _weight,
        uint256 _threshold
    ) public OnlyAdmin {
        _erc20Values[_erc20Address] = NPCLibrary.Token({
            weight: _weight,
            threshold: _threshold
        });
    }

    function isAdmin(address _address) public view returns (bool) {
        return _admins[_address];
    }

    function isNPC(address _address) public view returns (bool) {
        return _npcs[_address];
    }

    function getERC20TokenAddresses() public view returns (address[] memory) {
        return _erc20Addresses;
    }

    function getERC721TokenAddresses() public view returns (address[] memory) {
        return _erc721Addresses;
    }

    function getERC20TokenThreshold(
        address _erc20Token
    ) public view returns (uint256) {
        return _erc20Values[_erc20Token].threshold;
    }

    function getERC721TokenThreshold(
        address _erc721Token
    ) public view returns (uint256) {
        return _erc721Values[_erc721Token].threshold;
    }

    function getERC20TokenWeight(
        address _erc20Token
    ) public view returns (uint256) {
        return _erc20Values[_erc20Token].weight;
    }

    function getERC721TokenWeight(
        address _erc721Token
    ) public view returns (uint256) {
        return _erc721Values[_erc721Token].weight;
    }
}
