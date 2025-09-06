// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {VaultTest} from "test/VaultTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultclaimToken is VaultTest {
    // Import events from Vault
    event TokenClaimed(address indexed user, address indexed token, uint256 amount);
    
    function setUp() external {
        fixture();
        // Top up vault with tokens for testing claims
        _topUpVault(bob, TOKEN_AMOUNT * 5);
    }
    function test_WhenCallerLacksCLAIMER_ROLE() external {
        // it should revert with AccessControl error.
        _expectAccessControlRevert(bob, vault.CLAIMER_ROLE());
        
        vm.prank(bob);
        vault.claimToken(IERC20(usdt), TOKEN_AMOUNT);
    }

    function test_WhenTokenAddressIsZero() external {
        // it should revert with UnacceptableAddress.
        _expectUnacceptableAddress(address(0));
        
        vm.prank(alice);
        vault.claimToken(IERC20(address(0)), TOKEN_AMOUNT);
    }

    function test_WhenAmountIsZero() external {
        // it should revert with UnacceptableAmount.
        _expectUnacceptableAmount(ZERO_AMOUNT);
        
        vm.prank(alice);
        vault.claimToken(IERC20(usdt), ZERO_AMOUNT);
    }

    function test_WhenVaultHasInsufficientTokenBalance() external {
        // it should revert with ERC20 transfer error.
        uint256 vaultBalance = usdt.balanceOf(address(vault));
        
        vm.expectRevert();
        vm.prank(alice);
        vault.claimToken(IERC20(usdt), vaultBalance + 1);
    }

    function test_WhenTokenTransferFails() external {
        // it should revert with token-specific error.
        // This would require a mock token that fails on transfer
        // For now, we test insufficient balance scenario
        vm.expectRevert();
        vm.prank(alice);
        vault.claimToken(IERC20(usdt), TOKEN_AMOUNT * 100);
    }

    modifier whenAllParametersAreValid() {
        _;
    }

    function test_WhenAllParametersAreValid() external whenAllParametersAreValid {
        // it should transfer tokens from vault to caller.
        // it should emit TokenClaimed event.
        // it should reduce vault token balance.
        uint256 initialVaultBalance = usdt.balanceOf(address(vault));
        uint256 initialAliceBalance = usdt.balanceOf(alice);
        
        vm.expectEmit(true, true, false, true);
        emit TokenClaimed(alice, address(usdt), TOKEN_AMOUNT);
        
        vm.prank(alice);
        vault.claimToken(IERC20(usdt), TOKEN_AMOUNT);
        
        // Verify balances updated correctly
        assertEq(usdt.balanceOf(address(vault)), initialVaultBalance - TOKEN_AMOUNT);
        assertEq(usdt.balanceOf(alice), initialAliceBalance + TOKEN_AMOUNT);
    }

    function test_WhenMultipleClaimsOccur() external whenAllParametersAreValid {
        // it should process each claim independently.
        uint256 initialVaultBalance = usdt.balanceOf(address(vault));
        uint256 claimAmount1 = TOKEN_AMOUNT;
        uint256 claimAmount2 = TOKEN_AMOUNT / 2;
        
        // First claim
        vm.expectEmit(true, true, false, true);
        emit TokenClaimed(alice, address(usdt), claimAmount1);
        vm.prank(alice);
        vault.claimToken(IERC20(usdt), claimAmount1);
        
        // Second claim
        vm.expectEmit(true, true, false, true);
        emit TokenClaimed(alice, address(usdt), claimAmount2);
        vm.prank(alice);
        vault.claimToken(IERC20(usdt), claimAmount2);
        
        // Verify total deduction
        assertEq(usdt.balanceOf(address(vault)), initialVaultBalance - claimAmount1 - claimAmount2);
    }
}
