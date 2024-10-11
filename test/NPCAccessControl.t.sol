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

    function testSetERC20Addresses() public {
        address[] memory erc20Addresses = new address[](2);
        erc20Addresses[0] = address(0x5);
        erc20Addresses[1] = address(0x6);

        vm.prank(admin);
        accessControl.setERC20Addresses(erc20Addresses);

        address[] memory returnedAddresses = accessControl
            .getERC20TokenAddresses();
        assertEq(returnedAddresses.length, 2);
        assertEq(returnedAddresses[0], address(0x5));
        assertEq(returnedAddresses[1], address(0x6));
    }

    function testSetERC721Addresses() public {
        address[] memory erc721Addresses =  new address[](2);
        erc721Addresses[0] = address(0x7);
        erc721Addresses[1] = address(0x8);

        vm.prank(admin);
        accessControl.setERC721Addresses(erc721Addresses);

        address[] memory returnedAddresses = accessControl
            .getERC721TokenAddresses();
        assertEq(returnedAddresses.length, 2);
        assertEq(returnedAddresses[0], address(0x7));
        assertEq(returnedAddresses[1], address(0x8));
    }

    function testSetAndGetERC721TokenValue() public {
        address erc721Address = address(0x10);
        uint256 weight = 20;
        uint256 threshold = 200;

        vm.prank(admin);
        accessControl.setERC721Value(erc721Address, weight, threshold);

        assertEq(accessControl.getERC721TokenWeight(erc721Address), weight);
        assertEq(
            accessControl.getERC721TokenThreshold(erc721Address),
            threshold
        );
    }

    function testSetAndGetERC20TokenValue() public {
        address erc20Address = address(0x9);
        uint256 weight = 10;
        uint256 threshold = 100;
        uint256 decimal = 18;

        vm.prank(admin);
        accessControl.setERC20Value(erc20Address, weight, threshold, decimal);

        assertEq(accessControl.getERC20TokenWeight(erc20Address), weight);
        assertEq(accessControl.getERC20TokenThreshold(erc20Address), threshold);
        assertEq(accessControl.getERC20TokenDecimal(erc20Address), decimal);
    }
}
