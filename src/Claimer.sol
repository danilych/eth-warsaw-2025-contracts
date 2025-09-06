// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Errors} from "./libs/Errors.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IQuestStorage} from "./interfaces/IQuestStorage.sol";
import {Types} from "./libs/Types.sol";

contract Claimer is Ownable, EIP712 {
    bytes32 public constant CLAIM_TYPEHASH = keccak256("Claim(string questId,address user)");

    address public manager;
    IVault public vault;
    IQuestStorage public questStorage;

    event VaultUpdated(address indexed vault);
    event ManagerUpdated(address indexed manager);
    event QuestStorageUpdated(address indexed questStorage);
    event Claimed(address indexed user, address indexed token, uint256 amount, uint256 timestamp);

    constructor(address initialOwner, address manager_, IVault vault_, IQuestStorage questStorage_)
        Ownable(initialOwner)
        EIP712("Claimer", "1")
    {
        require(address(vault_) != address(0), Errors.UnacceptableAddress(address(vault_)));
        require(address(manager_) != address(0), Errors.UnacceptableAddress(address(manager_)));
        require(address(questStorage_) != address(0), Errors.UnacceptableAddress(address(questStorage_)));

        vault = vault_;
        manager = manager_;
        questStorage = questStorage_;
        emit VaultUpdated(address(vault_));
        emit ManagerUpdated(manager_);
        emit QuestStorageUpdated(address(questStorage_));
    }

    function updateVault(IVault vault_) external onlyOwner {
        require(address(vault_) != address(0), Errors.UnacceptableAddress(address(vault_)));

        vault = vault_;
        emit VaultUpdated(address(vault_));
    }

    function updateManager(address manager_) external onlyOwner {
        require(address(manager_) != address(0), Errors.UnacceptableAddress(address(manager_)));

        manager = manager_;
        emit ManagerUpdated(manager_);
    }

    function updateQuestStorage(IQuestStorage questStorage_) external onlyOwner {
        require(address(questStorage_) != address(0), Errors.UnacceptableAddress(address(questStorage_)));

        questStorage = questStorage_;
        emit QuestStorageUpdated(address(questStorage_));
    }

    function claim(string memory questId, bytes memory signature) external {
        Types.Quest memory quest = questStorage.getQuest(questId);
        require(bytes(quest.id).length > 0, Errors.UnacceptableId(questId));
        
        if(quest.expiry != 0) {
            require(quest.expiry > block.timestamp, Errors.QuestExpired(quest.id));
        }

        // Calculating rewards
        uint256 rewards = quest.reward;

        require(verifySignature(questId, msg.sender, signature), Errors.UnacceptableSignature(signature));

        vault.claimToken(quest.rewardToken, rewards);

        IERC20(quest.rewardToken).transfer(msg.sender, rewards);

        emit Claimed(msg.sender, address(quest.rewardToken), rewards, block.timestamp);
    }

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
