// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/NPCRent.sol";
import "../src/NPCAccessControls.sol";
import "../src/AU.sol";
import "../src/NPCSpectate.sol";
import "../src/TestERC721.sol";
import "../src/TestERC20.sol";

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


      
    // function testNPCPayRentAndClaim_MissedRent() public {
    //     vm.prank(admin);
    //     npcAccessControls.addNPC(npc1);

    //     vm.prank(admin);
    //     npcRent.setWeeklyAUAllowance(1000);

    //     vm.warp(block.timestamp + 1 weeks + 4 days);

    //     assertEq(au.totalSupply(), 0);

    //     vm.prank(npc1);
    //     npcRent.NPCPayRentAndClaim();

    //     assertEq(au.totalSupply(), 1000);
    //     assertEq(au.balanceOf(npc1), 0);
    //     assertEq(au.balanceOf(address(npcRent)), 1000);

    //     vm.expectEmit(true, true, false, true);
    //     assertEq(au.balanceOf(address(npcRent)), 1000);
    // }

    // function testNPCPayRentAndClaim_CountersUpdated() public {
    //     vm.prank(admin);
    //     npcAccessControls.addNPC(npc1);

    //     vm.prank(admin);
    //     npcRent.setWeeklyAUAllowance(1000);
    //     vm.warp(block.timestamp + 1 weeks);

    //     vm.prank(npc1);
    //     npcRent.NPCPayRentAndClaim();
    //     assertEq(npcRent.getNPCLastRentClock(npc1), block.timestamp);
    //     assertEq(npcRent.getNPCAUOwed(npc1), 910);
    // }
}
