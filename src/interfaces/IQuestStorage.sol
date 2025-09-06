// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Types} from "../libs/Types.sol";

interface IQuestStorage {
    function createQuest(string memory _id, uint256 _reward, IERC20 _rewardToken, uint32 _expiry, uint32 _startsAt) external;
    function removeQuest(string memory _id) external;
    function getQuest(string memory _id) external view returns (Types.Quest memory);
}
