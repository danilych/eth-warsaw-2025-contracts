// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Errors} from "./libs/Errors.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IQuestStorage} from "./interfaces/IQuestStorage.sol";
import {IRewardProcessor} from "./interfaces/IRewardProcessor.sol";
import {Types} from "./libs/Types.sol";

/// @title Claimer
/// @author Danilych
/// @notice Claimer is a contract that handles claims for quests.
contract Claimer is Ownable, EIP712 {
    bytes32 public constant CLAIM_TYPEHASH = keccak256("Claim(string questId,address user)");

    /// @notice Manager address, who signs claims.
    address public manager;

    /// @notice Vault contract, where tokens are stored.
    IVault public vault;
    
    /// @notice QuestStorage contract, where quests are stored.
    IQuestStorage public questStorage;
    
    /// @notice RewardProcessor contract, where rewards are calculated.
    IRewardProcessor public rewardProcessor;

    /// @notice Event emitted when vault is updated.
    /// @param vault New vault address.
    event VaultUpdated(address indexed vault);

    /// @notice Event emitted when manager is updated.
    /// @param manager New manager address.
    event ManagerUpdated(address indexed manager);
    
    /// @notice Event emitted when questStorage is updated.
    /// @param questStorage New questStorage address.
    event QuestStorageUpdated(address indexed questStorage);
    
    /// @notice Event emitted when rewardProcessor is updated.
    /// @param rewardProcessor New rewardProcessor address.
    event RewardProcessorUpdated(address indexed rewardProcessor);
    
    /// @notice Event emitted when a claim is made.
    /// @param questId Quest id.
    /// @param user User address.
    /// @param token Token address.
    /// @param amount Amount of tokens.
    /// @param timestamp Timestamp of the claim.
    event Claimed(string indexed questId, address indexed user, address indexed token, uint256 amount, uint256 timestamp);

    /// @notice Constructor.
    /// @param initialOwner Initial owner address.
    /// @param manager_ Manager address.
    /// @param vault_ Vault contract.
    /// @param questStorage_ QuestStorage contract.
    /// @param rewardProcessor_ RewardProcessor contract.
    constructor(address initialOwner, address manager_, IVault vault_, IQuestStorage questStorage_, IRewardProcessor rewardProcessor_)
        Ownable(initialOwner)
        EIP712("Claimer", "1")
    {
        require(address(vault_) != address(0), Errors.UnacceptableAddress(address(vault_)));
        require(address(manager_) != address(0), Errors.UnacceptableAddress(address(manager_)));
        require(address(questStorage_) != address(0), Errors.UnacceptableAddress(address(questStorage_)));
        require(address(rewardProcessor_) != address(0), Errors.UnacceptableAddress(address(rewardProcessor_)));

        vault = vault_;
        manager = manager_;
        questStorage = questStorage_;
        rewardProcessor = rewardProcessor_;

        emit VaultUpdated(address(vault_));
        emit ManagerUpdated(manager_);
        emit QuestStorageUpdated(address(questStorage_));
        emit RewardProcessorUpdated(address(rewardProcessor_));
    }

    /// @notice Updates vault.
    /// @param vault_ New vault contract.
    function updateVault(IVault vault_) external onlyOwner {
        require(address(vault_) != address(0), Errors.UnacceptableAddress(address(vault_)));

        vault = vault_;
        emit VaultUpdated(address(vault_));
    }

    /// @notice Updates manager.
    /// @param manager_ New manager address.
    function updateManager(address manager_) external onlyOwner {
        require(address(manager_) != address(0), Errors.UnacceptableAddress(address(manager_)));

        manager = manager_;
        emit ManagerUpdated(manager_);
    }

    /// @notice Updates questStorage.
    /// @param questStorage_ New questStorage contract.
    function updateQuestStorage(IQuestStorage questStorage_) external onlyOwner {
        require(address(questStorage_) != address(0), Errors.UnacceptableAddress(address(questStorage_)));

        questStorage = questStorage_;
        emit QuestStorageUpdated(address(questStorage_));
    }

    /// @notice Updates rewardProcessor.
    /// @param rewardProcessor_ New rewardProcessor contract.
    function updateRewardProcessor(IRewardProcessor rewardProcessor_) external onlyOwner {
        require(address(rewardProcessor_) != address(0), Errors.UnacceptableAddress(address(rewardProcessor_)));

        rewardProcessor = rewardProcessor_;
        emit RewardProcessorUpdated(address(rewardProcessor_));
    }

    /// @notice Claims a token.
    /// @param questId Quest id.
    /// @param signature Signature.
    function claim(string memory questId, bytes memory signature) external {
        Types.Quest memory quest = questStorage.getQuest(questId);
        require(bytes(quest.id).length > 0, Errors.UnacceptableId(questId));
        
        if(quest.expiry != 0) {
            require(quest.expiry > block.timestamp, Errors.QuestExpired(quest.id));
        }
        
        if(quest.startsAt != 0) {
            require(quest.startsAt <= block.timestamp, Errors.QuestNotStarted(quest.id));
        }

        // Calculating rewards
        uint256 rewards = rewardProcessor.calculateReward(quest.reward, quest.startsAt, quest.expiry, false, true);

        require(verifySignature(questId, msg.sender, signature), Errors.UnacceptableSignature(signature));

        vault.claimToken(quest.rewardToken, rewards);

        IERC20(quest.rewardToken).transfer(msg.sender, rewards);

        emit Claimed(questId, msg.sender, address(quest.rewardToken), rewards, block.timestamp);
    }

    /// @notice Predicts rewards for a quest.
    /// @param questId Quest id.
    function predictRewards(string memory questId) external view returns (uint256) {
        Types.Quest memory quest = questStorage.getQuest(questId);

        uint256 rewards = rewardProcessor.calculateReward(quest.reward, quest.startsAt, quest.expiry, false, true);

        return rewards;
    }

    /// @notice Verifies signature.
    /// @param questId Quest id.
    /// @param user User address.
    /// @param signature Signature.
    function verifySignature(string memory questId, address user, bytes memory signature)
        internal
        view
        returns (bool)
    {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(CLAIM_TYPEHASH, questId, user)));
        address signer = ECDSA.recover(digest, signature);

        return signer == manager;
    }
}
