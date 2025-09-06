// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Errors } from "./libs/Errors.sol";
import { IVault } from "./interfaces/IVault.sol";

/// @title Vault
/// @author Danilych
/// @notice Vault is a contract that stores tokens for quests rewards.
contract Vault is AccessControl, IVault {
    /// @notice Role for claimer, for claiming tokens.
    bytes32 public constant CLAIMER_ROLE = keccak256("CLAIMER_ROLE");

    /// @notice Event emitted when a token is topped up.
    /// @param user User address.
    /// @param token Token address.
    /// @param amount Amount of tokens.
    event ToppedUp(address indexed user, address indexed token, uint256 amount);
    
    /// @notice Event emitted when a token is claimed.
    /// @param user User address.
    /// @param token Token address.
    /// @param amount Amount of tokens.
    event TokenClaimed(address indexed user, address indexed token, uint256 amount);

    /// @notice Constructor.
    /// @param initialAdmin Initial admin address.
    constructor(address initialAdmin) {
        require(initialAdmin != address(0), Errors.UnacceptableAddress(initialAdmin));

        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
    }

    /// @notice Claims a token.
    /// @param token Token address.
    /// @param amount Amount of tokens.
    function claimToken(IERC20 token, uint256 amount) external onlyRole(CLAIMER_ROLE) {
        require(address(token) != address(0), Errors.UnacceptableAddress(address(token)));
        require(amount > 0, Errors.UnacceptableAmount(amount));

        token.transfer(msg.sender, amount);

        emit TokenClaimed(msg.sender, address(token), amount);
    }

    /// @notice Tops up a token.
    /// @param token Token address.
    /// @param amount Amount of tokens.
    function topUp(IERC20 token, uint256 amount) external {
        require(address(token) != address(0), Errors.UnacceptableAddress(address(token)));
        require(amount > 0, Errors.UnacceptableAmount(amount));

        token.transferFrom(msg.sender, address(this), amount);

        emit ToppedUp(msg.sender, address(token), amount);
    }
}
