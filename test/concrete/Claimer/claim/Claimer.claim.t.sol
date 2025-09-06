// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {ClaimerTest} from "test/ClaimerTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Claimerclaim is ClaimerTest {
    // Import events from Claimer
    event Claimed(address indexed user, address indexed token, uint256 amount, uint256 timestamp);
    
    function setUp() external {
        fixture();
    }
    function test_WhenQuestDoesNotExist() external {
        // it should revert with UnacceptableId.
        string memory nonExistentQuest = "non-existent-quest";
        bytes memory signature = _generateValidSignature(nonExistentQuest, alice);
        
        _expectUnacceptableId(nonExistentQuest);
        
        vm.prank(alice);
        claimer.claim(nonExistentQuest, signature);
    }

    function test_WhenSignatureIsInvalid() external {
        // it should revert with UnacceptableSignature.
        _createQuest();
        bytes memory invalidSignature = _generateInvalidSignature();
        
        // ECDSAInvalidSignature is thrown by OpenZeppelin's ECDSA.recover for invalid signatures
        vm.expectRevert(abi.encodeWithSignature("ECDSAInvalidSignature()"));
        
        vm.prank(alice);
        claimer.claim(QUEST_ID, invalidSignature);
    }

    function test_WhenSignatureIsFromWrongSigner() external {
        // it should revert with UnacceptableSignature.
        _createQuest();
        
        // Generate signature with wrong private key
        uint256 wrongPrivateKey = 0x987654321;
        bytes32 structHash = keccak256(abi.encode(
            claimer.CLAIM_TYPEHASH(),
            QUEST_ID,
            alice
        ));
        
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            keccak256(abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("Claimer")),
                keccak256(bytes("1")),
                block.chainid,
                address(claimer)
            )),
            structHash
        ));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongPrivateKey, digest);
        bytes memory wrongSignature = abi.encodePacked(r, s, v);
        
        _expectUnacceptableSignature(wrongSignature);
        
        vm.prank(alice);
        claimer.claim(QUEST_ID, wrongSignature);
    }

    function test_WhenVaultHasInsufficientTokens() external {
        // it should revert with ERC20 transfer error.
        _createQuest();
        
        // Create a quest with a very large reward that exceeds vault balance
        string memory largeRewardQuest = "large-reward-quest";
        uint256 largeReward = usdt.balanceOf(address(vault)) + 1000e18; // More than vault has
        
        vm.prank(deployer);
        questStorage.createQuest(largeRewardQuest, largeReward, IERC20(usdt), questExpiry, questStartsAt);
        
        bytes memory signature = _generateValidSignature(largeRewardQuest, alice);
        
        // The claim should revert because vault has insufficient token balance
        // This will fail when claimer tries to call vault.claimToken() 
        vm.expectRevert(); // OpenZeppelin v5 uses ERC20InsufficientBalance custom error
        vm.prank(alice);
        claimer.claim(largeRewardQuest, signature);
    }

    function test_WhenQuestIsExpired() external {
        // it should revert with QuestExpired.
        _createQuest();
        
        // Fast forward time to make quest expired
        vm.warp(block.timestamp + 7200); // 2 hours later
        
        bytes memory signature = _generateValidSignature(QUEST_ID, alice);
        
        // Expect revert due to quest expiry validation in claim function
        vm.expectRevert(abi.encodeWithSignature("QuestExpired(string)", QUEST_ID));
        
        vm.prank(alice);
        claimer.claim(QUEST_ID, signature);
    }

    function test_WhenQuestExpiryIsZero() external {
        // it should process claim normally.
        string memory noExpiryQuest = "no-expiry-quest";
        uint32 zeroExpiry = 0; // No end date
        
        // Create quest with zero expiry (no end date)
        vm.prank(deployer);
        questStorage.createQuest(noExpiryQuest, QUEST_REWARD, IERC20(usdt), zeroExpiry, questStartsAt);
        
        bytes memory signature = _generateValidSignature(noExpiryQuest, alice);
        uint256 initialAliceBalance = usdt.balanceOf(alice);
        uint256 initialVaultBalance = usdt.balanceOf(address(vault));
        
        vm.expectEmit(true, true, false, true);
        emit Claimed(alice, address(usdt), QUEST_REWARD, block.timestamp);
        
        vm.prank(alice);
        claimer.claim(noExpiryQuest, signature);
        
        // Verify claim succeeded with zero expiry
        assertEq(usdt.balanceOf(alice), initialAliceBalance + QUEST_REWARD);
        assertEq(usdt.balanceOf(address(vault)), initialVaultBalance - QUEST_REWARD);
    }

    modifier whenAllParametersAreValid() {
        _;
    }

    function test_WhenAllParametersAreValid() external whenAllParametersAreValid {
        // it should verify EIP712 signature correctly.
        // it should call vault claimToken.
        // it should transfer tokens to caller.
        // it should emit Claimed event.
        _createQuest();
        
        bytes memory signature = _generateValidSignature(QUEST_ID, alice);
        uint256 initialAliceBalance = usdt.balanceOf(alice);
        uint256 initialVaultBalance = usdt.balanceOf(address(vault));
        
        vm.expectEmit(true, true, false, true);
        emit Claimed(alice, address(usdt), QUEST_REWARD, block.timestamp);
        
        vm.prank(alice);
        claimer.claim(QUEST_ID, signature);
        
        // Verify balances updated correctly
        assertEq(usdt.balanceOf(alice), initialAliceBalance + QUEST_REWARD);
        assertEq(usdt.balanceOf(address(vault)), initialVaultBalance - QUEST_REWARD);
    }

    function test_WhenMultipleClaimsForSameQuest() external whenAllParametersAreValid {
        // it should process each claim independently.
        _createQuest();
        
        // First claim by alice
        bytes memory aliceSignature = _generateValidSignature(QUEST_ID, alice);
        vm.expectEmit(true, true, false, true);
        emit Claimed(alice, address(usdt), QUEST_REWARD, block.timestamp);
        vm.prank(alice);
        claimer.claim(QUEST_ID, aliceSignature);
        
        // Second claim by bob for same quest
        bytes memory bobSignature = _generateValidSignature(QUEST_ID, bob);
        vm.expectEmit(true, true, false, true);
        emit Claimed(bob, address(usdt), QUEST_REWARD, block.timestamp);
        vm.prank(bob);
        claimer.claim(QUEST_ID, bobSignature);
        
        // Verify both users received rewards
        assertEq(usdt.balanceOf(alice), QUEST_REWARD);
        assertEq(usdt.balanceOf(bob), QUEST_REWARD);
    }
}
