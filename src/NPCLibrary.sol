// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.26;

contract NPCLibrary {
    struct NPCVote {
        string comment;
        address npc;
        address spectator;
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
        uint8 global;
        uint8 weight;
    }

    struct NPCScore {
        uint8 totalModel;
        uint8 totalScene;
        uint8 totalChatContext;
        uint8 totalAppearance;
        uint8 totalCompletedJobs;
        uint8 totalPersonality;
        uint8 totalTraining;
        uint8 totalTokenizer;
        uint8 totalLora;
        uint8 totalSpriteSheet;
        uint8 totalGlobal;
        uint8 totalWeight;
    }

    struct PubVote {
        string comment;
        address npc;
        address spectator;
        uint256 profileId;
        uint256 pubId;
        uint8 model;
        uint8 chatContext;
        uint8 prompt;
        uint8 personality;
        uint8 style;
        uint8 media;
        uint8 tokenizer;
        uint8 global;
        uint8 weight;
    }

    struct PubScore {
        uint256 profileId;
        uint256 pubId;
        uint8 totalModel;
        uint8 totalChatContext;
        uint8 totalPrompt;
        uint8 totalPersonality;
        uint8 totalStyle;
        uint8 totalMedia;
        uint8 totalTokenizer;
        uint8 totalGlobal;
        uint8 totalWeight;
    }

    struct NPCRent {
        address npc;
        uint256 lastRentClock;
        uint256 activeWeeks;
        bool initialized;
    }
    
    struct Timer {
        uint256 total;
        uint256 weekly;
    }

        struct NPCAU {
        uint256 rent;
        uint256 claimed;
    }
}
