// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.26;

import "./NPCLibrary.sol";
import "./NPCAccessControls.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NPCSpectate {
    string public symbol;
    string public name;
    NPCAccessControl public _npcAccessControls;
    address[] public _nftAddresses;
    address[] public _erc20Addresses;

    error InsufficientTokenBalance();
    error InvalidAddress();

    event NPCVote(address spectator, address npc, uint8 weight);
    event PubVote(
        address spectator,
        uint256 profileId,
        uint256 pubId,
        uint8 weight
    );

    modifier OnlyAdmin() {
        if (!_npcAccessControls.isAdmin(msg.sender)) {
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

    mapping(address => NPCLibrary.NPCScore) private _npcScores;
    mapping(uint256 => mapping(uint256 => NPCLibrary.PubScore))
        private _pubScores;
    mapping(address => mapping(address => NPCLibrary.NPCVote))
        private _npcVotes;
    mapping(address => mapping(uint256 => mapping(uint256 => NPCLibrary.PubVote)))
        private _pubVotes;
    mapping(address => mapping(address => NPCLibrary.NPCVote[]))
        private _spectatorToAllNPCVotes;
    mapping(address => mapping(uint256 => mapping(uint256 => NPCLibrary.PubVote[])))
        private _spectatorToAllPubVotes;
    mapping(address => uint8) _spectatorToWeight;
    mapping(address => uint256) private _erc20Threshold;
    mapping(address => uint256) private _erc721Threshold;
    mapping(address => uint8) private _erc20Weight;
    mapping(address => uint8) private _erc721Weight;
    mapping(address => uint256) private _spectatorNPCGlobalFrequency;
    mapping(address => uint256) private _spectatorPubGlobalFrequency;
    mapping(address => mapping(address => uint256))
        private _spectatorNPCLocalFrequency;
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        private _spectatorPubLocalFrequency;

    constructor(address _npcAccessControlsAddress) {
        _npcAccessControls = NPCAccessControl(_npcAccessControlsAddress);
        symbol = "NPCS";
        name = "NPCSpectate";
    }

    function voteForNPC(NPCLibrary.NPCVote memory _vote) public OnlySpectator {
        uint8 _peso = _tokenWeighting();

        NPCLibrary.NPCScore storage _npc = _npcScores[_vote.npc];
        NPCLibrary.NPCVote memory _previousVote = _npcVotes[_vote.spectator][
            _vote.npc
        ];

        if (_previousVote.weight > 0) {
            _removePreviousNPCVote(_npc, _previousVote);
        }

        _addNewNPCVote(_npc, _vote, _peso);

        _npcVotes[_vote.spectator][_vote.npc] = _vote;
        _spectatorToWeight[_vote.spectator] = _peso;

        _spectatorNPCLocalFrequency[_vote.spectator][_vote.npc];
        _spectatorNPCGlobalFrequency[_vote.spectator];

        emit NPCVote(msg.sender, _vote.npc, _peso);
    }

    function voteForPub(NPCLibrary.PubVote memory _vote) public OnlySpectator {
        uint8 _peso = _tokenWeighting();

        NPCLibrary.PubScore storage _pub = _pubScores[_vote.profileId][
            _vote.pubId
        ];
        NPCLibrary.PubVote memory _previousVote = _pubVotes[_vote.spectator][
            _vote.profileId
        ][_vote.pubId];

        if (_previousVote.weight > 0) {
            _removePreviousPubVote(_pub, _previousVote);
        }

        _addNewPubVote(_pub, _vote, _peso);

        _pubVotes[_vote.spectator][_vote.profileId][_vote.pubId] = _vote;
        _spectatorToWeight[_vote.spectator] = _peso;

        _spectatorPubLocalFrequency[_vote.spectator][_vote.profileId][_vote.pubId] += 1;
        _spectatorPubGlobalFrequency[_vote.spectator] += 1;

        emit PubVote(msg.sender, _vote.profileId, _vote.pubId, _peso);
    }

    function getNPCScore(
        string memory _campo,
        address _npcAddress
    ) public view returns (uint256) {
        NPCLibrary.NPCScore memory _npc = _npcScores[_npcAddress];
        if (_npc.totalWeight == 0) {
            return 0;
        }

        if (keccak256(abi.encodePacked(_campo)) == keccak256("model")) {
            return _npc.totalModel / _npc.totalWeight;
        } else if (keccak256(abi.encodePacked(_campo)) == keccak256("scene")) {
            return _npc.totalScene / _npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("chatContext")
        ) {
            return _npc.totalChatContext / _npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("appearance")
        ) {
            return _npc.totalAppearance / _npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("completedJobs")
        ) {
            return _npc.totalCompletedJobs / _npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("personality")
        ) {
            return _npc.totalPersonality / _npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("training")
        ) {
            return _npc.totalTraining / _npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("tokenizer")
        ) {
            return _npc.totalTokenizer / _npc.totalWeight;
        } else if (keccak256(abi.encodePacked(_campo)) == keccak256("lora")) {
            return _npc.totalLora / _npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("spriteSheet")
        ) {
            return _npc.totalSpriteSheet / _npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("global")
        ) {
            return _npc.totalGlobal / _npc.totalWeight;
        }

        return 0;
    }

    function getPubScore(
        string memory _campo,
        uint256 _profileId,
        uint256 _pubId
    ) public view returns (uint256) {
        NPCLibrary.PubScore memory _pub = _pubScores[_profileId][_pubId];
        if (_pub.totalWeight == 0) {
            return 0;
        }

        if (keccak256(abi.encodePacked(_campo)) == keccak256("model")) {
            return _pub.totalModel / _pub.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("chatContext")
        ) {
            return _pub.totalChatContext / _pub.totalWeight;
        } else if (keccak256(abi.encodePacked(_campo)) == keccak256("prompt")) {
            return _pub.totalPrompt / _pub.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("personality")
        ) {
            return _pub.totalPersonality / _pub.totalWeight;
        } else if (keccak256(abi.encodePacked(_campo)) == keccak256("style")) {
            return _pub.totalStyle / _pub.totalWeight;
        } else if (keccak256(abi.encodePacked(_campo)) == keccak256("media")) {
            return _pub.totalMedia / _pub.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("tokenizer")
        ) {
            return _pub.totalTokenizer / _pub.totalWeight;
        } else if (
            keccak256(abi.encodePacked(_campo)) == keccak256("global")
        ) {
            return _pub.totalGlobal / _pub.totalWeight;
        }

        return 0;
    }

    function _removePreviousNPCVote(
        NPCLibrary.NPCScore storage _npc,
        NPCLibrary.NPCVote memory _previousVote
    ) internal {
        _npc.totalModel -= _previousVote.model * _previousVote.weight;
        _npc.totalScene -= _previousVote.scene * _previousVote.weight;
        _npc.totalChatContext -=
            _previousVote.chatContext *
            _previousVote.weight;
        _npc.totalAppearance -= _previousVote.appearance * _previousVote.weight;
        _npc.totalCompletedJobs -=
            _previousVote.completedJobs *
            _previousVote.weight;
        _npc.totalPersonality -=
            _previousVote.personality *
            _previousVote.weight;
        _npc.totalTraining -= _previousVote.training * _previousVote.weight;
        _npc.totalTokenizer -= _previousVote.tokenizer * _previousVote.weight;
        _npc.totalLora -= _previousVote.lora * _previousVote.weight;
        _npc.totalSpriteSheet -=
            _previousVote.spriteSheet *
            _previousVote.weight;
        _npc.totalGlobal -=
            _previousVote.global *
            _previousVote.weight;
        _npc.totalWeight -= _previousVote.weight;
    }

    function _addNewNPCVote(
        NPCLibrary.NPCScore storage _npc,
        NPCLibrary.NPCVote memory _vote,
        uint8 _peso
    ) internal {
        _npc.totalModel += _vote.model * _peso;
        _npc.totalScene += _vote.scene * _peso;
        _npc.totalChatContext += _vote.chatContext * _peso;
        _npc.totalAppearance += _vote.appearance * _peso;
        _npc.totalCompletedJobs += _vote.completedJobs * _peso;
        _npc.totalPersonality += _vote.personality * _peso;
        _npc.totalTraining += _vote.training * _peso;
        _npc.totalTokenizer += _vote.tokenizer * _peso;
        _npc.totalLora += _vote.lora * _peso;
        _npc.totalSpriteSheet += _vote.spriteSheet * _peso;
        _npc.totalGlobal += _vote.global * _peso;
        _npc.totalWeight += _peso;
    }

    function _removePreviousPubVote(
        NPCLibrary.PubScore storage _pub,
        NPCLibrary.PubVote memory _previousVote
    ) internal {
        _pub.totalModel -= _previousVote.model * _previousVote.weight;
        _pub.totalPrompt -= _previousVote.prompt * _previousVote.weight;
        _pub.totalChatContext -=
            _previousVote.chatContext *
            _previousVote.weight;
        _pub.totalPrompt -= _previousVote.prompt * _previousVote.weight;
        _pub.totalPersonality -=
            _previousVote.personality *
            _previousVote.weight;
        _pub.totalStyle -= _previousVote.style * _previousVote.weight;
        _pub.totalMedia -= _previousVote.media * _previousVote.weight;
        _pub.totalTokenizer -= _previousVote.tokenizer * _previousVote.weight;
        _pub.totalGlobal -=
            _previousVote.global *
            _previousVote.weight;
        _pub.totalWeight -= _previousVote.weight;
    }

    function _addNewPubVote(
        NPCLibrary.PubScore storage _pub,
        NPCLibrary.PubVote memory _vote,
        uint8 _peso
    ) internal {
        _pub.totalModel += _vote.model * _peso;
        _pub.totalPrompt += _vote.prompt * _peso;
        _pub.totalChatContext += _vote.chatContext * _peso;
        _pub.totalChatContext += _vote.chatContext * _peso;
        _pub.totalStyle += _vote.style * _peso;
        _pub.totalMedia += _vote.media * _peso;
        _pub.totalPersonality += _vote.personality * _peso;
        _pub.totalTokenizer += _vote.tokenizer * _peso;
        _pub.totalGlobal += _vote.global * _peso;
        _pub.totalWeight += _peso;
    }

    function _holdsTokens() internal view returns (bool) {
        address _spectator = msg.sender;

        bool _holdsEnoughERC20 = false;
        bool _holdsEnoughNFT = false;

        for (uint256 i = 0; i < _erc20Addresses.length; i++) {
            IERC20 erc20 = IERC20(_erc20Addresses[i]);
            if (
                erc20.balanceOf(_spectator) >= _erc20Threshold[_erc20Addresses[i]]
            ) {
                _holdsEnoughERC20 = true;
                break;
            }
        }

        for (uint256 i = 0; i < _nftAddresses.length; i++) {
            IERC721 nft = IERC721(_nftAddresses[i]);
            if (nft.balanceOf(_spectator) >= _erc721Threshold[_nftAddresses[i]]) {
                _holdsEnoughNFT = true;
                break;
            }
        }

        return _holdsEnoughERC20 && _holdsEnoughNFT;
    }

    function _tokenWeighting() internal view returns (uint8) {
        address _spectator = msg.sender;

        uint8 _totalWeight = 0;
        uint256 totalERC20Balance = 0;
        uint256 totalNFTBalance = 0;

        for (uint256 i = 0; i < _erc20Addresses.length; i++) {
            IERC20 _erc20 = IERC20(_erc20Addresses[i]);
            uint256 _balance = _erc20.balanceOf(_spectator);
            uint8 _tokenWeight = _erc20Weight[_erc20Addresses[i]];

            if (_balance > 0 && _tokenWeight > 0) {
                totalERC20Balance += _balance * _tokenWeight;
            }
        }

        for (uint256 i = 0; i < _nftAddresses.length; i++) {
            IERC721 _nft = IERC721(_nftAddresses[i]);
            uint256 _nftBalance = _nft.balanceOf(_spectator);
            uint8 _nftWeight = _erc721Weight[_nftAddresses[i]];

            if (_nftBalance > 0 && _nftWeight > 0) {
                totalNFTBalance += _nftBalance * _nftWeight;
            }
        }

        uint256 totalBalance = totalERC20Balance + totalNFTBalance;

        if (totalBalance > 0) {
            _totalWeight = uint8(
                (totalBalance * 100) / (totalERC20Balance + totalNFTBalance)
            );
        }

        if (_totalWeight > 100) {
            _totalWeight = 100;
        }

        return _totalWeight;
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

      function getNPCVoteWeight(address _spectator, address _npc, uint256 _index) public view returns (uint8) {
        return _spectatorToAllNPCVotes[_spectator][_npc][_index].weight;
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

             function getPubVoteWeight(address _spectator, uint256 _profileId, uint256 _pubId, uint256 _index) public view returns (uint8) {
        return _spectatorToAllPubVotes[_spectator][_profileId][_pubId][_index].weight;
    }
      
 



    function getSpectatorCurrentWeight(address _spectator) public view returns (uint8) {
        return _spectatorToWeight[_spectator];
    }

    function getSpectatorNPCGlobalFrequency(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorNPCGlobalFrequency[_spectator];
    }

    function getSpectatorPubGlobalFrequency(
        address _spectator
    ) public view returns (uint256) {
        return _spectatorPubGlobalFrequency[_spectator];
    }

    function getSpectatorNPCLocalFrequency(
        address _spectator,
        address _npc
    ) public view returns (uint256) {
        return _spectatorNPCLocalFrequency[_spectator][_npc];
    }

    function getSpectatorPubLocalFrequency(
        address _spectator,
        uint256 _profileId,
        uint256 _pubId
    ) public view returns (uint256) {
        return _spectatorPubLocalFrequency[_spectator][_profileId][_pubId];
    }

    function setERC20Thresholds(
        address _token,
        uint256 _threshold
    ) public OnlyAdmin {
        _erc20Threshold[_token] = _threshold;
    }

    function setERC721Thresholds(
        address _token,
        uint256 _threshold
    ) public OnlyAdmin {
        _erc721Threshold[_token] = _threshold;
    }

    function setERC20Weight(address _token, uint8 _weight) public OnlyAdmin {
        _erc20Weight[_token] = _weight;
    }

    function setERC721Weight(address _token, uint8 _weight) public OnlyAdmin {
        _erc721Weight[_token] = _weight;
    }

    function setERC20TokenAddresses(
        address[] memory _addresses
    ) public OnlyAdmin {
        _erc20Addresses = _addresses;
    }

    function setNFTTokenAddresses(
        address[] memory _addresses
    ) public OnlyAdmin {
        _nftAddresses = _addresses;
    }

    function getNFTTokenAddresses() public view returns (address[] memory) {
        return _nftAddresses;
    }

    function getERC20TokenAddresses() public view returns (address[] memory) {
        return _erc20Addresses;
    }
}
