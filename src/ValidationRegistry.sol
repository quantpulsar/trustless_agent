// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import {IValidationRegistry} from "./interfaces/IValidationRegistry.sol";
import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";

/**
 * @title ValidationRegistry
 * @author ERC-8004 Authors, azanux
 * @dev Concrete implementation of the ERC-8004 Validation Registry.
 */
contract ValidationRegistry is IValidationRegistry {
    // The duration for which a validation request remains pending (e.g., 1 hour).
    uint256 public constant PENDING_REQUEST_TTL = 3600; // TODO I am sure that 1 hour is enough

    IIdentityRegistry public immutable IDENTITY_REGISTRY;

    struct PendingValidation {
        uint256 agentValidatorId;
        uint256 agentServerId;
        uint256 expirationTimestamp;
    }

    // Mapping from data hash to the pending validation request details.
    mapping(bytes32 => PendingValidation) public pendingRequests;

    /**
     * @dev Sets the address of the IdentityRegistry for address resolution.
     * @param _identityRegistryAddress The deployed address of the IdentityRegistry.
     */
    constructor(address _identityRegistryAddress) {
        require(_identityRegistryAddress != address(0), "ValidationRegistry: Invalid registry address");
        IDENTITY_REGISTRY = IIdentityRegistry(_identityRegistryAddress);
    }

    /// @inheritdoc IValidationRegistry
    function requestValidation(uint256 agentValidatorId, uint256 agentServerId, bytes32 dataHash) external {
        // Verify that msg.sender is the owner of the server agent
        address serverOwner = IDENTITY_REGISTRY.getAgentOwner(agentServerId);
        require(msg.sender == serverOwner, "ValidationRegistry: Only server agent owner can request validation");
        
        // Verify that the server agent has the SERVER role
        require(IDENTITY_REGISTRY.hasRole(agentServerId, IIdentityRegistry.Role.SERVER), 
                "ValidationRegistry: Server agent must have SERVER role");
        
        // Verify that the validator agent has the VALIDATOR role
        require(IDENTITY_REGISTRY.hasRole(agentValidatorId, IIdentityRegistry.Role.VALIDATOR), 
                "ValidationRegistry: Validator agent must have VALIDATOR role");
        
        // Ensure the request does not already exist to prevent overwrites
        require(pendingRequests[dataHash].expirationTimestamp == 0, "ValidationRegistry: Request already exists");
        
        pendingRequests[dataHash] = PendingValidation({
            agentValidatorId: agentValidatorId,
            agentServerId: agentServerId,
            expirationTimestamp: block.timestamp + PENDING_REQUEST_TTL
        });

        emit ValidationRequested(agentValidatorId, agentServerId, dataHash);
    }

    /// @inheritdoc IValidationRegistry
    function submitValidationResponse(bytes32 dataHash, uint8 response) external {
        PendingValidation storage request = pendingRequests[dataHash];
        
        require(request.expirationTimestamp != 0, "ValidationRegistry: Request does not exist");
        require(block.timestamp <= request.expirationTimestamp, "ValidationRegistry: Request expired");
        require(response <= 100, "ValidationRegistry: Response must be between 0 and 100");

        // Resolve the validator's address from the IdentityRegistry
        (,, address validatorAddress) = IDENTITY_REGISTRY.getAgent(request.agentValidatorId);
        require(validatorAddress != address(0), "ValidationRegistry: Validator not found in registry");
        
        // Ensure the caller is the designated validator
        require(msg.sender == validatorAddress, "ValidationRegistry: Not authorized validator");
        
        // Verify that the validator agent has the VALIDATOR role
        require(IDENTITY_REGISTRY.hasRole(request.agentValidatorId, IIdentityRegistry.Role.VALIDATOR), 
                "ValidationRegistry: Validator agent must have VALIDATOR role");

        uint256 agentValidatorId = request.agentValidatorId;
        uint256 agentServerId = request.agentServerId;

        // Clean up state to prevent re-use and save gas
        delete pendingRequests[dataHash];
        
        emit ValidationResponded(agentValidatorId, agentServerId, dataHash, response);
    }
}
