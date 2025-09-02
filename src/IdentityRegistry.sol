// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";

/**
 * @title IdentityRegistry
 * @author ERC-8004 Authors, azanux
 * @dev Concrete implementation of the ERC-8004 Identity Registry with owner/agent separation.
 *
 * Architecture:
 * - AgentAddress: The EVM address identifying the agent (used for identification)
 * - Owner: The address that controls the agent (authorized to make updates)
 * - On registration, msg.sender must equal agentAddress, and becomes the owner
 * - Updates are authorized by the owner, not the agentAddress
 *
 * AgentDomain Requirements:
 * Following RFC 8615 principles, an Agent Card MUST be available at https://{AgentDomain}/.well-known/agent-card.json
 *
 * Additional Features:
 * - getAgentOwner(agentId): Get owner by agent ID
 * - getOwnerByAgentAddress(agentAddress): Get owner by agent address
 * - getOwnerByDomain(agentDomain): Get owner by agent domain
 */
contract IdentityRegistry is IIdentityRegistry {
    uint256 private _agentIdCounter;

    mapping(uint256 => Agent) private _agents;
    mapping(string => uint256) private _domainToAgentId;
    mapping(address => uint256) private _addressToAgentId;
    mapping(address => uint256) private _ownerToAgentId;

    /// @inheritdoc IIdentityRegistry
    function newAgent(string calldata agentDomain, address agentAddress) external returns (uint256 agentId) {
        require(bytes(agentDomain).length > 0, "IdentityRegistry: Domain cannot be empty");
        require(agentAddress != address(0), "IdentityRegistry: Agent address cannot be zero");
        require(_addressToAgentId[agentAddress] == 0, "IdentityRegistry: Agent address already registered");
        require(_domainToAgentId[agentDomain] == 0, "IdentityRegistry: Domain already registered");
        require(msg.sender == agentAddress, "IdentityRegistry: Sender must be agent address");

        _agentIdCounter++;
        agentId = _agentIdCounter;

        _agents[agentId] = Agent(agentId, agentDomain, agentAddress, msg.sender, 0);
        _domainToAgentId[agentDomain] = agentId;
        _addressToAgentId[agentAddress] = agentId;
        _ownerToAgentId[msg.sender] = agentId;

        emit AgentRegistered(agentId, agentDomain, agentAddress, msg.sender);
    }

    /// @inheritdoc IIdentityRegistry
    function updateAgent(uint256 agentId, string calldata newAgentDomain, address newAgentAddress)
        external
        returns (bool success)
    {
        Agent storage agent = _agents[agentId];
        require(agent.id != 0, "IdentityRegistry: Agent does not exist");
        require(msg.sender == agent.owner, "IdentityRegistry: Not authorized"); // TODO may be replace this part by hasAuthorized modifier

        // Update domain if a new one is provided
        if (bytes(newAgentDomain).length > 0) {
            require(_domainToAgentId[newAgentDomain] == 0, "IdentityRegistry: newAgent domain is already taken");
            delete _domainToAgentId[agent.domain];
            agent.domain = newAgentDomain;
            _domainToAgentId[newAgentDomain] = agentId;
        }

        // Update agent address if a new one is provided
        if (newAgentAddress != address(0)) {
            require(_addressToAgentId[newAgentAddress] == 0, "IdentityRegistry: newAgent address is already taken");
            delete _addressToAgentId[agent.agentAddress];
            agent.agentAddress = newAgentAddress;
            _addressToAgentId[newAgentAddress] = agentId;
        }

        emit AgentUpdated(agentId, agent.domain, agent.agentAddress, agent.owner);
        return true;
    }

    /// @inheritdoc IIdentityRegistry
    function getAgent(uint256 agentId) external view returns (uint256, string memory, address) {
        Agent storage agent = _agents[agentId];
        require(agent.id != 0, "IdentityRegistry: Agent does not exist");
        return (agent.id, agent.domain, agent.agentAddress);
    }

    /// @inheritdoc IIdentityRegistry
    function resolveByDomain(string calldata agentDomain) external view returns (uint256, string memory, address) {
        uint256 agentId = _domainToAgentId[agentDomain];
        require(agentId != 0, "IdentityRegistry: Domain not found");
        Agent storage agent = _agents[agentId];
        return (agent.id, agent.domain, agent.agentAddress);
    }

    /// @inheritdoc IIdentityRegistry
    function resolveByAddress(address agentAddress) external view returns (uint256, string memory, address) {
        uint256 agentId = _addressToAgentId[agentAddress];
        require(agentId != 0, "IdentityRegistry: Address not found");
        Agent storage agent = _agents[agentId];
        return (agent.id, agent.domain, agent.agentAddress);
    }

    /**
     * @dev Gets the owner address of an agent by its ID.
     * @param agentId The ID of the agent.
     * @return The owner address of the agent.
     */
    function getAgentOwner(uint256 agentId) external view returns (address) {
        Agent storage agent = _agents[agentId];
        require(agent.id != 0, "IdentityRegistry: Agent does not exist");
        return agent.owner;
    }

    /**
     * @dev Gets the owner address of an agent by its address.
     * @param agentAddress The address of the agent.
     * @return The owner address of the agent.
     */
    function getOwnerByAgentAddress(address agentAddress) external view returns (address) {
        uint256 agentId = _addressToAgentId[agentAddress];
        require(agentId != 0, "IdentityRegistry: Address not found");
        Agent storage agent = _agents[agentId];
        return agent.owner;
    }

    /**
     * @dev Gets the owner address of an agent by its domain.
     * @param agentDomain The domain of the agent.
     * @return The owner address of the agent.
     */
    function getOwnerByDomain(string calldata agentDomain) external view returns (address) {
        uint256 agentId = _domainToAgentId[agentDomain];
        require(agentId != 0, "IdentityRegistry: Domain not found");
        Agent storage agent = _agents[agentId];
        return agent.owner;
    }

    /// @inheritdoc IIdentityRegistry
    function addRole(uint256 agentId, Role role) external {
        Agent storage agent = _agents[agentId];
        require(agent.id != 0, "IdentityRegistry: Agent does not exist");
        require(msg.sender == agent.owner, "IdentityRegistry: Only owner can modify roles");

        uint8 roleBit = uint8(1 << uint8(role));
        agent.roles |= roleBit;

        emit AgentRolesUpdated(agentId, agent.roles);
    }

    /// @inheritdoc IIdentityRegistry
    function removeRole(uint256 agentId, Role role) external {
        Agent storage agent = _agents[agentId];
        require(agent.id != 0, "IdentityRegistry: Agent does not exist");
        require(msg.sender == agent.owner, "IdentityRegistry: Only owner can modify roles");

        uint8 roleBit = uint8(1 << uint8(role));
        agent.roles &= ~roleBit;

        emit AgentRolesUpdated(agentId, agent.roles);
    }

    /// @inheritdoc IIdentityRegistry
    function hasRole(uint256 agentId, Role role) external view returns (bool) {
        Agent storage agent = _agents[agentId];
        require(agent.id != 0, "IdentityRegistry: Agent does not exist");

        uint8 roleBit = uint8(1 << uint8(role));
        return (agent.roles & roleBit) != 0;
    }

    /// @inheritdoc IIdentityRegistry
    function getRoles(uint256 agentId) external view returns (uint8) {
        Agent storage agent = _agents[agentId];
        require(agent.id != 0, "IdentityRegistry: Agent does not exist");
        return agent.roles;
    }

    /// @inheritdoc IIdentityRegistry
    function setRoles(uint256 agentId, uint8 roles) external {
        Agent storage agent = _agents[agentId];
        require(agent.id != 0, "IdentityRegistry: Agent does not exist");
        require(msg.sender == agent.owner, "IdentityRegistry: Only owner can modify roles");
        require(roles <= 7, "IdentityRegistry: Invalid roles bitmap");

        agent.roles = roles;

        emit AgentRolesUpdated(agentId, roles);
    }
}
