// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {ClaimerTest} from "test/ClaimerTest.sol";

contract ClaimerupdateManager is ClaimerTest {
    // Import events from Claimer
    event ManagerUpdated(address indexed manager);

    function setUp() external {
        fixture();
    }

    function test_WhenCallerIsNotOwner() external {
        // it should revert with Ownable error.
        address newManager = makeAddr("newManager");

        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        vm.prank(alice);
        claimer.updateManager(newManager);
    }

    function test_WhenManagerAddressIsZero() external {
        // it should revert with UnacceptableAddress.
        _expectUnacceptableAddress(address(0));

        vm.prank(deployer);
        claimer.updateManager(address(0));
    }

    modifier whenManagerAddressIsValid() {
        _;
    }

    function test_WhenManagerAddressIsValid() external whenManagerAddressIsValid {
        // it should update manager state variable.
        // it should emit ManagerUpdated event.
        address newManager = makeAddr("newManager");

        vm.expectEmit(true, false, false, false);
        emit ManagerUpdated(newManager);

        vm.prank(deployer);
        claimer.updateManager(newManager);

        // Verify manager was updated
        assertEq(claimer.manager(), newManager);
    }

    function test_WhenSettingSameManagerAddress() external whenManagerAddressIsValid {
        // it should update and emit event normally.
        address currentManager = claimer.manager();

        vm.expectEmit(true, false, false, false);
        emit ManagerUpdated(currentManager);

        vm.prank(deployer);
        claimer.updateManager(currentManager);

        // Verify manager remains the same
        assertEq(claimer.manager(), currentManager);
    }
}
