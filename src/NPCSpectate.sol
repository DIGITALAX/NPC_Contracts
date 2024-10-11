// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.26;

import "./NPCLibrary.sol";
import "./NPCAccessControls.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NPCSpectate {
     NPCAccessControls public npcAccessControls;
    address[] private _spectators;
    address[] private _npcs;
    uint256[][] private _pubs;
    string public symbol;
    string public name;
    uint256 public weeklyClock;
    uint256 private _weeklyCountVotes;
    uint256 private _allCountVotes;

    error InsufficientTokenBalance();
    error InvalidAddress();

    event WeeklyReset(address reseter);
    event NPCVote(address spectator, address npc);
    event PubVote(
        address spectator,
        uint256 profileId,
        uint256 pubId
    );

    modifier OnlyAdmin() {
        if (!npcAccessControls.isAdmin(msg.sender)) {
            revert InvalidAddress();
        }
        _;
    }

    modifier OnlyAdminOrNPC() {
        if (!npcAccessControls.isAdmin(msg.sender) && !npcAccessControls.isNPC(msg.sender)) {
            revert InvalidAddress();
        }
        _;
    }


    modifier OnlySpectator() {
        if (!_holdsTokens()) {
            revert InsufficientTokenBalance();
        }
        _;
    }

      modifier OnlyValidNPC(address _npc) {
        if (!npcAccessControls.isNPC(_npc)) {
            revert InvalidAddress();
        }
        _;
    }




    mapping(address => mapping(address => NPCLibrary.NPCVote[]))
        private _spectatorToAllNPCVotes;
    mapping(address => mapping(uint256 => mapping(uint256 => NPCLibrary.PubVote[])))
        private _spectatorToAllPubVotes;
    mapping(address => NPCLibrary.Timer) private _spectatorNPCGlobalFrequency;
    mapping(address => NPCLibrary.Timer) private _spectatorPubGlobalFrequency;
    mapping(address => mapping(address => NPCLibrary.Timer))
        private _spectatorNPCLocalFrequency;
    mapping(address => mapping(uint256 => mapping(uint256 => NPCLibrary.Timer)))
        private _spectatorPubLocalFrequency;
        mapping(address => NPCLibrary.Timer) private _npcFrequency;
     mapping(address => NPCLibrary.Timer) private _spectatorFrequency;
          mapping(address => mapping(address => NPCLibrary.Timer)) private _spectatorGlobalTally;
        mapping(address => bool) private _weeklySpectatorRecorded;
mapping(uint256 => mapping(uint256 => bool)) private _weeklyPubRecorded;
            mapping(address =>  bool) private _weeklyNPCRecorded;
     

    constructor(address _npcAccessControlsAddress) {
        npcAccessControls = NPCAccessControls(_npcAccessControlsAddress);
        symbol = "NPCS";
        name = "NPCSpectate";
    }

    function voteForNPC(NPCLibrary.NPCVote memory _vote) public OnlySpectator OnlyValidNPC(_vote.npc) {

        _spectatorToAllNPCVotes[_vote.spectator][_vote.npc].push(_vote);
_spectatorGlobalTally[_vote.spectator][_vote.npc].total = _vote.global;
_spectatorGlobalTally[_vote.spectator][_vote.npc].weekly = _vote.global;
        _spectatorNPCLocalFrequency[_vote.spectator][_vote.npc].total += 1;
        _spectatorNPCGlobalFrequency[_vote.spectator].total += 1;
        _npcFrequency[_vote.npc].total += 1;
         _spectatorFrequency[_vote.spectator].total += 1;
         _spectatorNPCLocalFrequency[_vote.spectator][_vote.npc].weekly += 1;
        _spectatorNPCGlobalFrequency[_vote.spectator].weekly += 1;
        _npcFrequency[_vote.npc].weekly += 1;
      _spectatorFrequency[_vote.spectator].weekly += 1;

           if (!_weeklySpectatorRecorded[_vote.spectator]) {
            _spectators.push(_vote.spectator);
            _weeklySpectatorRecorded[_vote.spectator] = true;
        }

        if (!_weeklyNPCRecorded[_vote.npc]) {
            _npcs.push(_vote.npc);
            _weeklyNPCRecorded[_vote.npc] = true;
        }

_weeklyCountVotes++;
_allCountVotes++;
        emit NPCVote(msg.sender, _vote.npc);
    }

    function voteForPub(NPCLibrary.PubVote memory _vote) public OnlySpectator OnlyValidNPC(_vote.npc) {
           _spectatorToAllPubVotes[_vote.spectator][_vote.profileId][_vote.pubId].push(_vote);
_spectatorGlobalTally[_vote.spectator][_vote.npc].total = _vote.global;
_spectatorGlobalTally[_vote.spectator][_vote.npc].weekly = _vote.global;
        _spectatorPubLocalFrequency[_vote.spectator][_vote.profileId][_vote.pubId].total += 1;
        _spectatorPubGlobalFrequency[_vote.spectator].total += 1;
        _npcFrequency[_vote.npc].total += 1;
                 _spectatorFrequency[_vote.spectator].total += 1;
                _spectatorPubLocalFrequency[_vote.spectator][_vote.profileId][_vote.pubId].weekly += 1;
        _spectatorPubGlobalFrequency[_vote.spectator].weekly += 1;
        _npcFrequency[_vote.npc].weekly += 1;
         _spectatorFrequency[_vote.spectator].weekly += 1;



        if (!_weeklyPubRecorded[_vote.profileId][_vote.pubId]) {
            _pubs.push([_vote.profileId, _vote.pubId]);
            _weeklyPubRecorded[_vote.profileId][_vote.pubId] = true;
        }

            if (!_weeklySpectatorRecorded[_vote.spectator]) {
            _spectators.push(_vote.spectator);
            _weeklySpectatorRecorded[_vote.spectator] = true;
        }

        if (!_weeklyNPCRecorded[_vote.npc]) {
            _npcs.push(_vote.npc);
            _weeklyNPCRecorded[_vote.npc] = true;
        }

_allCountVotes++;
_weeklyCountVotes++;
        emit PubVote(msg.sender, _vote.profileId, _vote.pubId);
    }

    function _holdsTokens() internal view returns (bool) {
        address _spectator = msg.sender;

        bool _holdsEnoughERC20 = false;
        bool _holdsEnoughNFT = false;

            address[] memory _erc20Addresses = npcAccessControls
            .getERC20TokenAddresses();
        address[] memory _erc721Addresses = npcAccessControls
            .getERC721TokenAddresses();

        for (uint256 i = 0; i < _erc20Addresses.length; i++) {
            IERC20 erc20 = IERC20(_erc20Addresses[i]);
            if (
                erc20.balanceOf(_spectator) >= npcAccessControls.getERC20TokenThreshold(_erc20Addresses[i]) * npcAccessControls.getERC20TokenDecimal(_erc20Addresses[i])
            ) {
                _holdsEnoughERC20 = true;
                break;
            }
        }

        for (uint256 i = 0; i < _erc721Addresses.length; i++) {
            IERC721 nft = IERC721(_erc721Addresses[i]);
            if (nft.balanceOf(_spectator) >= 
            npcAccessControls.getERC721TokenThreshold(_erc721Addresses[i])
            
            ) {
                _holdsEnoughNFT = true;
                break;
            }
        }

        return _holdsEnoughERC20 || _holdsEnoughNFT;
    }




function weeklyReset() public OnlyAdminOrNPC {
    if (block.timestamp > weeklyClock + 1 weeks) {
        for (uint256 i = 0; i < _spectators.length; i++) {
            address _spectator = _spectators[i];
            _spectatorNPCGlobalFrequency[_spectator].weekly = 0;
            _spectatorPubGlobalFrequency[_spectator].weekly = 0;

            for (uint256 j = 0; j < _npcs.length; j++) {
                address npc = _npcs[j];
              delete  _spectatorNPCLocalFrequency[_spectator][npc].weekly;
              delete _spectatorGlobalTally[_spectator][npc].weekly;
            }

for (uint256 j = 0; j < _pubs.length; j++) {
    uint256 profileId = _pubs[j][0];
    uint256 pubId = _pubs[j][1];
    delete _spectatorPubLocalFrequency[_spectator][profileId][pubId].weekly;
    delete _weeklyPubRecorded[profileId][pubId];
}

 delete _weeklySpectatorRecorded[_spectator];
            delete _spectatorFrequency[_spectator].weekly;
        }

        for (uint256 i = 0; i < _npcs.length; i++) {
            address _npc = _npcs[i];
           delete _npcFrequency[_npc].weekly;
        delete   _weeklyNPCRecorded[_npc];
        }

  
        delete _spectators;
        delete _npcs;
        delete _pubs;

        weeklyClock = block.timestamp;

_weeklyCountVotes = 0;
        emit WeeklyReset(msg.sender);
    }
}

    function getNPCVoteComment(address _spectator, address _npc, uint256 _index) public view returns (string memory) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].comment;
    }

    function getNPCVoteModel(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].model;
    }

    function getNPCVoteScene(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].scene;
    }

        function getNPCVoteAppearance(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].appearance;
    }

       function getNPCVoteChatContext(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].chatContext;
    }

           function getNPCVoteCompletedJobs(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].completedJobs;
    }

      function getNPCVotePersonality(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].personality;
    }


      function getNPCVoteTraining(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].training;
    }

          function getNPCVoteTokenizer(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].tokenizer;
    }

       function getNPCVoteLora(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].lora;
    }

  function getNPCVoteSpriteSheet(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].spriteSheet;
    }

      function getNPCVoteGlobal(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].global;
    }


  function getPubVoteComment(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (string memory) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].comment;
    }

       function getPubVoteNPC(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (address) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].npc;
    }

     function getPubVoteModel(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (uint8) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].model;
    }

        function getPubVoteChatContext(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (uint8) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].chatContext;
    }

       function getPubVotePrompt(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (uint8) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].prompt;
    }

           function getPubVotePersonality(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (uint8) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].personality;
    }

        function getPubVoteStyle(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (uint8) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].style;
    }

        function getPubVoteMedia(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (uint8) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].media;
    }
      
      function getPubVoteTokenizer(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (uint8) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].tokenizer;
    }

         function getPubVoteGlobal(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (uint8) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].global;
    }

        function getSpectatorNPCTotalGlobalFrequency(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorNPCGlobalFrequency[_spectator].total;
    }


    function getSpectatorNPCWeeklyGlobalFrequency(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorNPCGlobalFrequency[_spectator].weekly;
    }

    function getSpectatorPubTotalGlobalFrequency(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorPubGlobalFrequency[_spectator].total;
    }

     function getSpectatorPubWeeklyGlobalFrequency(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorPubGlobalFrequency[_spectator].weekly;
    }


    function getSpectatorNPCTotalLocalFrequency(
        address _spectator,
        address _npc
    ) public view returns (uint256) {
        return _spectatorNPCLocalFrequency[_spectator][_npc].total;
    }

        function getSpectatorNPCTotalWeeklyFrequency(
        address _spectator,
        address _npc
    ) public view returns (uint256) {
        return _spectatorNPCLocalFrequency[_spectator][_npc].weekly;
    }

    function getNPCTotalFrequency(
        address _npc
    ) public view returns (uint256) {
        return _npcFrequency[_npc].total;
    }

    function getNPCWeeklyFrequency(
        address _npc
    ) public view returns (uint256) {
        return _npcFrequency[_npc].weekly;
    }
    
      function getSpectatorWeeklyFrequency(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorFrequency[_spectator].weekly;
    }

      function getSpectatorTotalFrequency(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorFrequency[_spectator].total;
    }

        function getGlobalScoreNPCTallyWeekly(
        address _spectator,
        address _npc
    ) public view returns (uint256) {
        return _spectatorGlobalTally[_spectator][_npc].weekly;
    }

      function getGlobalScoreNPCTallyTotal(
   address _spectator,
        address _npc
    ) public view returns (uint256) {
        return  _spectatorGlobalTally[_spectator][_npc].total;
    }


        function getSpectatorPubTotalLocalFrequency(
        address _spectator,
        uint256 _profileId,
        uint256 _pubId
    ) public view returns (uint256) {
        return _spectatorPubLocalFrequency[_spectator][_profileId][_pubId].total;
    }

    function getSpectatorPubWeeklyLocalFrequency(
        address _spectator,
        uint256 _profileId,
        uint256 _pubId
    ) public view returns (uint256) {
        return _spectatorPubLocalFrequency[_spectator][_profileId][_pubId].weekly;
    }

    function getWeeklySpectatorsCount()public view returns (uint256) {
        return _spectators.length;
    }
    
    function getWeeklyNPCsCount() public view returns (uint256) {
        return _npcs.length;
    }

function getAllWeeklyFrequency() public view returns (uint256) {
        return _weeklyCountVotes;
    }

function getAllTotalFrequency() public view returns (uint256) {
        return _allCountVotes;
    }

    function getWeeklySpectators()public view returns (address[] memory) {
        return _spectators;
    }

    function getWeeklyNPCs() public view returns (address[] memory) {
        return _npcs;
    }
}
