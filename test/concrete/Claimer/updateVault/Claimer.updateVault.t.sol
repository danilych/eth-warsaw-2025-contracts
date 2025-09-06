// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

contract ClaimerupdateVault {
    function test_WhenCallerIsNotOwner() external {
        // it should revert with Ownable error.
    }

    function test_WhenVaultAddressIsZero() external {
        // it should revert with UnacceptableAddress.
    }

    modifier whenVaultAddressIsValid() {
        _;
    }

    function test_WhenVaultAddressIsValid() external whenVaultAddressIsValid {
        // it should update vault state variable.
        // it should emit VaultUpdated event.
    }

    function test_WhenSettingSameVaultAddress() external whenVaultAddressIsValid {
        // it should update and emit event normally.
    }
}
