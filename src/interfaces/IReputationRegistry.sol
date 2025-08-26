// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

/**
 * @title IReputationRegistry
 * @author ERC-8004 Authors, azanux
 * @dev Interface for the ERC-8004 Reputation Registry.
 * A lightweight entry point for authorizing task feedback between agents.
 */
interface IReputationRegistry {
    /**
     * @dev Emitted when a Server Agent pre-authorizes a Client Agent to provide feedback.
     * @param agentClientId The ID of the agent authorized to give feedback.
     * @param agentServerId The ID of the agent that performed the task.
     * @param feedbackAuthId A unique identifier for this feedback authorization, to be referenced in the off-chain data.
     */
    event AuthFeedback(uint256 indexed agentClientId, uint256 indexed agentServerId, bytes32 indexed feedbackAuthId);

    /**
     * @dev Pre-authorizes a Client Agent to provide feedback for a task completed by a Server Agent.
     * This function's primary role is to emit an AuthFeedback event.
     * @param agentClientId The ID of the client agent.
     * @param agentServerId The ID of the server agent.
     */
    function acceptFeedback(uint256 agentClientId, uint256 agentServerId) external;
}
