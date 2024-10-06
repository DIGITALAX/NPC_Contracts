// votando por los espectadores sobre los npcs y las publicaciones específicas
// su actividad en la tabla
// el aquiler entre los npcs + los espectadores
// los npcs tienen que pagar el aquiler y el flujo del AU
// los manuales más tarde por la activadad de los npcs :)

// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.26;

import "./NPCLibrary.sol";
import "./NPCAccessControls.sol";

contract NPCVoting {
    string public symbol;
    string public name;
    NPCAccessControl public _npcAccessControls;
    address[] public nftAddresses;
    address[] public erc20Addresses;

    error InsufficientTokenBalance();
    error InvalidAddress();

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

    mapping(address => NPCLibrary.NPCScore) public _npcScores;
    mapping(address => mapping(address => NPCLibrary.NPCVote)) public _votes;

    constructor(address _npcAccessControlsAddress) {
        _npcAccessControls = NPCAccessControl(_npcAccessControlsAddress);
        symbol = "NPCV";
        name = "NPCVoting";
    }

    function voteForNPC(NPCLibrary.NPCVote memory _vote) public OnlySpectator {
        uint256 peso = _tokenWeighting();

        NPCLibrary.NPCScore storage npc = _npcScores[_vote.npc];
        NPCLibrary.NPCVote memory votoAnterior = _votes[_vote.voter][_vote.npc];

        if (votoAnterior.weight > 0) {
            _removePreviousVote(npc, votoAnterior);
        }

        _addNewVote(npc, _vote, peso);

        _votes[_vote.voter][_vote.npc] = _vote;
    }

    function npcScore(
        address _npc,
        string memory campo
    ) public view returns (uint256) {
        NPCLibrary.NPCScore memory npc = _npcScores[_npc];
        if (npc.totalWeight == 0) {
            return 0;
        }

        if (keccak256(abi.encodePacked(campo)) == keccak256("model")) {
            return npc.totalModel / npc.totalWeight;
        } else if (keccak256(abi.encodePacked(campo)) == keccak256("scene")) {
            return npc.totalScene / npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(campo)) == keccak256("chatContext")
        ) {
            return npc.totalChatContext / npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(campo)) == keccak256("appearance")
        ) {
            return npc.totalAppearance / npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(campo)) == keccak256("completedJobs")
        ) {
            return npc.totalCompletedJobs / npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(campo)) == keccak256("personality")
        ) {
            return npc.totalPersonality / npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(campo)) == keccak256("training")
        ) {
            return npc.totalTraining / npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(campo)) == keccak256("tokenizer")
        ) {
            return npc.totalTokenizer / npc.totalWeight;
        } else if (keccak256(abi.encodePacked(campo)) == keccak256("lora")) {
            return npc.totalLora / npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(campo)) == keccak256("spriteSheet")
        ) {
            return npc.totalSpriteSheet / npc.totalWeight;
        } else if (
            keccak256(abi.encodePacked(campo)) == keccak256("globalScore")
        ) {
            return npc.totalGlobalScore / npc.totalWeight;
        }

        return 0;
    }

    function _removePreviousVote(
        NPCLibrary.NPCScore storage npc,
        NPCLibrary.NPCVote memory votoAnterior
    ) internal {
        npc.totalModel -= votoAnterior.model * votoAnterior.weight;
        npc.totalScene -= votoAnterior.scene * votoAnterior.weight;
        npc.totalChatContext -= votoAnterior.chatContext * votoAnterior.weight;
        npc.totalAppearance -= votoAnterior.appearance * votoAnterior.weight;
        npc.totalCompletedJobs -=
            votoAnterior.completedJobs *
            votoAnterior.weight;
        npc.totalPersonality -= votoAnterior.personality * votoAnterior.weight;
        npc.totalTraining -= votoAnterior.training * votoAnterior.weight;
        npc.totalTokenizer -= votoAnterior.tokenizer * votoAnterior.weight;
        npc.totalLora -= votoAnterior.lora * votoAnterior.weight;
        npc.totalSpriteSheet -= votoAnterior.spriteSheet * votoAnterior.weight;
        npc.totalGlobalScore -= votoAnterior.globalScore * votoAnterior.weight;
        npc.totalWeight -= votoAnterior.weight;
    }

    function _addNewVote(
        NPCLibrary.NPCScore storage npc,
        NPCLibrary.NPCVote memory _vote,
        uint256 peso
    ) internal {
        npc.totalModel += _vote.model * peso;
        npc.totalScene += _vote.scene * peso;
        npc.totalChatContext += _vote.chatContext * peso;
        npc.totalAppearance += _vote.appearance * peso;
        npc.totalCompletedJobs += _vote.completedJobs * peso;
        npc.totalPersonality += _vote.personality * peso;
        npc.totalTraining += _vote.training * peso;
        npc.totalTokenizer += _vote.tokenizer * peso;
        npc.totalLora += _vote.lora * peso;
        npc.totalSpriteSheet += _vote.spriteSheet * peso;
        npc.totalGlobalScore += _vote.globalScore * peso;
        npc.totalWeight += peso;
    }

    function _holdsTokens() internal view returns (bool) {
        return true;
    }

    function _tokenWeighting() internal view returns (uint256) {

        address _voter = msg.sender;

        return 1;
    }

    function setNFTTokenAddresses(
        address[] memory _addresses
    ) public OnlyAdmin {}

    function setERC20TokenAddresses(
        address[] memory _addresses
    ) public OnlyAdmin {}
}
