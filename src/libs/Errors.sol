// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

library Errors {
    error UnacceptableAddress(address _address);
    error UnacceptableId(string _id);
    error UnacceptableReward(uint256 _reward);
    error UnacceptableExpiry(uint32 _expiry);
}