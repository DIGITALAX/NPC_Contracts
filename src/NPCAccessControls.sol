// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.26;

contract NPCAccessControls {
    string public symbol;
    string public name;

    mapping(address => bool) private _admins;
    mapping(address => bool) private _npcs;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event NPCAdded(address indexed npc);
    event NPCRemoved(address indexed npc);

    error AddressInvalid();
    error Existing();
    error CantRemoveSelf();

    modifier onlyAdmin() {
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

    function addAdmin(address _admin) external onlyAdmin {
        if (_admins[_admin] || _admin == msg.sender) {
            revert Existing();
        }
        _admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) external onlyAdmin {
        if (_admin == msg.sender) {
            revert CantRemoveSelf();
        }
        if (!_admins[_admin]) {
            revert AddressInvalid();
        }
        _admins[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function addNPC(address _npc) external onlyAdmin {
        if (_npcs[_npc]) {
            revert Existing();
        }
        _npcs[_npc] = true;
        emit NPCAdded(_npc);
    }

    function removeNPC(address _npc) external onlyAdmin {
        if (!_npcs[_npc]) {
            revert AddressInvalid();
        }
        _npcs[_npc] = false;
        emit NPCRemoved(_npc);
    }

    function isAdmin(address _address) public view returns (bool) {
        return _admins[_address];
    }

    function isNPC(address _address) public view returns (bool) {
        return _npcs[_address];
    }
}
