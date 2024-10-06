// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.26;

import "./NPCLibrary.sol";
import "./NPCAccessControls.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NPCVoting {
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

    mapping(address => uint256) private _spectatorAUClaimed;
    mapping(address => uint256) private _spectatorAUEarned;
    mapping(address => uint256) private _spectatorAUUnclaimed;

    constructor(address _npcAccessControlsAddress) {
        _npcAccessControls = NPCAccessControl(_npcAccessControlsAddress);
        symbol = "NPCR";
        name = "NPCRent";
    }

    function NPCPayRent() public OnlyNPC {}

    function NPCClaimRent() public OnlyNPC {}

    function voterClaimAU() public {}

    function getSpectatorAUUnclaimed(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorAUUnclaimed[_spectator];
    }

    function getSpectatorAUClaimed(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorAUClaimed[_spectator];
    }

    function getSpectatorAUEarned(
        address _spectator
    ) public view returns (uint256) {
        return
            _spectatorAUClaimed[_spectator] + _spectatorAUUnclaimed[_spectator];
    }

    function getNPCRentOwed() public view returns (uint256) {}

    function getNPCRentPaidTotal() public view returns (uint256) {}
}
