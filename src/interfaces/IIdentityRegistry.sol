// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

/**
 * @title IIdentityRegistry
 * @author ERC-8004 Authors, azanux
 * @dev Interface for the ERC-8004 Identity Registry.
 * Manages agent identities, providing a single on-chain entry point for registration and discovery.
 * 
 * Owner/Agent Architecture:
 * - AgentAddress: The EVM address identifying the agent (used for identification)
 * - Owner: The address that controls the agent (authorized to make updates)
 * - On registration, msg.sender must equal agentAddress, and becomes the owner
 * - Updates are authorized by the owner, not the agentAddress
 * 
 * AgentDomain Requirements:
 * Following RFC 8615 principles, an Agent Card MUST be available at https://{AgentDomain}/.well-known/agent-card.json
 */
interface IIdentityRegistry {
    /**
     * @dev Agent roles in the ERC-8004 ecosystem.
     * Agents can have multiple roles simultaneously using bitmap.
     */
    enum Role {
        SERVER,     // = 0 → bitmap: 001 (value 1) - Offers services and executes tasks
        CLIENT,     // = 1 → bitmap: 010 (value 2) - Assigns tasks and provides feedback  
        VALIDATOR   // = 2 → bitmap: 100 (value 4) - Validates tasks through crypto-economic or cryptographic verification
    }

    /**
     * @dev Represents a registered agent.
     * @param id The unique, global identifier for the agent (AgentID).
     * @param domain The domain where the agent's AgentCard can be found (AgentDomain).
     *               Following RFC 8615 principles, Agent Card MUST be available at https://{domain}/.well-known/agent-card.json
     * @param agentAddress The EVM-compatible address identifying the agent.
     * @param owner The address that controls the agent (authorized to make updates).
     * @param roles Bitmap representing the agent's roles (SERVER=1, CLIENT=2, VALIDATOR=4).
     */
    struct Agent {
        uint256 id;
        string domain;
        address agentAddress;
        address owner;
        uint8 roles;
    }

    /**
     * @dev Emitted when a new agent is successfully registered.
     * @param agentId The new agent's unique ID.
     * @param agentDomain The agent's domain.
     * @param agentAddress The agent's address.
     * @param owner The agent's owner address.
     */
    event AgentRegistered(uint256 indexed agentId, string agentDomain, address indexed agentAddress, address indexed owner); // TODO we should add the event to the specification

    /**
     * @dev Emitted when an agent's details are updated.
     * @param agentId The ID of the agent being updated.
     * @param newAgentDomain The new domain for the agent.
     * @param newAgentAddress The new address for the agent.
     * @param newOwner The new owner address for the agent.
     */
    event AgentUpdated(uint256 indexed agentId, string newAgentDomain, address indexed newAgentAddress, address indexed newOwner); // TODO we should add the event to the specification

    /**
     * @dev Emitted when an agent's roles are updated.
     * @param agentId The ID of the agent whose roles were updated.
     * @param newRoles The new roles bitmap for the agent.
     */
    event AgentRolesUpdated(uint256 indexed agentId, uint8 newRoles);

    /**
     * @dev Registers a new agent. The transaction sender MUST be the agent address and becomes the owner.
     * Corresponds to New(AgentDomain, AgentAddress) → AgentID in ERC-8004 spec.
     * @param agentDomain The domain name for discovering the agent's off-chain AgentCard.
     *                    Following RFC 8615 principles, Agent Card MUST be available at https://{agentDomain}/.well-known/agent-card.json
     * @param agentAddress The EVM address identifying the agent (must be msg.sender, becomes owner).
     * @return agentId The newly assigned unique ID for the agent.
     */
    function newAgent(string calldata agentDomain, address agentAddress) external returns (uint256 agentId);

    /**
     * @dev Updates an existing agent's details. The transaction sender MUST be the current owner.
     * Corresponds to Update(AgentID, Optional NewAgentDomain, Optional NewAgentAddress) → Boolean in ERC-8004 spec.
     * @param agentId The ID of the agent to update.
     * @param newAgentDomain The new domain. If empty, the domain is not changed.
     *                       Following RFC 8615 principles, Agent Card MUST be available at https://{newAgentDomain}/.well-known/agent-card.json
     * @param newAgentAddress The new address. If address(0), the address is not changed.
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

    /**
     * @dev Retrieves the owner address of an agent by its ID.
     * @param agentId The ID of the agent.
     * @return The owner address of the agent.
     */
    function getAgentOwner(uint256 agentId) external view returns (address);

    /**
     * @dev Retrieves the owner address of an agent by its address.
     * @param agentAddress The address of the agent.
     * @return The owner address of the agent.
     */
    function getOwnerByAgentAddress(address agentAddress) external view returns (address);

    /**
     * @dev Retrieves the owner address of an agent by its domain.
     * @param agentDomain The domain of the agent.
     * @return The owner address of the agent.
     */
    function getOwnerByDomain(string calldata agentDomain) external view returns (address);

    /**
     * @dev Adds a role to an agent. Only the agent owner can call this function.
     * @param agentId The ID of the agent.
     * @param role The role to add.
     */
    function addRole(uint256 agentId, Role role) external;

    /**
     * @dev Removes a role from an agent. Only the agent owner can call this function.
     * @param agentId The ID of the agent.
     * @param role The role to remove.
     */
    function removeRole(uint256 agentId, Role role) external;

    /**
     * @dev Checks if an agent has a specific role.
     * @param agentId The ID of the agent.
     * @param role The role to check.
     * @return True if the agent has the role, false otherwise.
     */
    function hasRole(uint256 agentId, Role role) external view returns (bool);

    /**
     * @dev Gets all roles for an agent as a bitmap.
     * @param agentId The ID of the agent.
     * @return The roles bitmap.
     */
    function getRoles(uint256 agentId) external view returns (uint8);

    /**
     * @dev Sets multiple roles for an agent at once. Only the agent owner can call this function.
     * @param agentId The ID of the agent.
     * @param roles The roles bitmap to set.
     */
    function setRoles(uint256 agentId, uint8 roles) external;
}
