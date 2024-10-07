// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.26;

import "./NPCLibrary.sol";
import "./NPCAccessControls.sol";
import "./AU.sol";
import "./NPCSpectate.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NPCRent {
    NPCAccessControls public npcAccessControls;
    NPCSpectate public npcSpectate;
    AU public au;
    string public symbol;
    string public name;
    uint256 public weeklyAUAmount;
    uint256 public lastWeekTimestamp;
    uint256 public weekCounter;
    uint256 public missedRentCounter;

    error InvalidAddress();
    error InsufficientTokenBalance();
    error NoAUToClaim();

    event RentPaid(address npc, uint256 auAmountClaimed, uint256 auAmountPaid);
    event RentMissed(address npc, uint256 auAmountPaid);
    event MissedRentDistributed(uint256 amount);
    event SpectatorClaimed(address spectator, uint256 auAmountClaimed);

    modifier OnlyNPC() {
        if (!npcAccessControls.isNPC(msg.sender)) {
            revert InvalidAddress();
        }
        _;
    }

    modifier OnlyAdmin() {
        if (!npcAccessControls.isAdmin(msg.sender)) {
            revert InvalidAddress();
        }
        _;
    }

    mapping(address => uint256) private _spectatorAUClaimed;
    mapping(address => uint256) private _spectatorAUEarned;
    mapping(address => uint256) private _spectatorAUUnclaimed;
    mapping(address => uint256) private _npcAUEarned;
    mapping(address => uint256) private _npcAUOwed;
    mapping(address => uint256) private _npcAUPaid;
    mapping(address => NPCLibrary.NPCRent) private _npcs;
    mapping(uint256 => NPCLibrary.AUTracker) private _weeklyAUTracker;

    constructor(
        address _npcAccessControlsAddress,
        address _npcSpectateAddress,
        address _auAddress
    ) {
        npcAccessControls = NPCAccessControls(_npcAccessControlsAddress);
        npcSpectate = NPCSpectate(_npcSpectateAddress);
        au = AU(_auAddress);
        symbol = "NPCR";
        name = "NPCRent";
    }

    function NPCPayRentAndClaim() public OnlyNPC {
        _updateWeekCounter();

        if (!_npcs[msg.sender].initialized) {
            _npcs[msg.sender].initialized = true;
            _npcs[msg.sender].npc = msg.sender;
            _npcs[msg.sender].lastRentClock = 0;
        }

        if (block.timestamp >= _npcs[msg.sender].lastRentClock + 1 weeks) {
            uint256 _amount = _calculateAUMinted(msg.sender);
            if (_amount <= 0) {
                revert NoAUToClaim();
            }
            uint256 _auAmountClaimed = (_amount * 9) / 100;
            uint256 _auAmountPaid = (_amount * 91) / 100;

            if (
                block.timestamp <=
                _npcs[msg.sender].lastRentClock + 1 weeks + 3 days
            ) {
                au.mint(msg.sender, _auAmountClaimed);
                au.mint(address(this), _auAmountPaid);

                _npcs[msg.sender].lastRentClock = block.timestamp;
                _npcs[msg.sender].activeWeeks += 1;
                _npcAUOwed[msg.sender] += _auAmountPaid;

                _weeklyAUTracker[weekCounter].unclaimed += _auAmountPaid;

                emit RentPaid(msg.sender, _auAmountClaimed, _auAmountPaid);
            } else {
                au.mint(address(this), _auAmountPaid + _auAmountClaimed);
                missedRentCounter += _auAmountPaid + _auAmountClaimed;
                _npcAUOwed[msg.sender] += _auAmountPaid + _auAmountClaimed;
                _npcs[msg.sender].activeWeeks += 1;
                _npcs[msg.sender].lastRentClock = block.timestamp;
                emit RentMissed(msg.sender, _auAmountPaid + _auAmountClaimed);
            }
        }
    }

    function distributeMissedRentAU(
        address[] memory _addresses
    ) public OnlyAdmin {
        uint256 totalAddresses = _addresses.length;
        uint256 _amount = missedRentCounter / totalAddresses;

        for (uint256 i = 0; i < totalAddresses; i++) {
            uint256 amountToTransfer = _amount;
            au.transferFrom(address(this), _addresses[i], amountToTransfer);
        }

        missedRentCounter = 0;
        emit MissedRentDistributed(missedRentCounter);
    }

    function transferAUOut(address _to, uint256 _amount) public OnlyAdmin {
        au.transfer(_to, _amount);
    }

    function spectatorClaimAU() public {
        uint256 _auToClaim = _calculateSpectatorAUEarned(msg.sender);
        if (_auToClaim <= 0) {
            revert NoAUToClaim();
        }

        au.mint(msg.sender, _auToClaim);
        au.transfer(msg.sender, _auToClaim);

        _spectatorAUClaimed[msg.sender] += _auToClaim;
        _spectatorAUUnclaimed[msg.sender] = 0;

        emit SpectatorClaimed(msg.sender, _auToClaim);
    }

    function setWeeklyAUAllowance(uint256 _allowance) public OnlyAdmin {
        weeklyAUAmount = _allowance;
    }

    function _calculateAUMinted(address _npc) internal view returns (uint256) {
        uint8 freqW = npcSpectate.getNPCWeeklyFrequency(_npc);
        uint256 npcWCount = npcSpectate.getWeeklyNPCsCount();
        uint256 freqT = npcSpectate.getNPCTotalFrequency(_npc);
        uint256 allCount = npcSpectate.getAllWeeklyFrequency();

        if (allCount == 0 || freqT == 0) return 0;

        uint256 npcWeight = (freqW * freqT) / (npcWCount * allCount);

        uint256 totalWeight = allCount;

        return (weeklyAUAmount * npcWeight) / totalWeight;
    }

    function _calculateSpectatorAUEarned(
        address _spectator
    ) internal view returns (uint256) {
        uint8 freqW = npcSpectate.getSpectatorWeeklyFrequency(_spectator);
        uint256 specWCount = npcSpectate.getWeeklySpectatorsCount();
        uint256 freqT = npcSpectate.getSpectatorTotalFrequency(_spectator);
        uint256 allCount = npcSpectate.getAllWeeklyFrequency();

        if (allCount == 0 || freqT == 0) return 0;

        uint256 npcWeight = (freqW * freqT) / (specWCount * allCount);

        uint256 totalWeight = allCount;

        return (weeklyAUAmount * npcWeight) / totalWeight;
    }

    function _updateWeekCounter() internal {
        if (block.timestamp >= lastWeekTimestamp + 1 weeks) {
            weekCounter += 1;
            lastWeekTimestamp = block.timestamp;
        }
    }

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

    function getNPCAUEarned(address _npc) public view returns (uint256) {
        return _npcAUEarned[_npc];
    }

    function getNPCAUOwed(address _npc) public view returns (uint256) {
        return _npcAUOwed[_npc];
    }

    function getNPCAUPaid(address _npc) public view returns (uint256) {
        return _npcAUPaid[_npc];
    }

    function getNPCLastRentClock(address _npc) public view returns (uint256) {
        return _npcs[_npc].lastRentClock;
    }
}
