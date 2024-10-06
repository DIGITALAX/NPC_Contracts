// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.26;

contract NPCLibrary {
    struct NPCVote {
        address npc;
        address voter;
        uint8 model;
        uint8 scene;
        uint8 chatContext;
        uint8 appearance;
        uint8 completedJobs;
        uint8 personality;
        uint8 training;
        uint8 tokenizer;
        uint8 lora;
        uint8 spriteSheet;
        uint8 globalScore;
        uint8 weight;
    }

    struct NPCScore {
        uint256 totalModel;
        uint256 totalScene;
        uint256 totalChatContext;
        uint256 totalAppearance;
        uint256 totalCompletedJobs;
        uint256 totalPersonality;
        uint256 totalTraining;
        uint256 totalTokenizer;
        uint256 totalLora;
        uint256 totalSpriteSheet;
        uint256 totalGlobalScore;
        uint256 totalWeight;
    }

    struct PublicationVote {
        uint256 profileId;
        uint256 pubId;
    }

    struct PublicationTotal {
        uint256 profileId;
        uint256 pubId;
    }
}
