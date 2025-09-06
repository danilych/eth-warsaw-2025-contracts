// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

contract ClaimerupdateManager {
    function test_WhenCallerIsNotOwner() external {
        // it should revert with Ownable error.
    }

    function test_WhenManagerAddressIsZero() external {
        // it should revert with UnacceptableAddress.
    }

    modifier whenManagerAddressIsValid() {
        _;
    }

    function test_WhenManagerAddressIsValid() external whenManagerAddressIsValid {
        // it should update manager state variable.
        // it should emit ManagerUpdated event.
    }

    function test_WhenSettingSameManagerAddress() external whenManagerAddressIsValid {
        // it should update and emit event normally.
    }
}
