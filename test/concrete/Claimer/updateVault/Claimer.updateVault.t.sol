// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {ClaimerTest} from "test/ClaimerTest.sol";
import {IVault} from "src/interfaces/IVault.sol";

contract ClaimerupdateVault is ClaimerTest {
    // Import events from Claimer
    event VaultUpdated(address indexed vault);
    
    function setUp() external {
        fixture();
    }
    function test_WhenCallerIsNotOwner() external {
        // it should revert with Ownable error.
        address newVault = makeAddr("newVault");
        
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        vm.prank(alice);
        claimer.updateVault(IVault(newVault));
    }

    function test_WhenVaultAddressIsZero() external {
        // it should revert with UnacceptableAddress.
        _expectUnacceptableAddress(address(0));
        
        vm.prank(deployer);
        claimer.updateVault(IVault(address(0)));
    }

    modifier whenVaultAddressIsValid() {
        _;
    }

    function test_WhenVaultAddressIsValid() external whenVaultAddressIsValid {
        // it should update vault state variable.
        // it should emit VaultUpdated event.
        address newVault = makeAddr("newVault");
        
        vm.expectEmit(true, false, false, false);
        emit VaultUpdated(newVault);
        
        vm.prank(deployer);
        claimer.updateVault(IVault(newVault));
        
        // Verify vault was updated
        assertEq(address(claimer.vault()), newVault);
    }

    function test_WhenSettingSameVaultAddress() external whenVaultAddressIsValid {
        // it should update and emit event normally.
        address currentVault = address(vault);
        
        vm.expectEmit(true, false, false, false);
        emit VaultUpdated(currentVault);
        
        vm.prank(deployer);
        claimer.updateVault(vault);
        
        // Verify vault remains the same
        assertEq(address(claimer.vault()), currentVault);
    }
}
