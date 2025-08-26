// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import "./interfaces/IReputationRegistry.sol";

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
    function AcceptFeedback(uint256 agentClientId, uint256 agentServerId) external {
        _feedbackAuthCounter++;
        bytes32 feedbackAuthId = keccak256(abi.encodePacked(block.chainid, address(this), _feedbackAuthCounter));
        
        emit AuthFeedback(agentClientId, agentServerId, feedbackAuthId);
    }
}
