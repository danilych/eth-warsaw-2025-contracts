// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {QuestStorageTest} from "test/QuestStorageTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract QuestStoragecreateQuest is QuestStorageTest {
    // Import events from QuestStorage
    event QuestCreated(string id, uint256 reward, IERC20 rewardToken, uint32 expiry, uint32 startsAt);

    function setUp() external {
        fixture();
    }

    function test_WhenCallerLacksMANAGER_ROLE() external {
        // it should revert with AccessControl error.
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)")),
                alice,
                questStorage.MANAGER_ROLE()
            )
        );

        vm.prank(alice);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(usdt), questExpiry, questStartsAt);
    }

    function test_WhenQuestIdIsEmpty() external {
        // it should revert with UnacceptableId.
        _expectUnacceptableId(EMPTY_QUEST_ID);

        vm.prank(deployer);
        questStorage.createQuest(EMPTY_QUEST_ID, QUEST_REWARD, IERC20(usdt), questExpiry, questStartsAt);
    }

    function test_WhenRewardIsZero() external {
        // it should revert with UnacceptableReward.
        _expectUnacceptableReward(0);

        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, 0, IERC20(usdt), questExpiry, questStartsAt);
    }

    function test_WhenTokenAddressIsZero() external {
        // it should revert with UnacceptableAddress.
        _expectUnacceptableAddress(address(0));

        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(address(0)), questExpiry, questStartsAt);
    }

    function test_WhenExpiryIsInThePast() external {
        // it should revert with UnacceptableExpiry.
        // Use a timestamp that's clearly in the past to avoid underflow issues
        uint32 pastExpiry = uint32(block.timestamp) > 3600 ? uint32(block.timestamp) - 3600 : 1;
        _expectUnacceptableExpiry(pastExpiry);

        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(usdt), pastExpiry, questStartsAt);
    }

    function test_WhenExpiryEqualsBlockTimestamp() external {
        // it should revert with UnacceptableExpiry.
        uint32 currentTimestamp = uint32(block.timestamp);

        _expectUnacceptableExpiry(currentTimestamp);

        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(usdt), currentTimestamp, questStartsAt);
    }

    function test_WhenExpiryIsZero() external {
        // it should create quest without expiry validation.
        uint32 zeroExpiry = 0;

        vm.expectEmit(true, true, true, true);
        emit QuestCreated(QUEST_ID, QUEST_REWARD, IERC20(usdt), zeroExpiry, questStartsAt);

        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(usdt), zeroExpiry, questStartsAt);

        // Verify quest was created with zero expiry
        (string memory storedId, uint256 storedReward, IERC20 storedToken, uint32 storedExpiry, uint32 storedStartsAt) =
            questStorage.quests(QUEST_ID);
        assertEq(storedId, QUEST_ID);
        assertEq(storedReward, QUEST_REWARD);
        assertEq(address(storedToken), address(usdt));
        assertEq(storedExpiry, zeroExpiry);
        assertEq(storedStartsAt, questStartsAt);
    }

    function test_WhenStartsAtIsInTheFuture() external {
        // it should revert with QuestNotStarted error.
        uint32 futureStartsAt = uint32(block.timestamp + 3600);

        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("QuestNotStarted(string)")), QUEST_ID));

        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(usdt), questExpiry, futureStartsAt);
    }

    function test_WhenStartsAtIsZero() external {
        // it should create quest without startsAt validation.
        uint32 zeroStartsAt = 0;

        vm.expectEmit(true, true, true, true);
        emit QuestCreated(QUEST_ID, QUEST_REWARD, IERC20(usdt), questExpiry, zeroStartsAt);

        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(usdt), questExpiry, zeroStartsAt);

        // Verify quest was created with zero startsAt
        (string memory storedId, uint256 storedReward, IERC20 storedToken, uint32 storedExpiry, uint32 storedStartsAt) =
            questStorage.quests(QUEST_ID);
        assertEq(storedId, QUEST_ID);
        assertEq(storedReward, QUEST_REWARD);
        assertEq(address(storedToken), address(usdt));
        assertEq(storedExpiry, questExpiry);
        assertEq(storedStartsAt, zeroStartsAt);
    }

    modifier whenAllParametersAreValid() {
        _;
    }

    function test_WhenAllParametersAreValid() external whenAllParametersAreValid {
        // it should store quest in mapping.
        // it should emit QuestCreated event.
        vm.expectEmit(true, true, true, true);
        emit QuestCreated(QUEST_ID, QUEST_REWARD, IERC20(usdt), questExpiry, questStartsAt);

        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(usdt), questExpiry, questStartsAt);

        // Verify quest is stored correctly
        (string memory id, uint256 reward, IERC20 token, uint32 expiry, uint32 startsAt) = questStorage.quests(QUEST_ID);
        assertEq(id, QUEST_ID);
        assertEq(reward, QUEST_REWARD);
        assertEq(address(token), address(usdt));
        assertEq(expiry, questExpiry);
        assertEq(startsAt, questStartsAt);
    }

    function test_WhenQuestIdAlreadyExists() external whenAllParametersAreValid {
        // it should overwrite existing quest.
        // Create initial quest
        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(usdt), questExpiry, questStartsAt);

        // Create new quest with same ID but different reward
        uint256 newReward = QUEST_REWARD * 2;
        vm.expectEmit(true, true, true, true);
        emit QuestCreated(QUEST_ID, newReward, IERC20(usdt), questExpiry, questStartsAt);

        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, newReward, IERC20(usdt), questExpiry, questStartsAt);

        // Verify quest was overwritten
        (, uint256 reward,,,) = questStorage.quests(QUEST_ID);
        assertEq(reward, newReward);
    }

    function test_WhenCreatingMultipleQuests() external {
        // it should handle each quest independently.
        string memory questId1 = "quest-1";
        string memory questId2 = "quest-2";
        uint256 reward1 = 1000e18;
        uint256 reward2 = 2000e18;

        vm.startPrank(deployer);

        // Create first quest
        vm.expectEmit(true, true, true, true);
        emit QuestCreated(questId1, reward1, IERC20(usdt), questExpiry, questStartsAt);
        questStorage.createQuest(questId1, reward1, IERC20(usdt), questExpiry, questStartsAt);

        // Create second quest
        vm.expectEmit(true, true, true, true);
        emit QuestCreated(questId2, reward2, IERC20(usdt), questExpiry, questStartsAt);
        questStorage.createQuest(questId2, reward2, IERC20(usdt), questExpiry, questStartsAt);

        vm.stopPrank();

        // Verify both quests exist independently
        (, uint256 storedReward1,,,) = questStorage.quests(questId1);
        (, uint256 storedReward2,,,) = questStorage.quests(questId2);
        assertEq(storedReward1, reward1);
        assertEq(storedReward2, reward2);
    }
}
