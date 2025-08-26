// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import "./interfaces/IIdentityRegistry.sol";

/**
 * @title IdentityRegistry
 * @author ERC-8004 Authors, azanux
 * @dev Concrete implementation of the ERC-8004 Identity Registry.
 */
contract IdentityRegistry is IIdentityRegistry {
    uint256 private _agentIdCounter;

    mapping(uint256 => Agent) private _agents;
    mapping(string => uint256) private _domainToAgentId;
    mapping(address => uint256) private _addressToAgentId;

    /// @inheritdoc IIdentityRegistry
    function New(string calldata agentDomain, address agentAddress) external returns (uint256 agentId) {
        require(bytes(agentDomain).length > 0, "IdentityRegistry: Domain cannot be empty");
        require(agentAddress != address(0), "IdentityRegistry: Address cannot be zero");
        require(_addressToAgentId[agentAddress] == 0, "IdentityRegistry: Address already registered");
        require(_domainToAgentId[agentDomain] == 0, "IdentityRegistry: Domain already registered");
        require(msg.sender == agentAddress, "IdentityRegistry: Sender must be agent address");

        _agentIdCounter++;
        agentId = _agentIdCounter;

        _agents[agentId] = Agent(agentId, agentDomain, agentAddress);
        _domainToAgentId[agentDomain] = agentId;
        _addressToAgentId[agentAddress] = agentId;

        emit AgentRegistered(agentId, agentDomain, agentAddress);
    }

    /// @inheritdoc IIdentityRegistry
    function Update(uint256 agentId, string calldata newAgentDomain, address newAgentAddress) external returns (bool success) {
        Agent storage agent = _agents[agentId];
        require(agent.id != 0, "IdentityRegistry: Agent does not exist");
        require(msg.sender == agent.owner, "IdentityRegistry: Not authorized");

        // Update domain if a new one is provided
        if (bytes(newAgentDomain).length > 0) {
            require(_domainToAgentId[newAgentDomain] == 0, "IdentityRegistry: New domain is already taken");
            delete _domainToAgentId[agent.domain];
            agent.domain = newAgentDomain;
            _domainToAgentId[newAgentDomain] = agentId;
        }

        // Update address if a new one is provided
        if (newAgentAddress != address(0)) {
            require(_addressToAgentId[newAgentAddress] == 0, "IdentityRegistry: New address is already taken");
            delete _addressToAgentId[agent.owner];
            agent.owner = newAgentAddress;
            _addressToAgentId[newAgentAddress] = agentId;
        }

        emit AgentUpdated(agentId, agent.domain, agent.owner);
        return true;
    }

    /// @inheritdoc IIdentityRegistry
    function Get(uint256 agentId) external view returns (uint256, string memory, address) {
        Agent storage agent = _agents[agentId];
        return (agent.id, agent.domain, agent.owner);
    }

    /// @inheritdoc IIdentityRegistry
    function ResolveByDomain(string calldata agentDomain) external view returns (uint256, string memory, address) {
        uint256 agentId = _domainToAgentId[agentDomain];
        Agent storage agent = _agents[agentId];
        return (agent.id, agent.domain, agent.owner);
    }

    /// @inheritdoc IIdentityRegistry
    function ResolveByAddress(address agentAddress) external view returns (uint256, string memory, address) {
        uint256 agentId = _addressToAgentId[agentAddress];
        Agent storage agent = _agents[agentId];
        return (agent.id, agent.domain, agent.owner);
    }
}
