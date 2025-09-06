// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

contract QuestStoragecreateQuest {
    function test_WhenCallerLacksMANAGER_ROLE() external {
        // it should revert with AccessControl error.
    }

    function test_WhenQuestIdIsEmpty() external {
        // it should revert with UnacceptableId.
    }

    function test_WhenRewardIsZero() external {
        // it should revert with UnacceptableReward.
    }

    function test_WhenTokenAddressIsZero() external {
        // it should revert with UnacceptableAddress.
    }

    function test_WhenExpiryIsInThePast() external {
        // it should revert with UnacceptableExpiry.
    }

    function test_WhenExpiryEqualsBlockTimestamp() external {
        // it should revert with UnacceptableExpiry.
    }

    modifier whenAllParametersAreValid() {
        _;
    }

    function test_WhenAllParametersAreValid() external whenAllParametersAreValid {
        // it should store quest in mapping.
        // it should emit QuestCreated event.
    }

    function test_WhenQuestIdAlreadyExists() external whenAllParametersAreValid {
        // it should overwrite existing quest.
    }

    function test_WhenCreatingMultipleQuests() external {
        // it should handle each quest independently.
    }
}
