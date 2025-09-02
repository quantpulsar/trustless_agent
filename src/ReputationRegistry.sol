// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import {IReputationRegistry} from "./interfaces/IReputationRegistry.sol";
import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";

/**
 * @title ReputationRegistry
 * @author ERC-8004 Authors, azanux
 * @dev Concrete implementation of the ERC-8004 Reputation Registry.
 * This contract is intentionally lightweight to minimize on-chain costs.
 * It verifies that only the owner of the server agent can authorize feedback.
 */
contract ReputationRegistry is IReputationRegistry {
    uint256 private _feedbackAuthCounter;
    IIdentityRegistry public immutable identityRegistry;

    /**
     * @dev Constructor that sets the IdentityRegistry for agent validation.
     * @param _identityRegistry The address of the IdentityRegistry contract.
     */
    constructor(IIdentityRegistry _identityRegistry) {
        require(address(_identityRegistry) != address(0), "ReputationRegistry: IdentityRegistry cannot be zero");
        identityRegistry = _identityRegistry;
    }

    /// @inheritdoc IReputationRegistry
    function acceptFeedback(uint256 agentClientId, uint256 agentServerId) external {
        // Verify that msg.sender is the owner of the server agent
        address serverOwner = identityRegistry.getAgentOwner(agentServerId);
        require(msg.sender == serverOwner, "ReputationRegistry: Only server agent owner can authorize feedback");

        // Verify that the server agent has the SERVER role
        require(
            identityRegistry.hasRole(agentServerId, IIdentityRegistry.Role.SERVER),
            "ReputationRegistry: Server agent must have SERVER role"
        );

        // Verify that the client agent has the CLIENT role
        require(
            identityRegistry.hasRole(agentClientId, IIdentityRegistry.Role.CLIENT),
            "ReputationRegistry: Client agent must have CLIENT role"
        );

        _feedbackAuthCounter++;
        uint256 counter = _feedbackAuthCounter;

        // Generate feedbackAuthId using standard Solidity instead of assembly
        bytes32 feedbackAuthId =
            keccak256(abi.encodePacked(block.chainid, address(this), counter, agentClientId, agentServerId));

        emit AuthFeedback(agentClientId, agentServerId, feedbackAuthId);
    }
}
