// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {VaultTest} from "test/VaultTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaulttopUp is VaultTest {
    // Import events from Vault
    event ToppedUp(address indexed user, address indexed token, uint256 amount);

    function setUp() external {
        fixture();
    }

    function test_WhenTokenAddressIsZero() external {
        // it should revert with UnacceptableAddress.
        _expectUnacceptableAddress(address(0));

        vm.prank(alice);
        vault.topUp(IERC20(address(0)), TOKEN_AMOUNT);
    }

    function test_WhenAmountIsZero() external {
        // it should revert with UnacceptableAmount.
        _expectUnacceptableAmount(ZERO_AMOUNT);

        vm.prank(alice);
        vault.topUp(IERC20(usdt), ZERO_AMOUNT);
    }

    function test_WhenCallerHasInsufficientTokenBalance() external {
        // it should revert with ERC20 transfer error.
        address poorUser = makeAddr("poorUser");
        vm.prank(poorUser);
        usdt.approve(address(vault), TOKEN_AMOUNT);

        vm.expectRevert();
        vm.prank(poorUser);
        vault.topUp(IERC20(usdt), TOKEN_AMOUNT);
    }

    function test_WhenCallerHasInsufficientAllowance() external {
        // it should revert with ERC20 allowance error.
        vm.prank(alice);
        usdt.approve(address(vault), TOKEN_AMOUNT - 1);

        vm.expectRevert();
        vm.prank(alice);
        vault.topUp(IERC20(usdt), TOKEN_AMOUNT);
    }

    function test_WhenTokenTransferFails() external {
        // it should revert with token-specific error.
        // This test would require a mock token that fails transfers
        // For now, we'll test with zero allowance which causes transfer to fail
        vm.prank(alice);
        usdt.approve(address(vault), 0);

        vm.expectRevert();
        vm.prank(alice);
        vault.topUp(IERC20(usdt), TOKEN_AMOUNT);
    }

    modifier whenAllParametersAreValid() {
        _;
    }

    function test_WhenAllParametersAreValid() external whenAllParametersAreValid {
        // it should transfer tokens from caller to vault.
        // it should emit ToppedUp event.
        // it should update vault token balance.
        uint256 initialVaultBalance = usdt.balanceOf(address(vault));
        uint256 initialAliceBalance = usdt.balanceOf(alice);

        vm.expectEmit(true, true, false, true);
        emit ToppedUp(alice, address(usdt), TOKEN_AMOUNT);

        vm.prank(alice);
        vault.topUp(IERC20(usdt), TOKEN_AMOUNT);

        // Verify balances updated correctly
        assertEq(usdt.balanceOf(address(vault)), initialVaultBalance + TOKEN_AMOUNT);
        assertEq(usdt.balanceOf(alice), initialAliceBalance - TOKEN_AMOUNT);
    }

    function test_WhenMultipleTopUpsOccur() external whenAllParametersAreValid {
        // it should accumulate tokens correctly.
        uint256 initialVaultBalance = usdt.balanceOf(address(vault));

        // First topUp from alice
        vm.expectEmit(true, true, false, true);
        emit ToppedUp(alice, address(usdt), TOKEN_AMOUNT);
        vm.prank(alice);
        vault.topUp(IERC20(usdt), TOKEN_AMOUNT);

        // Second topUp from bob
        vm.expectEmit(true, true, false, true);
        emit ToppedUp(bob, address(usdt), TOKEN_AMOUNT * 2);
        vm.prank(bob);
        vault.topUp(IERC20(usdt), TOKEN_AMOUNT * 2);

        // Verify total accumulation
        assertEq(usdt.balanceOf(address(vault)), initialVaultBalance + TOKEN_AMOUNT + TOKEN_AMOUNT * 2);
    }
}
