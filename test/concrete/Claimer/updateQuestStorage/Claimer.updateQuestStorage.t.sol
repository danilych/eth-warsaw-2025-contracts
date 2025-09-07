// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {ClaimerTest} from "test/ClaimerTest.sol";
import {IQuestStorage} from "src/interfaces/IQuestStorage.sol";

contract ClaimerupdateQuestStorage is ClaimerTest {
    // Import events from Claimer
    event QuestStorageUpdated(address indexed questStorage);

    function setUp() external {
        fixture();
    }

    function test_WhenCallerIsNotOwner() external {
        // it should revert with Ownable error.
        address newQuestStorage = makeAddr("newQuestStorage");

        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        vm.prank(alice);
        claimer.updateQuestStorage(IQuestStorage(newQuestStorage));
    }

    function test_WhenQuestStorageAddressIsZero() external {
        // it should revert with UnacceptableAddress.
        _expectUnacceptableAddress(address(0));

        vm.prank(deployer);
        claimer.updateQuestStorage(IQuestStorage(address(0)));
    }

    modifier whenQuestStorageAddressIsValid() {
        _;
    }

    function test_WhenQuestStorageAddressIsValid() external whenQuestStorageAddressIsValid {
        // it should update questStorage state variable.
        // it should emit QuestStorageUpdated event.
        address newQuestStorage = makeAddr("newQuestStorage");

        vm.expectEmit(true, false, false, false);
        emit QuestStorageUpdated(newQuestStorage);

        vm.prank(deployer);
        claimer.updateQuestStorage(IQuestStorage(newQuestStorage));

        // Verify questStorage was updated
        assertEq(address(claimer.questStorage()), newQuestStorage);
    }

    function test_WhenSettingSameQuestStorageAddress() external whenQuestStorageAddressIsValid {
        // it should update and emit event normally.
        address currentQuestStorage = address(questStorage);

        vm.expectEmit(true, false, false, false);
        emit QuestStorageUpdated(currentQuestStorage);

        vm.prank(deployer);
        claimer.updateQuestStorage(questStorage);

        // Verify questStorage remains the same
        assertEq(address(claimer.questStorage()), currentQuestStorage);
    }
}
