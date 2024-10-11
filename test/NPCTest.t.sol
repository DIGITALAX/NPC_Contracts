// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/NPCRent.sol";
import "../src/NPCAccessControls.sol";
import "../src/AU.sol";
import "../src/NPCSpectate.sol";
import "../src/TestERC721.sol";
import "../src/TestERC20.sol";
import {console} from "forge-std/console.sol";

contract NPCTest is Test {
    NPCRent public npcRent;
    NPCAccessControls public npcAccessControls;
    NPCSpectate public npcSpectate;
    AU public au;
    TestERC20 public mona;
    TestERC20 public delta;
    TestERC721 public genesis;
    TestERC721 public fashion;

    address public admin = address(0x1);
    address public npc1 = address(0x2);
        address public npc2 = address(0x3);
    address public spectator1 = address(0x4);
    address public spectator2 = address(0x5);

    bytes32 constant NO_AU_TO_CLAIM_ERROR = keccak256("NoAUToClaim()");
    bytes32 constant INSUFFICIENTE_TOKENS_ERROR = keccak256("InsufficientTokenBalance()");
    bytes32 constant INVALID_ADDRESS_ERROR = keccak256("InvalidAddress()");
    

    function setUp() public {
        npcAccessControls = new NPCAccessControls();
        npcSpectate = new NPCSpectate(address(npcAccessControls));
        npcRent = new NPCRent(address(npcAccessControls), address(npcSpectate));
        au = new AU(address(npcAccessControls), address(npcRent));
        npcRent.setAU(address(au));

        mona = new TestERC20();
        delta = new TestERC20();
        genesis = new TestERC721();
        fashion = new TestERC721();

        vm.prank(address(this));
        npcAccessControls.addAdmin(admin);
                  npcAccessControls.setERC20Value(address(mona), 100, 20, 1000000000000000000);
    npcAccessControls.setERC20Value(address(delta), 50, 1, 1000000000000000000);
      npcAccessControls.setERC721Value(address(genesis), 90, 1);
  npcAccessControls.setERC721Value(address(fashion), 50, 5);

              address[] memory erc20s = new address[](2);
        erc20s[0] =    address(mona);
        erc20s[1] = address(delta);

                    address[] memory erc721s = new address[](2);
        erc721s[0] =    address(genesis);
        erc721s[1] = address(fashion);

        npcAccessControls.setERC20Addresses(erc20s);
        npcAccessControls.setERC721Addresses(erc721s);
    }

    function testConstructorInitializesValues() public view {
        assertEq(npcRent.symbol(), "NPCR");
        assertEq(npcRent.name(), "NPCRent");
        assertEq(
            address(npcRent.npcAccessControls()),
            address(npcAccessControls)
        );
        assertEq(address(npcRent.npcSpectate()), address(npcSpectate));
        assertEq(address(npcRent.au()), address(au));
    }

    function testNPCPayRentAndClaim_NoAU() public {
        vm.prank(admin);
        npcAccessControls.addNPC(npc1);

        vm.prank(admin);
        npcRent.setWeeklyAUAllowance(1000);

        vm.warp(block.timestamp + 1 weeks + 4 days);

        assertEq(au.totalSupply(), 0);

        vm.prank(npc1);

        try npcRent.NPCPayRentAndClaim() {
            fail();
        } catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(NO_AU_TO_CLAIM_ERROR));
        }
    }

    function testVote_noTokens() public {
      npcAccessControls.addNPC(npc1);

        vm.prank(spectator1);

  NPCLibrary.NPCVote memory vote = NPCLibrary.NPCVote({
         npc: npc1,
         spectator: spectator1,
            model: 50,
            scene: 40,
            chatContext: 30,
            appearance: 20,
            completedJobs: 15,
            personality: 65,
            training: 75,
            tokenizer: 80,
            lora: 10,
            spriteSheet: 50,
            global: 11,
            comment: "Good NPC"
        });

      try  npcSpectate.voteForNPC(vote) {
        fail();
      }  catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(INSUFFICIENTE_TOKENS_ERROR));
        }



  NPCLibrary.PubVote memory vote_pub = NPCLibrary.PubVote({
            npc: npc1,
               spectator: spectator1,
            model: 54,
            chatContext: 34,
            personality: 63,
   pubId: 100,
   profileId: 25678,
   prompt: 83,
            tokenizer: 83,
media: 0,
style: 83,
            global: 63,
            comment: "Good NPC"
        });



      try  npcSpectate.voteForPub(vote_pub) {
        fail();
      }  catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(INSUFFICIENTE_TOKENS_ERROR));
        }

                mona.mint(address(spectator1), 10);

      try  npcSpectate.voteForPub(vote_pub) {
        fail();
      }  catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(INSUFFICIENTE_TOKENS_ERROR));
        }
    }

      function testVote_withTokens() public {
        npcAccessControls.addNPC(npc1);
        vm.prank(spectator1);

        mona.mint(address(spectator1), 100);
      vm.prank(spectator1);
  NPCLibrary.NPCVote memory vote_npc = NPCLibrary.NPCVote({
            npc: npc1,
               spectator: spectator1,
            model: 50,
            scene: 40,
            chatContext: 30,
            appearance: 20,
            completedJobs: 15,
            personality: 65,
            training: 75,
            tokenizer: 80,
            lora: 10,
            spriteSheet: 50,
            global: 11,
            comment: "Good NPC"
        });

   npcSpectate.voteForNPC(vote_npc);

        assertEq(npcSpectate.getNPCVoteModel(address(spectator1), address(npc1), 0), 50);
        assertEq(npcSpectate.getNPCVoteScene(address(spectator1), address(npc1), 0) , 40);
        assertEq(npcSpectate.getNPCVoteChatContext(address(spectator1), address(npc1), 0), 30);
        assertEq(npcSpectate.getNPCVoteAppearance(address(spectator1), address(npc1), 0), 20);
        assertEq(npcSpectate.getNPCVoteCompletedJobs(address(spectator1), address(npc1), 0), 15);
        assertEq(npcSpectate.getNPCVotePersonality(address(spectator1), address(npc1), 0), 65);
        assertEq(npcSpectate.getNPCVoteTraining(address(spectator1), address(npc1), 0), 75);
        assertEq(npcSpectate.getNPCVoteTokenizer(address(spectator1), address(npc1), 0), 80);
        assertEq(npcSpectate.getNPCVoteLora(address(spectator1), address(npc1), 0), 10);
        assertEq(npcSpectate.getNPCVoteSpriteSheet(address(spectator1), address(npc1), 0), 50);
        assertEq(npcSpectate.getNPCVoteGlobal(address(spectator1), address(npc1), 0), 11);
        assertEq(npcSpectate.getNPCVoteComment(address(spectator1), address(npc1), 0), "Good NPC");

  NPCLibrary.PubVote memory vote_pub = NPCLibrary.PubVote({
            npc: npc1,
                   spectator: spectator1,
            model: 5,
            chatContext: 3,
            personality: 6,
   pubId: 100,
   profileId: 25678,
   prompt: 8,
            tokenizer: 8,
media: 0,
style: 8,
            global: 6,
            comment: "Good Pub"
        });
          vm.prank(spectator1);
npcSpectate.voteForPub(vote_pub);


        assertEq(npcSpectate.getPubVoteModel(address(spectator1), 25678, 100, 0), 5);
        assertEq(npcSpectate.getPubVotePrompt(address(spectator1), 25678, 100, 0) , 8);
        assertEq(npcSpectate.getPubVoteChatContext(address(spectator1), 25678, 100, 0), 3);
        assertEq(npcSpectate.getPubVotePersonality(address(spectator1), 25678, 100, 0), 6);
        assertEq(npcSpectate.getPubVoteTokenizer(address(spectator1), 25678, 100, 0), 8);
        assertEq(npcSpectate.getPubVoteMedia(address(spectator1), 25678, 100, 0), 0);
        assertEq(npcSpectate.getPubVoteStyle(address(spectator1), 25678, 100, 0), 8);
        assertEq(npcSpectate.getPubVoteGlobal(address(spectator1), 25678, 100, 0), 6);
        assertEq(npcSpectate.getPubVoteComment(address(spectator1), 25678, 100, 0), "Good Pub");

    }
 function testVote_noNPC() public {

        delta.mint(address(spectator1), 100);
  NPCLibrary.PubVote memory vote_pub = NPCLibrary.PubVote({
            npc: npc2,
                   spectator: spectator1,
            model: 52,
            chatContext: 32,
            personality: 62,
   pubId: 230,
   profileId: 10032,
   prompt: 83,
            tokenizer: 82,
media: 10,
style: 80,
            global: 90,
            comment: "Otro Pub"
        });
          vm.prank(spectator1);



 try  npcSpectate.voteForPub(vote_pub) {
        fail();
      }  catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(INVALID_ADDRESS_ERROR));
        }
              
        npcAccessControls.addNPC(npc2);
              vm.prank(spectator1);
        npcSpectate.voteForPub(vote_pub);
      
        assertEq(npcSpectate.getPubVoteModel(address(spectator1), 10032, 230, 0), 52);
        assertEq(npcSpectate.getPubVotePrompt(address(spectator1), 10032, 230, 0) , 83);
        assertEq(npcSpectate.getPubVoteChatContext(address(spectator1), 10032, 230, 0), 32);
        assertEq(npcSpectate.getPubVotePersonality(address(spectator1), 10032, 230, 0), 62);
        assertEq(npcSpectate.getPubVoteTokenizer(address(spectator1), 10032, 230, 0), 82);
        assertEq(npcSpectate.getPubVoteMedia(address(spectator1), 10032, 230, 0), 10);
        assertEq(npcSpectate.getPubVoteStyle(address(spectator1), 10032, 230, 0), 80);
        assertEq(npcSpectate.getPubVoteGlobal(address(spectator1), 10032, 230, 0), 90);
        assertEq(npcSpectate.getPubVoteComment(address(spectator1), 10032, 230, 0), "Otro Pub");

    }

    function testVote_withERC721() public {

        genesis.mint(address(spectator2), 1);
  NPCLibrary.PubVote memory vote_pub = NPCLibrary.PubVote({
            npc: npc2,
                   spectator: spectator2,
            model: 52,
            chatContext: 32,
            personality: 62,
   pubId: 10,
   profileId: 21050,
   prompt: 83,
            tokenizer: 82,
media: 10,
style: 80,
            global: 90,
            comment: "Otro Pub1"
        });

              
        npcAccessControls.addNPC(npc2);
              vm.prank(spectator2);
        npcSpectate.voteForPub(vote_pub);
      
        assertEq(npcSpectate.getPubVoteModel(address(spectator2), 21050, 10, 0), 52);
        assertEq(npcSpectate.getPubVotePrompt(address(spectator2), 21050, 10, 0) , 83);
        assertEq(npcSpectate.getPubVoteChatContext(address(spectator2), 21050, 10, 0), 32);
        assertEq(npcSpectate.getPubVotePersonality(address(spectator2), 21050, 10, 0), 62);
        assertEq(npcSpectate.getPubVoteTokenizer(address(spectator2), 21050, 10, 0), 82);
        assertEq(npcSpectate.getPubVoteMedia(address(spectator2), 21050, 10, 0), 10);
        assertEq(npcSpectate.getPubVoteStyle(address(spectator2), 21050, 10, 0), 80);
        assertEq(npcSpectate.getPubVoteGlobal(address(spectator2), 21050, 10, 0), 90);
        assertEq(npcSpectate.getPubVoteComment(address(spectator2), 21050, 10, 0), "Otro Pub1");

    }



function makeVotes() public {
        npcAccessControls.addNPC(npc1);
        npcAccessControls.addNPC(npc2);

        delta.mint(address(spectator1), 80);
        mona.mint(address(spectator2), 100);
        genesis.mint(address(spectator1), 1);
        fashion.mint(address(spectator2), 2);

  NPCLibrary.PubVote memory vote_pub = NPCLibrary.PubVote({
            npc: npc1,
                   spectator: spectator1,
            model: 52,
            chatContext: 32,
            personality: 62,
   pubId: 230,
   profileId: 10032,
   prompt: 83,
            tokenizer: 82,
media: 10,
style: 80,
            global: 90,
            comment: "Otro Pub"
        });


          vm.prank(spectator1);
        npcSpectate.voteForPub(vote_pub);


  NPCLibrary.PubVote memory vote_pub_2 = NPCLibrary.PubVote({
            npc: npc1,
                   spectator: spectator2,
            model: 20,
            chatContext: 99,
            personality: 62,
   pubId: 100,
   profileId: 25678,
   prompt: 80,
            tokenizer: 20,
media: 0,
style: 80,
            global: 70,
            comment: "Good Pub"
        });
          vm.prank(spectator2);
        npcSpectate.voteForPub(vote_pub_2);



  NPCLibrary.PubVote memory vote_pub_3 = NPCLibrary.PubVote({
            npc: npc2,
                   spectator: spectator1,
            model: 52,
            chatContext: 22,
            personality: 62,
   pubId: 230,
   profileId: 10032,
   prompt:20,
            tokenizer: 20,
media: 10,
style: 88,
            global: 81,
            comment: "Otro Pub"
        });


          vm.prank(spectator1);
        npcSpectate.voteForPub(vote_pub_3);

  NPCLibrary.PubVote memory vote_pub_4 = NPCLibrary.PubVote({
            npc: npc2,
                   spectator: spectator2,
            model: 70,
            chatContext: 19,
            personality: 82,
   pubId: 102,
   profileId: 25788,
   prompt: 20,
            tokenizer: 20,
media: 20,
style: 80,
            global: 50,
            comment: "Good Pub"
        });
          vm.prank(spectator2);
        npcSpectate.voteForPub(vote_pub_4);

  NPCLibrary.NPCVote memory vote_npc = NPCLibrary.NPCVote({
         npc: npc1,
         spectator: spectator1,
            model: 50,
            scene: 40,
            chatContext: 30,
            appearance: 20,
            completedJobs: 15,
            personality: 65,
            training: 75,
            tokenizer: 80,
            lora: 10,
            spriteSheet: 50,
            global: 11,
            comment: "Good NPC"
        });
          vm.prank(spectator1);
        npcSpectate.voteForNPC(vote_npc);

  NPCLibrary.NPCVote memory vote_npc_2 = NPCLibrary.NPCVote({
         npc: npc1,
         spectator: spectator2,
            model: 40,
            scene: 23,
            chatContext: 29,
            appearance: 20,
            completedJobs: 12,
            personality: 62,
            training: 49,
            tokenizer: 54,
            lora: 13,
            spriteSheet: 52,
            global: 80,
            comment: "Otro NPC"
        });
          vm.prank(spectator2);
        npcSpectate.voteForNPC(vote_npc_2);


  NPCLibrary.NPCVote memory vote_npc_3 = NPCLibrary.NPCVote({
         npc: npc2,
         spectator: spectator1,
            model: 50,
            scene: 36,
            chatContext: 36,
            appearance: 36,
            completedJobs: 15,
            personality: 65,
            training: 36,
            tokenizer: 36,
            lora: 10,
            spriteSheet: 50,
            global: 79,
            comment: "Good NPC"
        });
          vm.prank(spectator1);
        npcSpectate.voteForNPC(vote_npc_3);

  NPCLibrary.NPCVote memory vote_npc_4 = NPCLibrary.NPCVote({
         npc: npc2,
         spectator: spectator2,
            model: 40,
            scene: 33,
            chatContext: 33,
            appearance: 33,
            completedJobs: 12,
            personality: 62,
            training: 45,
            tokenizer: 23,
            lora: 13,
            spriteSheet: 52,
            global: 27,
            comment: "Otro NPC"
        });
          vm.prank(spectator2);
        npcSpectate.voteForNPC(vote_npc_4);



}

function testStatistics() public {
  makeVotes();

        address[] memory spectators = new address[](2);
        spectators[0] =    address(spectator1);
        spectators[1] = address(spectator2);

        address[] memory npcs = new address[](2);
        npcs[0] = address(npc1);
        npcs[1] = address(npc2);

    assertEq(npcSpectate.getWeeklySpectators(), spectators);
    assertEq(npcSpectate.getWeeklyNPCs(), npcs);
    assertEq(npcSpectate.getAllTotalFrequency(), 8);
    assertEq(npcSpectate.getAllWeeklyFrequency(), 8);

        assertEq(npcSpectate.getSpectatorPubWeeklyLocalFrequency(spectator1, 10032, 230), 2);
          assertEq(npcSpectate.getSpectatorPubWeeklyLocalFrequency(spectator2, 25678, 100), 1);
            assertEq(npcSpectate.getSpectatorPubWeeklyLocalFrequency(spectator2, 25788, 102), 1);

                   assertEq(npcSpectate.getSpectatorPubTotalLocalFrequency(spectator1, 10032, 230), 2);
          assertEq(npcSpectate.getSpectatorPubTotalLocalFrequency(spectator2, 25678, 100), 1);
            assertEq(npcSpectate.getSpectatorPubTotalLocalFrequency(spectator2, 25788, 102), 1);

                    assertEq(npcSpectate.getGlobalScoreNPCTallyTotal(spectator1,npc1), 101);
                                  assertEq(npcSpectate.getGlobalScoreNPCTallyWeekly(spectator1,npc1), 101);
          assertEq(npcSpectate.getGlobalScoreNPCTallyTotal(spectator2, npc1), 150);
              assertEq(npcSpectate.getGlobalScoreNPCTallyWeekly(spectator2, npc1), 150);
                 assertEq(npcSpectate.getGlobalScoreNPCTallyTotal(spectator1,npc2), 160);
                 assertEq(npcSpectate.getGlobalScoreNPCTallyWeekly(spectator1,npc2), 160);
          assertEq(npcSpectate.getGlobalScoreNPCTallyTotal(spectator2, npc2), 77);
            assertEq(npcSpectate.getGlobalScoreNPCTallyWeekly(spectator2, npc2), 77);

                  assertEq(npcSpectate.getSpectatorWeeklyFrequency(spectator1), 4);
              assertEq(npcSpectate.getSpectatorTotalFrequency(spectator1), 4);
                      assertEq(npcSpectate.getSpectatorWeeklyFrequency(spectator2), 4);
              assertEq(npcSpectate.getSpectatorTotalFrequency(spectator2), 4);

                     assertEq(npcSpectate.getNPCWeeklyFrequency(npc1), 4);
              assertEq(npcSpectate.getNPCTotalFrequency(npc1), 4);
                      assertEq(npcSpectate.getNPCWeeklyFrequency(npc2), 4);
              assertEq(npcSpectate.getNPCTotalFrequency(npc2), 4);

                             assertEq(npcSpectate.getSpectatorNPCTotalWeeklyFrequency(spectator1, npc1), 1);
              assertEq(npcSpectate.getSpectatorNPCTotalLocalFrequency(spectator1, npc1), 1);
                     assertEq(npcSpectate.getSpectatorNPCTotalWeeklyFrequency(spectator1, npc2), 1);
              assertEq(npcSpectate.getSpectatorNPCTotalLocalFrequency(spectator1, npc2), 1);
                     assertEq(npcSpectate.getSpectatorNPCTotalWeeklyFrequency(spectator2, npc1), 1);
              assertEq(npcSpectate.getSpectatorNPCTotalLocalFrequency(spectator2, npc1), 1);
                 assertEq(npcSpectate.getSpectatorNPCTotalWeeklyFrequency(spectator2, npc2), 1);
              assertEq(npcSpectate.getSpectatorNPCTotalLocalFrequency(spectator2, npc2), 1);


                  assertEq(npcSpectate.getSpectatorPubWeeklyGlobalFrequency(spectator1), 2);
              assertEq(npcSpectate.getSpectatorPubTotalGlobalFrequency(spectator1), 2);
                      assertEq(npcSpectate.getSpectatorPubWeeklyGlobalFrequency(spectator2), 2);
              assertEq(npcSpectate.getSpectatorPubTotalGlobalFrequency(spectator2), 2);

                     assertEq(npcSpectate.getSpectatorNPCWeeklyGlobalFrequency(spectator1), 2);
              assertEq(npcSpectate.getSpectatorNPCTotalGlobalFrequency(spectator1), 2);
                      assertEq(npcSpectate.getSpectatorNPCWeeklyGlobalFrequency(spectator2), 2);
              assertEq(npcSpectate.getSpectatorNPCTotalGlobalFrequency(spectator2), 2);
} 

function testWeeklyWeights_spectator() public {

  makeVotes();

npcRent.calculateWeeklySpectatorWeights();

     assertEq(npcRent.getSpectatorUnnormalizedWeightByWeek(spectator1, 0), 2000000000000000000045);
     assertEq(npcRent.getSpectatorUnnormalizedWeightByWeek(spectator2, 0), 5000000000000000000025);

     assertEq(npcRent.getSpectatorWeightByWeek(spectator1, 0), 28);
     assertEq(npcRent.getSpectatorWeightByWeek(spectator2, 0), 72);

   assertEq(npcRent.getSpectatorPortion(spectator1, 0), 2800);
     assertEq(npcRent.getSpectatorPortion(spectator2, 0), 7200);

   assertEq(npcRent.getSpectatorUnnormalizedCurrentWeekWeight(spectator1), 2000000000000000000045);
     assertEq(npcRent.getSpectatorUnnormalizedCurrentWeekWeight(spectator2), 5000000000000000000025);
     
        assertEq(npcRent.getSpectatorCurrentWeekWeight(spectator1), 28);
     assertEq(npcRent.getSpectatorCurrentWeekWeight(spectator2), 72);

}

function testWeeklyWeights_npc() public { 
  makeVotes();
npcRent.calculateWeeklySpectatorWeights();
  npcRent.calculateWeeklyNPCWeights();

  assertEq(npcRent.getNPCUnnormalizedWeightByWeekWeekly(npc1, 0), 5656);
     assertEq(npcRent.getNPCUnnormalizedWeightByWeekWeekly(npc2, 0), 11088);

      assertEq(npcRent.getNPCUnnormalizedWeightByWeekTotal(npc1, 0), 5656);
     assertEq(npcRent.getNPCUnnormalizedWeightByWeekTotal(npc2, 0), 11088);

      assertEq(npcRent.getNPCCurrentUnnormalizedWeightedScoreWeekly(npc1), 5656);
     assertEq(npcRent.getNPCCurrentUnnormalizedWeightedScoreWeekly(npc2), 11088);

      assertEq(npcRent.getNPCCurrentUnnormalizedWeightedScoreTotal(npc1), 5656);
     assertEq(npcRent.getNPCCurrentUnnormalizedWeightedScoreTotal(npc2), 11088);


         assertEq(npcRent.getNPCWeightByWeekWeekly(npc1,0), 33);
     assertEq(npcRent.getNPCWeightByWeekWeekly(npc2,0), 66);


         assertEq(npcRent.getNPCWeightByWeekTotal(npc1,0), 33);
     assertEq(npcRent.getNPCWeightByWeekTotal(npc2,0), 66);

        assertEq(npcRent.getNPCCurrentWeightedScoreWeekly(npc1), 33);
     assertEq(npcRent.getNPCCurrentWeightedScoreWeekly(npc2), 66);

      assertEq(npcRent.getNPCCurrentWeightedScoreTotal(npc1), 33);
     assertEq(npcRent.getNPCCurrentWeightedScoreTotal(npc2), 66);


      assertEq(npcRent.getNPCPortion(npc1,0), 3333);
     assertEq(npcRent.getNPCPortion(npc2,0), 6666);

}

function testClaim() public {

  npcRent.setWeeklyAUAllowance(100000000000000000000);
  
testWeeklyWeights_npc();
  assertEq(au.balanceOf(address(npc1)), 0);
        vm.warp(block.timestamp + 1 weeks + 1 days);
     vm.prank(npc1);
     npcRent.NPCPayRentAndClaim();
  assertEq(npcRent.getTotalAUPaidByWeek(0), 30330300000000000000);
    assertEq(npcRent.getTotalAUAllowanceByWeek(0), 100000000000000000000);
   assertEq(npcRent.getNPCActiveWeeks(address(npc1)), 1);
      assertEq(npcRent.getNPCActiveWeeks(address(npc2)), 0);
         assertEq(npcRent.getNPCIsInitialized(address(npc1)), true);
      assertEq(npcRent.getNPCIsInitialized(address(npc2)), false);
  assertEq(au.balanceOf(address(npc1)), 2999700000000000000);


   vm.prank(spectator1);
     npcRent.spectatorClaimAU(address(npc1), false, 0);
       assertEq(au.balanceOf(address(spectator1)), 8492484000000000000);
      assertEq(npcRent.getSpectatorHasClaimedAUByWeek(address(spectator1),address(npc1), 0), true);
      assertEq(npcRent.getSpectatorHasClaimedAUByWeek(address(spectator1),address(npc2), 0), false);
      assertEq(npcRent.getSpectatorClaimedAUByWeek(address(spectator1), 0), 8492484000000000000);
 assertEq(npcRent.getSpectatorClaimedAUByWeek(address(spectator2), 0), 0);




        vm.prank(spectator1);
   try   npcRent.spectatorClaimAU(address(npc1), false, 1) {
            fail();
        } catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(NO_AU_TO_CLAIM_ERROR));
        }

             vm.prank(spectator1);
   try     npcRent.spectatorClaimAU(address(npc2), false, 0) {
            fail();
        } catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(NO_AU_TO_CLAIM_ERROR));
        }

             vm.prank(spectator2);
     npcRent.spectatorClaimAU(address(npc1), false, 0);
       assertEq(au.balanceOf(address(spectator2)), 21837816000000000000);
      assertEq(npcRent.getSpectatorHasClaimedAUByWeek(address(spectator2),address(npc1), 0), true);
      assertEq(npcRent.getSpectatorHasClaimedAUByWeek(address(spectator2),address(npc2), 0), false);
      assertEq(npcRent.getSpectatorClaimedAUByWeek(address(spectator2), 0), 21837816000000000000);
      assertEq(npcRent.getSpectatorClaimedAUByWeek(address(spectator1), 0), 8492484000000000000);

}


function testDistributeAU() public {
 npcRent.setWeeklyAUAllowance(100000000000000000000);
  
testWeeklyWeights_npc();
        vm.warp(block.timestamp + 1 weeks + 1 days);
     vm.prank(npc1);
     npcRent.NPCPayRentAndClaim();
     vm.prank(npc2);
     npcRent.NPCPayRentAndClaim();

   vm.prank(spectator1);
     npcRent.spectatorClaimAU(address(npc1), true, 0);

        address[] memory spectators = new address[](2);
        spectators[0] =    address(spectator1);
        spectators[1] = address(spectator2);
        vm.prank(admin);

uint256 amount = au.balanceOf(address(npcRent));
npcRent.transferAUOut(admin, amount);
      assertEq(au.balanceOf(address(npcRent)), 0);
      assertEq(au.balanceOf(admin), 65513448000000000000);
}

}
