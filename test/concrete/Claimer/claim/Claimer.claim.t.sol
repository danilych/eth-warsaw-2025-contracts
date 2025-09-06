// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

contract Claimerclaim {
    function test_WhenQuestDoesNotExist() external {
        // it should revert with UnacceptableId.
    }

    function test_WhenSignatureIsInvalid() external {
        // it should revert with UnacceptableSignature.
    }

    function test_WhenSignatureIsFromWrongSigner() external {
        // it should revert with UnacceptableSignature.
    }

    function test_WhenVaultHasInsufficientTokens() external {
        // it should revert with ERC20 transfer error.
    }

    function test_WhenQuestIsExpired() external {
        // it should process claim normally.
        // it should not validate expiry in claim function.
    }

    modifier whenAllParametersAreValid() {
        _;
    }

    function test_WhenAllParametersAreValid() external whenAllParametersAreValid {
        // it should verify EIP712 signature correctly.
        // it should call vault claimToken.
        // it should transfer tokens to caller.
        // it should emit Claimed event.
    }

    function test_WhenMultipleClaimsForSameQuest() external whenAllParametersAreValid {
        // it should process each claim independently.
    }
}
