// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.26;

import "./NPCLibrary.sol";
import "./NPCAccessControls.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NPCAUDistributor {
    string public symbol;
    string public name;
    NPCAccessControl public _npcAccessControls;

    error InvalidAddress();
    error InsufficientTokenBalance();

    modifier OnlyNPC() {
        if (!_npcAccessControls.isNPC(msg.sender)) {
            revert InvalidAddress();
        }
        _;
    }

    constructor(address _npcAccessControlsAddress) {
        _npcAccessControls = NPCAccessControl(_npcAccessControlsAddress);
        symbol = "NPCAUD";
        name = "NPCAUDistributor";
    }

    function callAUDistribution() public OnlyNPC {}
}
