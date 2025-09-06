// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVault {
    function claimToken(IERC20 token, uint256 amount) external;
    function topUp(IERC20 token, uint256 amount) external;
}
