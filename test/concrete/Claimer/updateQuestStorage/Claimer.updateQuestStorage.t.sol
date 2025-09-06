// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

contract ClaimerupdateQuestStorage {
    function test_WhenCallerIsNotOwner() external {
        // it should revert with Ownable error.
    }

    function test_WhenQuestStorageAddressIsZero() external {
        // it should revert with UnacceptableAddress.
    }

    modifier whenQuestStorageAddressIsValid() {
        _;
    }

    function test_WhenQuestStorageAddressIsValid() external whenQuestStorageAddressIsValid {
        // it should update questStorage state variable.
        // it should emit QuestStorageUpdated event.
    }

    function test_WhenSettingSameQuestStorageAddress() external whenQuestStorageAddressIsValid {
        // it should update and emit event normally.
    }
}
