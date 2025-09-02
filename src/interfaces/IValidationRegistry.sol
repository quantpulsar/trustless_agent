// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

/**
 * @title IValidationRegistry
 * @author ERC-8004 Authors, azanux
 * @dev Interface for the ERC-8004 Validation Registry.
 * Provides generic hooks for requesting and recording independent task validations.
 */
interface IValidationRegistry {
    /**
     * @dev Emitted when a validation is requested for a task.
     * @param agentValidatorId The ID of the agent requested to perform the validation.
     * @param agentServerId The ID of the agent whose work is being validated.
     * @param dataHash A hash commitment to the off-chain data needed for validation.
     */
    event ValidationRequested(
        uint256 indexed agentValidatorId, uint256 indexed agentServerId, bytes32 indexed dataHash
    );

    /**
     * @dev Emitted when a validator submits a response for a validation request.
     * @param agentValidatorId The ID of the validator agent.
     * @param agentServerId The ID of the server agent.
     * @param dataHash The hash commitment of the validated data.
     * @param response The result of the validation (a value between 0 and 100).
     */
    event ValidationResponded(
        uint256 indexed agentValidatorId, uint256 indexed agentServerId, bytes32 indexed dataHash, uint8 response
    );

    /**
     * @dev Submits a request for a task to be validated.
     * Emits a ValidationRequested event and stores the request in memory for a limited time.
     * @param agentValidatorId The ID of the designated validator agent.
     * @param agentServerId The ID of the server agent that performed the task.
     * @param dataHash A commitment hash of the off-chain task input and output.
     */
    function requestValidation(uint256 agentValidatorId, uint256 agentServerId, bytes32 dataHash) external;

    /**
     * @dev Submits a response to a pending validation request.
     * The caller must be the designated validator agent's address.
     * @param dataHash The hash corresponding to the validation request.
     * @param response The validation result, an integer where 0 <= response <= 100.
     */
    function submitValidationResponse(bytes32 dataHash, uint8 response) external;
}
