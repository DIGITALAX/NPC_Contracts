// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "./../src/NPCAccessControls.sol";

contract NPCAccessControlsTest is Test {
    NPCAccessControls public accessControl;
    address admin = address(0x1);
    address newAdmin = address(0x2);
    address npc = address(0x4);
    bytes32 constant EXISTING_ERROR = keccak256("Existing()");
    bytes32 constant ADDRESS_INVALID_ERROR = keccak256("AddressInvalid()");
    bytes32 constant CANT_REMOVE_SELF_ERROR = keccak256("CantRemoveSelf()");

    function setUp() public {
        vm.prank(admin);
        accessControl = new NPCAccessControls();
    }

    function testInitialAdmin() public view {
        assertTrue(accessControl.isAdmin(admin));
        assertEq(accessControl.symbol(), "NPCAC");
        assertEq(accessControl.name(), "NPCAccessControls");
    }

    function testAddAdmin() public {
        vm.prank(admin);
        accessControl.addAdmin(newAdmin);
        assertTrue(accessControl.isAdmin(newAdmin));
    }

    function testRemoveAdmin() public {
        vm.prank(admin);
        accessControl.addAdmin(newAdmin);
        assertTrue(accessControl.isAdmin(newAdmin));

        vm.prank(admin);
        accessControl.removeAdmin(newAdmin);
        assertFalse(accessControl.isAdmin(newAdmin));
    }

    function testAddAdminRevertsIfExisting() public {
        vm.prank(admin);
        accessControl.addAdmin(newAdmin);

        vm.prank(admin);
        try accessControl.addAdmin(newAdmin) {
            fail();
        } catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(EXISTING_ERROR));
        }
    }

    function testRemoveAdminRevertsIfNotAdmin() public {
        vm.prank(admin);
        try accessControl.removeAdmin(newAdmin) {
            fail();
        } catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(ADDRESS_INVALID_ERROR));
        }
    }

    function testRemoveAdminRevertsIfSelf() public {
        vm.prank(admin);
        try accessControl.removeAdmin(admin) {
            fail();
        } catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(CANT_REMOVE_SELF_ERROR));
        }
    }

    function testAddNPC() public {
        vm.prank(admin);
        accessControl.addNPC(npc);
        assertTrue(accessControl.isNPC(npc));
    }

    function testRemoveNPC() public {
        vm.prank(admin);
        accessControl.addNPC(npc);
        assertTrue(accessControl.isNPC(npc));

        vm.prank(admin);
        accessControl.removeNPC(npc);
        assertFalse(accessControl.isNPC(npc));
    }

    function testAddNPCRevertsIfExisting() public {
        vm.prank(admin);
        accessControl.addNPC(npc);

        vm.prank(admin);
        try accessControl.addNPC(npc) {
            fail();
        } catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(EXISTING_ERROR));
        }
    }

    function testRemoveNPCRevertsIfNotNPC() public {
        vm.prank(admin);
        try accessControl.removeNPC(npc) {
            fail();
        } catch (bytes memory lowLevelData) {
            bytes4 errorSelector = bytes4(lowLevelData);
            assertEq(errorSelector, bytes4(ADDRESS_INVALID_ERROR));
        }
    }

}
