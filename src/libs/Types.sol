// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Types {
    struct Quest {
        string id;
        uint256 reward;
        IERC20 rewardToken;
        uint32 expiry;
    }
}
