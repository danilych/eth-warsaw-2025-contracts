// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Test} from "./Test.sol";
import {Vault} from "src/Vault.sol";
import {USDT} from "src/samples/USDT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultTest is Test {
    Vault public vault;
    USDT public usdt;
    
    // Test amounts
    uint256 internal constant TOKEN_AMOUNT = 1000e18;
    uint256 internal constant ZERO_AMOUNT = 0;

    function fixture() public {
        vault = new Vault(deployer);
        usdt = new USDT(deployer);
        
        // Mint tokens to test users
        vm.startPrank(deployer);
        usdt.mint(alice, TOKEN_AMOUNT * 10);
        usdt.mint(bob, TOKEN_AMOUNT * 10);
        usdt.mint(carol, TOKEN_AMOUNT * 10);
        
        // Grant CLAIMER_ROLE to alice for testing
        vault.grantRole(vault.CLAIMER_ROLE(), alice);
        vm.stopPrank();
        
        // Set up allowances
        vm.prank(alice);
        usdt.approve(address(vault), type(uint256).max);
        
        vm.prank(bob);
        usdt.approve(address(vault), type(uint256).max);
        
        vm.prank(carol);
        usdt.approve(address(vault), type(uint256).max);
    }

    function _topUpVault(address user, uint256 amount) internal {
        vm.prank(user);
        vault.topUp(IERC20(usdt), amount);
    }

    function _expectUnacceptableAddress(address addr) internal {
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("UnacceptableAddress(address)")), addr));
    }

    function _expectUnacceptableAmount(uint256 amount) internal {
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("UnacceptableAmount(uint256)")), amount));
    }

    function _expectAccessControlRevert(address account, bytes32 role) internal {
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)")),
                account,
                role
            )
        );
    }
}
