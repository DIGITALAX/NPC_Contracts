// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./NPCAccessControls.sol";

contract AU is ERC20 {
    address public npcRent;
    NPCAccessControls public _npcAccessControls;

    error InvalidAddress();

    modifier OnlyRentOrAdmin() {
        if (!_npcAccessControls.isAdmin(msg.sender) && msg.sender != npcRent) {
            revert InvalidAddress();
        }
        _;
    }

    constructor(
        address _rentAddress,
        address _npcAccessControlsAddress
    ) ERC20("Autonomy Units", "AU") {
        npcRent = _rentAddress;
        _npcAccessControls = NPCAccessControls(_npcAccessControlsAddress);
    }

    function mint(address _to, uint256 _mintAmount) public OnlyRentOrAdmin {
        _mint(_to, _mintAmount);
    }
}
