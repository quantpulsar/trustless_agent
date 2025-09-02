// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {IdentityRegistry} from "../src/IdentityRegistry.sol";
import {IIdentityRegistry} from "../src/interfaces/IIdentityRegistry.sol";

contract IdentityRegistryTest is Test {
    IdentityRegistry public registry;

    address public agent1 = address(0x1);
    address public agent2 = address(0x2);
    address public agent3 = address(0x3);

    string public domain1 = "agent1.example.com";
    string public domain2 = "agent2.example.com";
    string public domain3 = "agent3.example.com";

    function setUp() public {
        registry = new IdentityRegistry();
    }

    function test_RegisterAgent() public {
        vm.prank(agent1);
        uint256 agentId = registry.newAgent(domain1, agent1);

        assertEq(agentId, 1);

        (uint256 id, string memory domain, address owner) = registry.getAgent(agentId);
        assertEq(id, 1);
        assertEq(domain, domain1);
        assertEq(owner, agent1);
    }

    function test_RegisterAgent_EmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit IIdentityRegistry.AgentRegistered(1, domain1, agent1, agent1);

        vm.prank(agent1);
        registry.newAgent(domain1, agent1);
    }

    function test_RegisterMultipleAgents() public {
        vm.prank(agent1);
        uint256 agentId1 = registry.newAgent(domain1, agent1);

        vm.prank(agent2);
        uint256 agentId2 = registry.newAgent(domain2, agent2);

        assertEq(agentId1, 1);
        assertEq(agentId2, 2);
    }

    function test_RevertWhen_EmptyDomain() public {
        vm.expectRevert("IdentityRegistry: Domain cannot be empty");
        vm.prank(agent1);
        registry.newAgent("", agent1);
    }

    function test_RevertWhen_ZeroAddress() public {
        vm.expectRevert("IdentityRegistry: Agent address cannot be zero");
        vm.prank(agent1);
        registry.newAgent(domain1, address(0));
    }

    function test_RevertWhen_AddressAlreadyRegistered() public {
        vm.prank(agent1);
        registry.newAgent(domain1, agent1);

        vm.expectRevert("IdentityRegistry: Agent address already registered");
        vm.prank(agent1);
        registry.newAgent(domain2, agent1);
    }

    function test_RevertWhen_DomainAlreadyRegistered() public {
        vm.prank(agent1);
        registry.newAgent(domain1, agent1);

        vm.expectRevert("IdentityRegistry: Domain already registered");
        vm.prank(agent2);
        registry.newAgent(domain1, agent2);
    }

    function test_RevertWhen_SenderNotAgentAddress() public {
        vm.expectRevert("IdentityRegistry: Sender must be agent address");
        vm.prank(agent2);
        registry.newAgent(domain1, agent1);
    }

    function test_updateAgentAgent_Domain() public {
        vm.prank(agent1);
        uint256 agentId = registry.newAgent(domain1, agent1);

        vm.expectEmit(true, false, false, true);
        emit IIdentityRegistry.AgentUpdated(agentId, domain2, agent1, agent1);

        vm.prank(agent1);
        bool success = registry.updateAgent(agentId, domain2, address(0));

        assertTrue(success);

        (, string memory domain, address owner) = registry.getAgent(agentId);
        assertEq(domain, domain2);
        assertEq(owner, agent1);
    }

    function test_updateAgentAgent_Address() public {
        vm.prank(agent1);
        uint256 agentId = registry.newAgent(domain1, agent1);

        vm.expectEmit(true, false, false, true);
        emit IIdentityRegistry.AgentUpdated(agentId, domain1, agent2, agent1);

        vm.prank(agent1);
        bool success = registry.updateAgent(agentId, "", agent2);

        assertTrue(success);

        (, string memory domain, address owner) = registry.getAgent(agentId);
        assertEq(domain, domain1);
        assertEq(owner, agent2);
    }

    function test_updateAgentAgent_Both() public {
        vm.prank(agent1);
        uint256 agentId = registry.newAgent(domain1, agent1);

        vm.prank(agent1);
        bool success = registry.updateAgent(agentId, domain2, agent2);

        assertTrue(success);

        (, string memory domain, address owner) = registry.getAgent(agentId);
        assertEq(domain, domain2);
        assertEq(owner, agent2);
    }

    function test_RevertWhen_updateAgentNonexistentAgent() public {
        vm.expectRevert("IdentityRegistry: Agent does not exist");
        vm.prank(agent1);
        registry.updateAgent(999, domain2, agent2);
    }

    function test_RevertWhen_updateAgentNotAuthorized() public {
        vm.prank(agent1);
        uint256 agentId = registry.newAgent(domain1, agent1);

        vm.expectRevert("IdentityRegistry: Not authorized");
        vm.prank(agent2);
        registry.updateAgent(agentId, domain2, agent2);
    }

    function test_RevertWhen_updateAgentWithTakenDomain() public {
        vm.prank(agent1);
        registry.newAgent(domain1, agent1);

        vm.prank(agent2);
        uint256 agentId2 = registry.newAgent(domain2, agent2);

        vm.expectRevert("IdentityRegistry: newAgent domain is already taken");
        vm.prank(agent2);
        registry.updateAgent(agentId2, domain1, address(0));
    }

    function test_RevertWhen_updateAgentWithTakenAddress() public {
        vm.prank(agent1);
        registry.newAgent(domain1, agent1);

        vm.prank(agent2);
        uint256 agentId2 = registry.newAgent(domain2, agent2);

        vm.expectRevert("IdentityRegistry: newAgent address is already taken");
        vm.prank(agent2);
        registry.updateAgent(agentId2, "", agent1);
    }

    function test_ResolveByDomain() public {
        vm.prank(agent1);
        uint256 expectedId = registry.newAgent(domain1, agent1);

        (uint256 id, string memory domain, address owner) = registry.resolveByDomain(domain1);

        assertEq(id, expectedId);
        assertEq(domain, domain1);
        assertEq(owner, agent1);
    }

    function test_ResolveByAddress() public {
        vm.prank(agent1);
        uint256 expectedId = registry.newAgent(domain1, agent1);

        (uint256 id, string memory domain, address owner) = registry.resolveByAddress(agent1);

        assertEq(id, expectedId);
        assertEq(domain, domain1);
        assertEq(owner, agent1);
    }

    function test_ResolveByDomain_NonexistentReturnsZero() public {
        vm.expectRevert("IdentityRegistry: Domain not found");
        registry.resolveByDomain("nonexistent.com");
    }

    function test_ResolveByAddress_NonexistentReturnsZero() public {
        vm.expectRevert("IdentityRegistry: Address not found");
        registry.resolveByAddress(address(0x999));
    }

    function testFuzz_RegisterAgent(address agentAddr, string memory agentDomain) public {
        vm.assume(agentAddr != address(0));
        vm.assume(bytes(agentDomain).length > 0);

        vm.prank(agentAddr);
        uint256 agentId = registry.newAgent(agentDomain, agentAddr);

        assertEq(agentId, 1);

        (uint256 id, string memory domain, address owner) = registry.getAgent(agentId);
        assertEq(id, agentId);
        assertEq(domain, agentDomain);
        assertEq(owner, agentAddr);
    }
}
