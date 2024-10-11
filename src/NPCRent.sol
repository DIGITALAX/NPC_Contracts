// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.26;

import "./NPCLibrary.sol";
import "./NPCAccessControls.sol";
import "./AU.sol";
import "./NPCSpectate.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {console} from "forge-std/console.sol";

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
    error AlreadyClaimed();

    event RentPaid(address npc, uint256 auAmountClaimed, uint256 auAmountPaid);
    event RentMissed(address npc, uint256 auAmountPaid);
    event MissedRentDistributed(uint256 amount);
    event SpectatorClaimed(address spectator, uint256 auAmountClaimed);
    event SpectatorClaimedAll(address spectator, uint256 auAmountClaimed);
    event SpectatorWeightsCalculated(
        address npc,
        uint256 globalWeight,
        uint256 globalWeightNormalized
    );
    event NPCWeightsCalculated(address npc, uint256 globalWeight);

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

    modifier OnlyNPCOrAdmin() {
        if (
            !npcAccessControls.isAdmin(msg.sender) &&
            !npcAccessControls.isNPC(msg.sender)
        ) {
            revert InvalidAddress();
        }
        _;
    }

    mapping(address => uint256) private _spectatorAUClaimed;
    mapping(address => uint256) private _spectatorAUUnclaimed;
    mapping(address => uint256[]) private _spectatorAllWeights;
    mapping(address => uint256) private _spectatorWeeklyWeight;
    mapping(address => uint256[]) private _spectatorAllUnnormalizedWeights;
    mapping(address => uint256) private _spectatorWeeklyUnnormalizedWeight;
    mapping(address => NPCLibrary.NPCWeight[])
        private _npcAllUnnormalizedWeights;
    mapping(address => NPCLibrary.NPCWeight)
        private _npcWeeklyUnnormalizedWeight;
    mapping(address => NPCLibrary.NPCWeight[]) private _npcAllWeights;
    mapping(address => NPCLibrary.NPCWeight) private _npcWeeklyWeight;
    mapping(address => mapping(uint256 => uint256)) private _npcPortion;
    mapping(address => mapping(uint256 => uint256)) private _spectatorPortion;
    mapping(address => uint256) private _npcAUOwed;
    mapping(address => NPCLibrary.NPCRent) private _npcRent;
    mapping(uint256 => uint256) private _weeklyAUPaidTracker;
    mapping(uint256 => uint256) private _weeklyAUAllowanceTracker;
    mapping(uint256 => mapping(address => NPCLibrary.NPCAU)) private _npcAUWeek;
    mapping(address => mapping(address => mapping(uint256 => bool)))
        private _spectatorAUWeek;
    mapping(address => mapping(uint256 => uint256))
        private _spectatorWeeklyAUClaim;
    mapping(uint256 => address[]) private _activeNPCs;

    constructor(
        address _npcAccessControlsAddress,
        address _npcSpectateAddress
    ) {
        npcAccessControls = NPCAccessControls(_npcAccessControlsAddress);
        npcSpectate = NPCSpectate(_npcSpectateAddress);
        symbol = "NPCR";
        name = "NPCRent";
    }

    function NPCPayRentAndClaim() public OnlyNPC {
        _updateWeekCounter();

        if (!_npcRent[msg.sender].initialized) {
            _npcRent[msg.sender].initialized = true;
            _npcRent[msg.sender].npc = msg.sender;
            _npcRent[msg.sender].lastRentClock = 0;
        }

        if (block.timestamp >= _npcRent[msg.sender].lastRentClock + 1 weeks) {
            uint256 _auAmount = (weeklyAUAmount *
                _npcPortion[msg.sender][weekCounter - 1]) / 10000;

            if (_auAmount <= 0) {
                revert NoAUToClaim();
            }

            uint256 _auAmountClaimed = (_auAmount * 9) / 100;
            uint256 _auAmountPaid = (_auAmount * 91) / 100;

            if (
                block.timestamp <=
                _npcRent[msg.sender].lastRentClock + 1 weeks + 3 days
            ) {
                au.mint(msg.sender, _auAmountClaimed);
                au.mint(address(this), _auAmountPaid);
                _npcRent[msg.sender].lastRentClock = block.timestamp;
                _npcRent[msg.sender].activeWeeks += 1;
                _npcAUOwed[msg.sender] += _auAmountPaid;

                _weeklyAUPaidTracker[weekCounter - 1] += _auAmountPaid;
                _npcAUWeek[weekCounter - 1][msg.sender] = NPCLibrary.NPCAU({
                    rent: _auAmountClaimed,
                    claimed: _auAmountPaid
                });
                _activeNPCs[weekCounter - 1].push(msg.sender);

                emit RentPaid(msg.sender, _auAmountClaimed, _auAmountPaid);
            } else {
                au.mint(address(this), _auAmountPaid + _auAmountClaimed);
                missedRentCounter += _auAmountPaid + _auAmountClaimed;
                _npcAUOwed[msg.sender] += _auAmountPaid + _auAmountClaimed;
                _npcRent[msg.sender].activeWeeks += 1;
                _npcRent[msg.sender].lastRentClock = block.timestamp;
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
            au.transferFrom(address(this), _addresses[i], _amount);
        }

        emit MissedRentDistributed(missedRentCounter);
        missedRentCounter = 0;
    }

    function transferAUOut(address _to, uint256 _amount) public OnlyAdmin {
        au.transfer(_to, _amount);
    }

    function spectatorClaimAU(address _npc, bool _all, uint256 _week) public {
        if (_all) {
            uint256 _amountClaimed = 0;
            for (uint256 i; i < _activeNPCs[_week].length; i++) {
                if (
                    !_spectatorAUWeek[msg.sender][_activeNPCs[_week][i]][_week]
                ) {
                    uint256 _auToClaim = (_npcAUWeek[_week][
                        _activeNPCs[_week][i]
                    ].claimed * _spectatorPortion[msg.sender][_week]) / 10000;

                    if (_auToClaim >= 0) {
                        _spectatorAUWeek[msg.sender][_activeNPCs[_week][i]][
                            _week
                        ] = true;

                        _spectatorAUClaimed[msg.sender] += _auToClaim;
                        _spectatorWeeklyAUClaim[msg.sender][
                            _week
                        ] += _auToClaim;
                        _amountClaimed += _auToClaim;
                    }
                }
            }
            if (_amountClaimed > 0) {
                au.transfer(msg.sender, _amountClaimed);
                emit SpectatorClaimedAll(msg.sender, _amountClaimed);
            } else {
                revert NoAUToClaim();
            }
        } else {
            if (_spectatorAUWeek[msg.sender][_npc][_week]) {
                revert AlreadyClaimed();
            }

            uint256 _auToClaim = (_npcAUWeek[_week][_npc].claimed *
                _spectatorPortion[msg.sender][_week]) / 10000;

            if (_auToClaim <= 0) {
                revert NoAUToClaim();
            }

            _spectatorAUWeek[msg.sender][_npc][_week] = true;

            au.transfer(msg.sender, _auToClaim);

            _spectatorAUClaimed[msg.sender] += _auToClaim;
            _spectatorWeeklyAUClaim[msg.sender][_week] += _auToClaim;

            emit SpectatorClaimed(msg.sender, _auToClaim);
        }
    }

    function setWeeklyAUAllowance(uint256 _allowance) public OnlyAdmin {
        weeklyAUAmount = _allowance;
        _weeklyAUAllowanceTracker[weekCounter] = _allowance;
    }

    function calculateWeeklySpectatorWeights() public OnlyNPCOrAdmin {
        _updateWeekCounter();

        address[] memory _spectators = npcSpectate.getWeeklySpectators();

        uint256 _totalGlobalWeight = 0;
        uint256 _totalGlobalWeightNormalized = 0;

        uint256 totalWeekly = npcSpectate.getAllWeeklyFrequency();
        uint256 total = npcSpectate.getAllTotalFrequency();

        for (uint256 i = 0; i < _spectators.length; i++) {
            address _spectator = _spectators[i];
            uint256 _tokenW = _tokenWeighting(_spectator);
            uint256 specWeekly = npcSpectate.getSpectatorWeeklyFrequency(
                _spectator
            );
            uint256 specTotal = npcSpectate.getSpectatorTotalFrequency(
                _spectator
            );
            uint256 normalizedActivityWeight = 0;
            if (totalWeekly > 0) {
                normalizedActivityWeight = (specWeekly * 50) / totalWeekly;
            }
            if (total > 0) {
                normalizedActivityWeight += (specTotal * 50) / total;
            }
            _tokenW = (_tokenW * normalizedActivityWeight) / 100;

            _totalGlobalWeight += _tokenW;

            _spectatorAllUnnormalizedWeights[_spectator].push(_tokenW);
            _spectatorWeeklyUnnormalizedWeight[_spectator] = _tokenW;
        }

        for (uint256 i = 0; i < _spectators.length; i++) {
            address _spectator = _spectators[i];
            uint256 _tokenW = 0;
            if (_totalGlobalWeight > 0) {
                _tokenW =
                    (_spectatorWeeklyUnnormalizedWeight[_spectator] * 100) /
                    _totalGlobalWeight;
            }
            _totalGlobalWeightNormalized += _tokenW;
            _spectatorAllWeights[_spectator].push(_tokenW);
            _spectatorWeeklyWeight[_spectator] = _tokenW;
        }

        if (_totalGlobalWeightNormalized != 100) {
            uint256 difference = 100 - _totalGlobalWeightNormalized;
            address maxWeightSpectator;
            uint256 maxWeight = 0;
            for (uint256 i = 0; i < _spectators.length; i++) {
                address _spectator = _spectators[i];
                if (_spectatorWeeklyWeight[_spectator] > maxWeight) {
                    maxWeight = _spectatorWeeklyWeight[_spectator];
                    maxWeightSpectator = _spectator;
                }
            }
            _spectatorWeeklyWeight[maxWeightSpectator] += difference;
            _spectatorAllWeights[maxWeightSpectator][
                _spectatorAllWeights[maxWeightSpectator].length - 1
            ] += difference;
        }

        _calculateSpectatorPortions();

        emit SpectatorWeightsCalculated(
            msg.sender,
            _totalGlobalWeight,
            _totalGlobalWeightNormalized
        );
    }

    function _tokenWeighting(
        address _spectator
    ) internal view returns (uint256) {
        uint256 totalERC20Weight = 0;
        uint256 totalNFTWeight = 0;

        address[] memory _erc20Addresses = npcAccessControls
            .getERC20TokenAddresses();
        address[] memory _erc721Addresses = npcAccessControls
            .getERC721TokenAddresses();

        for (uint256 i = 0; i < _erc20Addresses.length; i++) {
            IERC20 _erc20 = IERC20(_erc20Addresses[i]);
            uint256 _balance = _erc20.balanceOf(_spectator);
            uint256 _tokenWeight = npcAccessControls.getERC20TokenWeight(
                _erc20Addresses[i]
            );

            if (_balance > 0 && _tokenWeight > 0) {
                totalERC20Weight += _balance * _tokenWeight;
            }
        }

        for (uint256 i = 0; i < _erc721Addresses.length; i++) {
            IERC721 _nft = IERC721(_erc721Addresses[i]);
            uint256 _balance = _nft.balanceOf(_spectator);
            uint256 _nftWeight = npcAccessControls.getERC721TokenWeight(
                _erc721Addresses[i]
            );

            if (_balance > 0 && _nftWeight > 0) {
                totalNFTWeight += _balance * _nftWeight;
            }
        }

        uint256 totalWeight = totalERC20Weight + totalNFTWeight;
        return totalWeight;
    }

    function calculateWeeklyNPCWeights() public OnlyNPCOrAdmin {
        _updateWeekCounter();

        address[] memory _npcs = npcSpectate.getWeeklyNPCs();
        address[] memory _spectators = npcSpectate.getWeeklySpectators();
        uint256 _totalNPCWeightWeekly = 0;
        uint256 _totalNPCWeightGlobal = 0;

        for (uint256 i = 0; i < _npcs.length; i++) {
            address _npc = _npcs[i];
            uint256 _totalGlobal = 0;
            uint256 _weeklyGlobal = 0;

            for (uint256 j = 0; j < _spectators.length; j++) {
                address _spectator = _spectators[i];

                _weeklyGlobal +=
                    npcSpectate.getGlobalScoreNPCTallyWeekly(_spectator, _npc) *
                    _spectatorWeeklyWeight[_spectator];
                _totalGlobal +=
                    npcSpectate.getGlobalScoreNPCTallyTotal(_spectator, _npc) *
                    _spectatorWeeklyWeight[_spectator];
            }
            NPCLibrary.NPCWeight memory _weight = NPCLibrary.NPCWeight({
                weekly: _weeklyGlobal,
                total: _totalGlobal
            });

            _npcWeeklyUnnormalizedWeight[_npc] = _weight;
            _npcAllUnnormalizedWeights[_npc].push(_weight);
            _totalNPCWeightWeekly += _weeklyGlobal;
            _totalNPCWeightGlobal += _totalGlobal;
        }

        for (uint256 i = 0; i < _npcs.length; i++) {
            uint256 _weekly = 0;
            uint256 _total = 0;
            address _npc = _npcs[i];
            if (_totalNPCWeightWeekly > 0) {
                _weekly =
                    (_npcWeeklyUnnormalizedWeight[_npc].weekly * 100) /
                    _totalNPCWeightWeekly;
            }

            if (_totalNPCWeightGlobal > 0) {
                _total =
                    (_npcWeeklyUnnormalizedWeight[_npc].total * 100) /
                    _totalNPCWeightGlobal;
            }

            NPCLibrary.NPCWeight memory _weight = NPCLibrary.NPCWeight({
                weekly: _weekly,
                total: _total
            });

            _npcWeeklyWeight[_npc] = _weight;
            _npcAllWeights[_npc].push(_weight);
        }

        _calculateNPCPortions();

        emit NPCWeightsCalculated(msg.sender, _totalNPCWeightGlobal);
    }

    function _calculateSpectatorPortions() internal {
        uint256 _sumOfNormalizedWeights = 0;

        address[] memory _spectators = npcSpectate.getWeeklySpectators();

        for (uint256 i = 0; i < _spectators.length; i++) {
            address _spectator = _spectators[i];
            _sumOfNormalizedWeights += _spectatorWeeklyWeight[_spectator];
        }

        for (uint256 i = 0; i < _spectators.length; i++) {
            address _spectator = _spectators[i];
            uint256 _portion = 0;
            if (_sumOfNormalizedWeights > 0) {
                _portion =
                    (_spectatorWeeklyWeight[_spectator] * 10000) /
                    _sumOfNormalizedWeights;
            }

            _spectatorPortion[_spectator][weekCounter] = _portion;
        }
    }

    function _calculateNPCPortions() internal {
        uint256 _sumOfNormalizedWeights = 0;

        address[] memory _npcs = npcSpectate.getWeeklyNPCs();

        for (uint256 i = 0; i < _npcs.length; i++) {
            address _npc = _npcs[i];
            _sumOfNormalizedWeights += _npcWeeklyWeight[_npc].weekly;
        }

        for (uint256 i = 0; i < _npcs.length; i++) {
            address _npc = _npcs[i];
            uint256 _portion = 0;
            if (_sumOfNormalizedWeights > 0) {
                _portion =
                    (_npcWeeklyWeight[_npc].weekly * 10000) /
                    _sumOfNormalizedWeights;
            }
            _npcPortion[_npc][weekCounter] = _portion;
        }
    }

    function _updateWeekCounter() internal {
        if (block.timestamp >= lastWeekTimestamp + 1 weeks) {
            weekCounter += 1;
            lastWeekTimestamp = block.timestamp;

            address[] memory _spectators = npcSpectate.getWeeklySpectators();
            address[] memory _npcs = npcSpectate.getWeeklyNPCs();

            for (uint256 i = 0; i < _spectators.length; i++) {
                address _spectator = _spectators[i];

                delete _spectatorWeeklyWeight[_spectator];
                delete _spectatorWeeklyUnnormalizedWeight[_spectator];
            }

            for (uint256 i = 0; i < _npcs.length; i++) {
                address _npc = _npcs[i];
                delete _npcWeeklyWeight[_npc];
                delete _npcWeeklyUnnormalizedWeight[_npc];
            }
        }
    }

    function setAU(address _auAddress) public OnlyAdmin {
        au = AU(_auAddress);
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

    function getSpectatorWeightByWeek(
        address _spectator,
        uint256 _indice
    ) public view returns (uint256) {
        return _spectatorAllWeights[_spectator][_indice];
    }

    function getSpectatorCurrentWeekWeight(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorWeeklyWeight[_spectator];
    }

    function getSpectatorUnnormalizedWeightByWeek(
        address _spectator,
        uint256 _indice
    ) public view returns (uint256) {
        return _spectatorAllUnnormalizedWeights[_spectator][_indice];
    }

    function getSpectatorPortion(
        address _spectator,
        uint256 _week
    ) public view returns (uint256) {
        return _spectatorPortion[_spectator][_week];
    }

    function getSpectatorUnnormalizedCurrentWeekWeight(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorWeeklyUnnormalizedWeight[_spectator];
    }

    function getNPCUnnormalizedWeightByWeekWeekly(
        address _npc,
        uint256 _indice
    ) public view returns (uint256) {
        return _npcAllUnnormalizedWeights[_npc][_indice].weekly;
    }

    function getNPCUnnormalizedWeightByWeekTotal(
        address _npc,
        uint256 _indice
    ) public view returns (uint256) {
        return _npcAllUnnormalizedWeights[_npc][_indice].total;
    }

    function getNPCCurrentUnnormalizedWeightedScoreWeekly(
        address _npc
    ) public view returns (uint256) {
        return _npcWeeklyUnnormalizedWeight[_npc].weekly;
    }

    function getNPCCurrentUnnormalizedWeightedScoreTotal(
        address _npc
    ) public view returns (uint256) {
        return _npcWeeklyUnnormalizedWeight[_npc].total;
    }

    function getNPCWeightByWeekWeekly(
        address _npc,
        uint256 _indice
    ) public view returns (uint256) {
        return _npcAllWeights[_npc][_indice].weekly;
    }

    function getNPCWeightByWeekTotal(
        address _npc,
        uint256 _indice
    ) public view returns (uint256) {
        return _npcAllWeights[_npc][_indice].total;
    }

    function getNPCCurrentWeightedScoreWeekly(
        address _npc
    ) public view returns (uint256) {
        return _npcWeeklyWeight[_npc].weekly;
    }

    function getNPCCurrentWeightedScoreTotal(
        address _npc
    ) public view returns (uint256) {
        return _npcWeeklyWeight[_npc].total;
    }

    function getNPCPortion(
        address _spectator,
        uint256 _week
    ) public view returns (uint256) {
        return _npcPortion[_spectator][_week];
    }

    function getNPCAUOwed(address _npc) public view returns (uint256) {
        return _npcAUOwed[_npc];
    }

    function getNPCIsInitialized(address _npc) public view returns (bool) {
        return _npcRent[_npc].initialized;
    }

    function getNPCActiveWeeks(address _npc) public view returns (uint256) {
        return _npcRent[_npc].activeWeeks;
    }

    function getNPCLastRentClock(address _npc) public view returns (uint256) {
        return _npcRent[_npc].lastRentClock;
    }

    function getActiveWeeklyNPCs(
        uint256 _week
    ) public view returns (address[] memory) {
        return _activeNPCs[_week];
    }

    function getSpectatorHasClaimedAUByWeek(
        address _spectator,
        address _npc,
        uint256 _week
    ) public view returns (bool) {
        return _spectatorAUWeek[_spectator][_npc][_week];
    }

    function getSpectatorClaimedAUByWeek(
        address _spectator,
        uint256 _week
    ) public view returns (uint256) {
        return _spectatorWeeklyAUClaim[_spectator][_week];
    }

    function getTotalAUPaidByWeek(uint256 _week) public view returns (uint256) {
        return _weeklyAUPaidTracker[_week];
    }

    function getTotalAUAllowanceByWeek(
        uint256 _week
    ) public view returns (uint256) {
        return _weeklyAUAllowanceTracker[_week];
    }

    function getNPCAuRentByWeek(
        address _npc,
        uint256 _week
    ) public view returns (uint256) {
        return _npcAUWeek[_week][_npc].rent;
    }

    function getNPCAuClaimedByWeek(
        address _npc,
        uint256 _week
    ) public view returns (uint256) {
        return _npcAUWeek[_week][_npc].claimed;
    }
}
