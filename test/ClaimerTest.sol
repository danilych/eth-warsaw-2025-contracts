// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Test} from "./Test.sol";
import {Claimer} from "src/Claimer.sol";
import {Vault} from "src/Vault.sol";
import {QuestStorage} from "src/QuestStorage.sol";
import {IVault} from "src/interfaces/IVault.sol";
import {IQuestStorage} from "src/interfaces/IQuestStorage.sol";
import {USDT} from "src/samples/USDT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ClaimerTest is Test {
    Claimer public claimer;
    Vault public vault;
    QuestStorage public questStorage;
    USDT public usdt;
    
    // Test data
    string internal constant QUEST_ID = "550e8400-e29b-41d4-a716-446655440000";
    uint256 internal constant QUEST_REWARD = 1000e18;
    uint32 internal questExpiry;
    uint32 internal questStartsAt;
    
    // EIP712 signature components
    uint256 internal managerPrivateKey = 0x123456789;
    address internal manager;

    function fixture() public {
        // Derive manager address from private key
        manager = vm.addr(managerPrivateKey);
        
        // Deploy contracts
        vault = new Vault(deployer);
        questStorage = new QuestStorage(deployer);
        claimer = new Claimer(deployer, manager, IVault(address(vault)), IQuestStorage(address(questStorage)));
        usdt = new USDT(deployer);
        
        // Set up roles
        vm.startPrank(deployer);
        questStorage.grantRole(questStorage.MANAGER_ROLE(), deployer);
        vault.grantRole(vault.CLAIMER_ROLE(), address(claimer));
        
        // Mint and approve tokens
        usdt.mint(deployer, QUEST_REWARD * 10);
        usdt.approve(address(vault), type(uint256).max);
        vm.stopPrank();
        
        // Set expiry to 1 hour in the future
        questExpiry = uint32(block.timestamp + 3600);
        // Set start time to current timestamp
        questStartsAt = uint32(block.timestamp);
        
        // Top up vault with tokens
        vm.prank(deployer);
        vault.topUp(IERC20(usdt), QUEST_REWARD * 5);
    }

    function _createQuest() internal returns (string memory) {
        vm.prank(deployer);
        questStorage.createQuest(QUEST_ID, QUEST_REWARD, IERC20(usdt), questExpiry, questStartsAt);
        return QUEST_ID;
    }

    function _generateValidSignature(string memory questId, address user) internal view returns (bytes memory) {
        bytes32 structHash = keccak256(abi.encode(
            claimer.CLAIM_TYPEHASH(),
            questId,
            user
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
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(managerPrivateKey, digest);
        return abi.encodePacked(r, s, v);
    }

    function _generateInvalidSignature() internal pure returns (bytes memory) {
        return abi.encodePacked(bytes32(0), bytes32(0), uint8(0));
    }

    function _expectUnacceptableId(string memory id) internal {
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("UnacceptableId(string)")), id));
    }

    function _expectUnacceptableSignature(bytes memory signature) internal {
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("UnacceptableSignature(bytes)")), signature));
    }

    function _expectUnacceptableAddress(address addr) internal {
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("UnacceptableAddress(address)")), addr));
    }

    function _expectOwnableUnauthorized(address account) internal {
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("OwnableUnauthorizedAccount(address)")), account));
    }
}
