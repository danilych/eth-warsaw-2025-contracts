// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

library Errors {
    error UnacceptableAddress(address address_);
    error UnacceptableId(string id);
    error UnacceptableReward(uint256 reward);
    error UnacceptableExpiry(uint32 expiry);
    error UnacceptableAmount(uint256 amount);
    error UnacceptableSignature(bytes signature);
}
