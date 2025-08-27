// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

/**
 * @title IIdentityRegistry
 * @author ERC-8004 Authors, azanux
 * @dev Interface for the ERC-8004 Identity Registry.
 * Manages agent identities, providing a single on-chain entry point for registration and discovery.
 * 
 * AgentDomain Requirements:
 * Following RFC 8615 principles, an Agent Card MUST be available at https://{AgentDomain}/.well-known/agent-card.json
 */
interface IIdentityRegistry {
    /**
     * @dev Represents a registered agent.
     * @param id The unique, global identifier for the agent (AgentID).
     * @param domain The domain where the agent's AgentCard can be found (AgentDomain).
     *               Following RFC 8615 principles, Agent Card MUST be available at https://{domain}/.well-known/agent-card.json
     * @param owner The EVM-compatible address controlling the agent (AgentAddress).
     */
    struct Agent {
        uint256 id;
        string domain;
        address owner;
    }

    /**
     * @dev Emitted when a new agent is successfully registered.
     * @param agentId The new agent's unique ID.
     * @param agentDomain The agent's domain.
     * @param agentAddress The agent's controlling address.
     */
    event AgentRegistered(uint256 indexed agentId, string agentDomain, address indexed agentAddress);

    /**
     * @dev Emitted when an agent's details are updated.
     * @param agentId The ID of the agent being updated.
     * @param newAgentDomain The new domain for the agent.
     * @param newAgentAddress The new controlling address for the agent.
     */
    event AgentUpdated(uint256 indexed agentId, string newAgentDomain, address indexed newAgentAddress);

    /**
     * @dev Registers a new agent. The transaction sender MUST be the agent's address.
     * Corresponds to New(AgentDomain, AgentAddress) → AgentID in ERC-8004 spec.
     * @param agentDomain The domain name for discovering the agent's off-chain AgentCard.
     *                    Following RFC 8615 principles, Agent Card MUST be available at https://{agentDomain}/.well-known/agent-card.json
     * @param agentAddress The EVM address that will control this agent's identity.
     * @return agentId The newly assigned unique ID for the agent.
     */
    function newAgent(string calldata agentDomain, address agentAddress) external returns (uint256 agentId);

    /**
     * @dev Updates an existing agent's details. The transaction sender MUST be the current `AgentAddress`.
     * Corresponds to Update(AgentID, Optional NewAgentDomain, Optional NewAgentAddress) → Boolean in ERC-8004 spec.
     * @param agentId The ID of the agent to update.
     * @param newAgentDomain The new domain. If empty, the domain is not changed.
     *                       Following RFC 8615 principles, Agent Card MUST be available at https://{newAgentDomain}/.well-known/agent-card.json
     * @param newAgentAddress The new controlling address. If address(0), the address is not changed.
     * @return success A boolean indicating if the update was successful.
     */
    function updateAgent(
        uint256 agentId,
        string calldata newAgentDomain,
        address newAgentAddress
    ) external returns (bool success);

    /**
     * @dev Retrieves an agent's details by its ID.
     * Corresponds to Get(AgentID) → AgentID, AgentDomain, AgentAddress in ERC-8004 spec.
     * @param agentId The ID of the agent.
     * @return The agent's ID, domain, and address.
     */
    function getAgent(uint256 agentId) external view returns (uint256, string memory, address);

    /**
     * @dev Resolves an agent's details by its domain.
     * Corresponds to ResolveByDomain(AgentDomain) → AgentID, AgentDomain, AgentAddress in ERC-8004 spec.
     * @param agentDomain The domain of the agent. Agent Card is available at https://{agentDomain}/.well-known/agent-card.json
     * @return The agent's ID, domain, and address.
     */
    function resolveByDomain(string calldata agentDomain) external view returns (uint256, string memory, address);

    /**
     * @dev Resolves an agent's details by its address.
     * Corresponds to ResolveByAddress(AgentAddress) → AgentID, AgentDomain, AgentAddress in ERC-8004 spec.
     * @param agentAddress The address of the agent.
     * @return The agent's ID, domain, and address.
     */
    function resolveByAddress(address agentAddress) external view returns (uint256, string memory, address);
}
