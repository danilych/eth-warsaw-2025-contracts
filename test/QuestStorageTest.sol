// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Test} from "./Test.sol";
import {QuestStorage} from "src/QuestStorage.sol";
import {USDT} from "src/samples/USDT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract QuestStorageTest is Test {
    QuestStorage public questStorage;
    USDT public usdt;
    
    // Test data
    string internal constant QUEST_ID = "550e8400-e29b-41d4-a716-446655440000";
    string internal constant EMPTY_QUEST_ID = "";
    uint256 internal constant QUEST_REWARD = 1000e18;
    uint32 internal questExpiry;

    function fixture() public {
        vm.startPrank(deployer);
        
        questStorage = new QuestStorage(deployer);
        usdt = new USDT(deployer);
        
        // Set expiry to 1 hour in the future
        questExpiry = uint32(block.timestamp + 3600);
        
        // Grant MANAGER_ROLE to deployer for testing
        // deployer already has DEFAULT_ADMIN_ROLE from constructor
        questStorage.grantRole(questStorage.MANAGER_ROLE(), deployer);
        
        vm.stopPrank();
    }

    function _createValidQuest() internal returns (string memory) {
        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(usdt), questExpiry);
        return QUEST_ID;
    }

    function _expectUnacceptableId(string memory id) internal {
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("UnacceptableId(string)")), id));
    }

    function _expectUnacceptableReward(uint256 reward) internal {
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("UnacceptableReward(uint256)")), reward));
    }

    function _expectUnacceptableAddress(address addr) internal {
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("UnacceptableAddress(address)")), addr));
    }

    function _expectUnacceptableExpiry(uint32 expiry) internal {
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("UnacceptableExpiry(uint32)")), expiry));
    }
}
