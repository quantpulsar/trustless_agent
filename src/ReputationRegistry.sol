// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import {IReputationRegistry} from "./interfaces/IReputationRegistry.sol";

/**
 * @title ReputationRegistry
 * @author ERC-8004 Authors, azanux
 * @dev Concrete implementation of the ERC-8004 Reputation Registry.
 * This contract is intentionally lightweight to minimize on-chain costs.
 */
contract ReputationRegistry is IReputationRegistry {
    uint256 private _feedbackAuthCounter;

    /**
     * @dev This contract relies on an external IdentityRegistry to validate agent IDs.
     * It is RECOMMENDED that access control is implemented to ensure calls originate
     * from a trusted source or that agent IDs are checked against a registry.
     * For this basic implementation, we assume valid agent IDs are passed.
     */
    constructor() {}

    /// @inheritdoc IReputationRegistry
    function acceptFeedback(uint256 agentClientId, uint256 agentServerId) external {
        _feedbackAuthCounter++;
        uint256 counter = _feedbackAuthCounter;
        bytes32 feedbackAuthId;
        assembly {
            // Store data in scratch space to prepare for hashing.
            // This is more gas-efficient than abi.encodePacked.
            mstore(0x00, chainid())
            mstore(0x20, address())
            mstore(0x40, counter)
            // Hash 96 bytes (3 words) from scratch space.
            feedbackAuthId := keccak256(0x00, 0x60)
        }

        emit AuthFeedback(agentClientId, agentServerId, feedbackAuthId);
    }
}
