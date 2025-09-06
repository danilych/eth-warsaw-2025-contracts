// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Errors} from "./libs/Errors.sol";
import {Types} from "./libs/Types.sol";
import {IQuestStorage} from "./interfaces/IQuestStorage.sol";

/// @title QuestStorage
/// @author Danilych
/// @notice QuestStorage is a contract that stores main config for quests to make all calculations onchain.
contract QuestStorage is AccessControl, IQuestStorage {
    /// @notice Role for manager, for creating and removing quests.
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @notice Mapping of quests, where key is quest id and value is quest config.
    mapping(string id => Types.Quest) public quests;

    /// @notice Event emitted when a new quest is created.
    /// @param id Quest id. UUID.
    /// @param reward Quest reward.
    /// @param rewardToken Quest reward token.
    /// @param expiry Quest expiry.
    /// @param startsAt Quest start time.
    event QuestCreated(string id, uint256 reward, IERC20 rewardToken, uint32 expiry, uint32 startsAt);

    /// @notice Event emitted when a quest is removed.
    /// @param id Quest id. UUID.
    event QuestRemoved(string id);

    /// @notice Constructor.
    /// @param initialAdmin Initial admin address.
    constructor(address initialAdmin) {
        require(initialAdmin != address(0), Errors.UnacceptableAddress(initialAdmin));

        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
    }

    /// @notice Creates a new quest.
    /// @param _id Quest id. UUID.
    /// @param _reward Quest reward.
    /// @param _rewardToken Quest reward token.
    /// @param _expiry Quest expiry.
    /// @param _startsAt Quest start time.
    function createQuest(string memory _id, uint256 _reward, IERC20 _rewardToken, uint32 _expiry, uint32 _startsAt)
        external
        onlyRole(MANAGER_ROLE)
    {
        require(bytes(_id).length != 0, Errors.UnacceptableId(_id));
        require(_reward > 0, Errors.UnacceptableReward(_reward));
        require(address(_rewardToken) != address(0), Errors.UnacceptableAddress(address(_rewardToken)));
        if (_expiry != 0) {
            require(_expiry > block.timestamp, Errors.UnacceptableExpiry(_expiry));
        }
        if (_startsAt != 0) {
            require(_startsAt <= block.timestamp, Errors.QuestNotStarted(_id));
        }

        quests[_id] = Types.Quest({id: _id, reward: _reward, rewardToken: _rewardToken, expiry: _expiry, startsAt: _startsAt});

        emit QuestCreated(_id, _reward, _rewardToken, _expiry, _startsAt);
    }

    /// @notice Removes a quest.
    /// @param _id Quest id. UUID.
    function removeQuest(string memory _id) external onlyRole(MANAGER_ROLE) {
        delete quests[_id];

        emit QuestRemoved(_id);
    }

    /// @notice Gets a quest.
    /// @param _id Quest id. UUID.
    function getQuest(string memory _id) external view returns (Types.Quest memory) {
        return quests[_id];
    }
}
