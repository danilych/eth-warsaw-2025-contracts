// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

contract QuestStorageremoveQuest {
    function test_WhenCallerLacksMANAGER_ROLE() external {
        // it should revert with AccessControl error.
    }

    function test_WhenQuestExists() external {
        // it should delete quest from mapping.
        // it should emit QuestRemoved event.
        // it should make getQuest return empty struct.
    }

    function test_WhenQuestDoesNotExist() external {
        // it should emit QuestRemoved event without reverting.
    }
}
