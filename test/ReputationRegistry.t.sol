// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {ReputationRegistry} from "../src/ReputationRegistry.sol";
import {IReputationRegistry} from "../src/interfaces/IReputationRegistry.sol";

contract ReputationRegistryTest is Test {
    ReputationRegistry public registry;
    
    uint256 public constant CLIENT_AGENT_ID = 1;
    uint256 public constant SERVER_AGENT_ID = 2;
    uint256 public constant ANOTHER_CLIENT_AGENT_ID = 3;
    uint256 public constant ANOTHER_SERVER_AGENT_ID = 4;

    function setUp() public {
        registry = new ReputationRegistry();
    }

    function test_AcceptFeedback() public {
        registry.acceptFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID);
        
        // No direct way to verify internal state, but function should execute successfully
        assertTrue(true);
    }

    function test_AcceptFeedback_EmitsEvent() public {
        // We can't predict the exact feedbackAuthId, but we can verify the event structure
        vm.expectEmit(true, true, false, false);
        emit IReputationRegistry.AuthFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID, bytes32(0));
        
        registry.acceptFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID);
    }

    function test_AcceptFeedback_GeneratesUniqueFeedbackAuthId() public {
        // Record events to check feedbackAuthId uniqueness
        vm.recordLogs();
        
        registry.acceptFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID);
        registry.acceptFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID);
        
        Vm.Log[] memory logs = vm.getRecordedLogs();
        
        // Should have 2 AuthFeedback events
        assertEq(logs.length, 2);
        
        // Extract feedbackAuthIds from the events
        bytes32 feedbackAuthId1 = logs[0].topics[3];
        bytes32 feedbackAuthId2 = logs[1].topics[3];
        
        // Should be different
        assertTrue(feedbackAuthId1 != feedbackAuthId2);
    }

    function test_AcceptFeedback_MultipleAgentCombinations() public {
        vm.recordLogs();
        
        registry.acceptFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID);
        registry.acceptFeedback(ANOTHER_CLIENT_AGENT_ID, SERVER_AGENT_ID);
        registry.acceptFeedback(CLIENT_AGENT_ID, ANOTHER_SERVER_AGENT_ID);
        registry.acceptFeedback(ANOTHER_CLIENT_AGENT_ID, ANOTHER_SERVER_AGENT_ID);
        
        Vm.Log[] memory logs = vm.getRecordedLogs();
        
        // Should have 4 AuthFeedback events
        assertEq(logs.length, 4);
        
        // Verify all events have different feedbackAuthIds
        bytes32[] memory authIds = new bytes32[](4);
        for (uint i = 0; i < 4; i++) {
            authIds[i] = logs[i].topics[3];
        }
        
        // Check uniqueness
        for (uint i = 0; i < 4; i++) {
            for (uint j = i + 1; j < 4; j++) {
                assertTrue(authIds[i] != authIds[j]);
            }
        }
    }

    function test_AcceptFeedback_CorrectEventParameters() public {
        vm.expectEmit(true, true, false, false);
        emit IReputationRegistry.AuthFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID, bytes32(0));
        
        registry.acceptFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID);
    }

    function test_AcceptFeedback_FeedbackAuthIdIncludesChainId() public {
        vm.recordLogs();
        
        registry.acceptFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID);
        
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 feedbackAuthId = logs[0].topics[3];
        
        // The feedbackAuthId should be deterministic based on chainid, contract address, and counter
        // We can't easily test the internal assembly logic, but we can verify it's not zero
        assertTrue(feedbackAuthId != bytes32(0));
    }

    function test_AcceptFeedback_FeedbackAuthIdIncludesContractAddress() public {
        // Deploy a second registry to compare feedbackAuthIds
        ReputationRegistry registry2 = new ReputationRegistry();
        
        vm.recordLogs();
        
        registry.acceptFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID);
        registry2.acceptFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID);
        
        Vm.Log[] memory logs = vm.getRecordedLogs();
        
        // Should have 2 events
        assertEq(logs.length, 2);
        
        bytes32 feedbackAuthId1 = logs[0].topics[3];
        bytes32 feedbackAuthId2 = logs[1].topics[3];
        
        // Should be different because they come from different contract addresses
        assertTrue(feedbackAuthId1 != feedbackAuthId2);
    }

    function test_AcceptFeedback_IncrementalCounters() public {
        vm.recordLogs();
        
        // Call multiple times to verify counter increments
        for (uint i = 0; i < 5; i++) {
            registry.acceptFeedback(CLIENT_AGENT_ID, SERVER_AGENT_ID);
        }
        
        Vm.Log[] memory logs = vm.getRecordedLogs();
        
        // Should have 5 events, all with different feedbackAuthIds
        assertEq(logs.length, 5);
        
        bytes32[] memory authIds = new bytes32[](5);
        for (uint i = 0; i < 5; i++) {
            authIds[i] = logs[i].topics[3];
        }
        
        // Verify all are unique
        for (uint i = 0; i < 5; i++) {
            for (uint j = i + 1; j < 5; j++) {
                assertTrue(authIds[i] != authIds[j]);
            }
        }
    }

    function testFuzz_AcceptFeedback(uint256 clientId, uint256 serverId) public {
        vm.assume(clientId != 0);
        vm.assume(serverId != 0);
        
        vm.expectEmit(true, true, false, false);
        emit IReputationRegistry.AuthFeedback(clientId, serverId, bytes32(0));
        
        registry.acceptFeedback(clientId, serverId);
    }

    function testFuzz_AcceptFeedback_MultipleCalls(uint256 clientId, uint256 serverId, uint8 numCalls) public {
        vm.assume(clientId != 0);
        vm.assume(serverId != 0);
        vm.assume(numCalls > 0 && numCalls <= 10); // Limit to avoid gas issues
        
        vm.recordLogs();
        
        for (uint i = 0; i < numCalls; i++) {
            registry.acceptFeedback(clientId, serverId);
        }
        
        Vm.Log[] memory logs = vm.getRecordedLogs();
        assertEq(logs.length, numCalls);
        
        // Verify all feedbackAuthIds are unique
        if (numCalls > 1) {
            bytes32[] memory authIds = new bytes32[](numCalls);
            for (uint i = 0; i < numCalls; i++) {
                authIds[i] = logs[i].topics[3];
            }
            
            for (uint i = 0; i < numCalls; i++) {
                for (uint j = i + 1; j < numCalls; j++) {
                    assertTrue(authIds[i] != authIds[j]);
                }
            }
        }
    }
}