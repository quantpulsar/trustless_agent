# Off-chain Implementation

This document provides comprehensive specifications for Agent Cards in the ERC-8004 ecosystem, covering off-chain data structures, protocol requirements, and integration patterns that extend beyond the smart contract implementation.

## Table of Contents

1. [Overview](#overview)
2. [Agent Card Standard (RFC 8615)](#agent-card-standard-rfc-8615)
3. [Agent Card Structure](#agent-card-structure)
4. [Registration Schema](#registration-schema)
5. [Trust Models](#trust-models)
6. [Reputation System & FeedbackAuthID](#reputation-system--feedbackauthid)
7. [A2A Protocol Extensions](#a2a-protocol-extensions)
8. [CAIP-10 Address Format](#caip-10-address-format)
9. [Multi-Chain Support](#multi-chain-support)
10. [Cryptographic Proofs](#cryptographic-proofs)
11. [Discovery Mechanisms](#discovery-mechanisms)
12. [Best Practices](#best-practices)
13. [Examples](#examples)

## Overview

The ERC-8004 standard defines a trustless agent ecosystem where agents must provide verifiable off-chain metadata through standardized Agent Cards. These cards serve as the bridge between on-chain identity and off-chain capabilities, enabling discovery, trust establishment, and interoperability across the decentralized agent network.

## Agent Card Standard (RFC 8615)

### Well-Known URI Requirement

Following RFC 8615 principles, every registered agent **MUST** serve an Agent Card at the standardized well-known URI:

```
https://{AgentDomain}/.well-known/agent-card.json
```

### HTTP Requirements

- **Content-Type**: `application/json`
- **HTTPS**: Required (HTTP redirects allowed)
- **CORS**: Should support cross-origin requests
- **Caching**: Recommended cache headers for performance
- **Availability**: Should maintain high availability (99.9%+ uptime)

### Example Discovery

For an agent registered with domain `security-agent.quantpulsar.ai`:

```
https://security-agent.quantpulsar.ai/.well-known/agent-card.json
```

## Agent Card Structure

### Core Schema

```json
{
  "version": "1.0",
  "agent": {
    "name": "QuantPulsar Security Agent",
    "description": "Specialized AI agent for smart contract security analysis",
    "capabilities": ["vulnerability-detection", "gas-optimization", "audit-reporting"]
  },
  "registrations": [
    {
      "agentId": 12345,
      "agentAddress": "eip155:1:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7",
      "signature": "0x...",
      "chain": {
        "chainId": 1,
        "network": "ethereum-mainnet",
        "registryContract": "0x..."
      },
      "registrationDate": "2024-08-27T10:00:00Z"
    }
  ],
  "trustModels": ["feedback", "inference-validation", "tee-attestation"],
  "endpoints": {
    "api": "https://api.security-agent.quantpulsar.ai",
    "websocket": "wss://ws.security-agent.quantpulsar.ai",
    "documentation": "https://docs.security-agent.quantpulsar.ai"
  },
  "extensions": {
    "a2a-protocol": "1.2",
    "specializations": ["solidity", "vyper", "yul"],
    "pricing": {
      "model": "usage-based",
      "currency": "ETH",
      "rateCard": "https://pricing.security-agent.quantpulsar.ai"
    }
  }
}
```

### Required Fields

- `version`: Schema version (current: "1.0")
- `registrations`: Array of blockchain registrations
- `trustModels`: Supported trust and validation mechanisms

### Optional Fields

- `agent`: Agent metadata and capabilities
- `endpoints`: Service endpoints for interaction
- `extensions`: Protocol-specific extensions

## Registration Schema

Each registration in the `registrations` array represents a blockchain where the agent is registered:

```json
{
  "agentId": 12345,
  "agentAddress": "eip155:1:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7",
  "signature": "0x1b2c3d4e5f...",
  "chain": {
    "chainId": 1,
    "network": "ethereum-mainnet",
    "registryContract": "0xRegistryAddress..."
  },
  "registrationDate": "2024-08-27T10:00:00Z",
  "metadata": {
    "roles": ["server", "client"],
    "status": "active"
  }
}
```

### Field Specifications

- **`agentId`**: Unique identifier from the blockchain registry
- **`agentAddress`**: CAIP-10 formatted address (see below)
- **`signature`**: Cryptographic proof of address ownership
- **`chain`**: Blockchain-specific information
- **`registrationDate`**: ISO 8601 timestamp of registration
- **`metadata`**: Additional registration metadata

## Trust Models

The `trustModels` array specifies which trust mechanisms the agent supports when acting as a Server Agent:

### Supported Trust Models

1. **`feedback`**: Reputation-based trust through client feedback
2. **`inference-validation`**: Crypto-economic validation through re-execution
3. **`tee-attestation`**: Trusted Execution Environment attestations
4. **`stake-bond`**: Economic bonding mechanisms
5. **`multi-party-computation`**: MPC-based verification
6. **`zero-knowledge-proof`**: ZK-proof validation

### Trust Model Specifications

```json
{
  "trustModels": [
    {
      "type": "feedback",
      "config": {
        "minRating": 4.5,
        "minInteractions": 100
      }
    },
    {
      "type": "tee-attestation",
      "config": {
        "provider": "intel-sgx",
        "attestationEndpoint": "https://attestation.example.com"
      }
    }
  ]
}
```

## Reputation Registry

The Registry provides a lightweight entry point for task feedback between agents through off-chain attestations.

To minimize on-chain costs, only essential data is stored on-chain. The registry exposes a single endpoint:

```solidity
AcceptFeedback(AgentClientID, AgentServerID) → emits AuthFeedback event
```

This emits an AuthFeedback event with parameters (AgentClientID, AgentServerID, FeedbackAuthID).

### Authorization Flow

The reputation system follows a three-step process to ensure authorized and verifiable feedback:

#### Step 1: Pre-authorization
When a Server Agent accepts a task, it automatically pre-authorizes the Client Agent to provide feedback by calling:

```solidity
acceptFeedback(agentClientId, agentServerId)
```

This emits an `AuthFeedback` event on-chain with a unique `FeedbackAuthID`, creating an immutable record of the authorization.

#### Step 2: Task Execution  
The Server Agent performs the requested work according to the agreed specifications.

#### Step 3: Feedback Publication
Once the task is completed, the Client Agent can publish detailed feedback off-chain using the `FeedbackAuthID` as the reference key. This feedback is stored in JSON format and made accessible through the Client Agent's Agent Card.

### FeedbackAuthID Generation

The `FeedbackAuthID` is generated on-chain using:

```solidity
feedbackAuthId = keccak256(chainId + contractAddress + counter)
```

However, in off-chain data structures, this ID MUST be formatted using CAIP-10 format:

```
eip155:1:{FeedbackAuthID}
```

Where `1` is the chain ID (Ethereum mainnet) and `{FeedbackAuthID}` is the hex representation of the generated hash.

### Feedback Data Structure

Each feedback-providing Client Agent's Agent Card MUST extend A2A by including a FeedbackDataURI that points to a JSON file containing a list of objects like the following:

```json
{
  "FeedbackAuthID": "eip155:1:{FeedbackAuthID}",  // Mandatory, CAIP 10 format
  "AgentSkillId": "string",         // Optional, as per A2A spec
  "TaskId": "string",               // Optional, as per A2A spec
  "contextId": "string",            // Optional, as per A2A spec
  "Rating": 95,                     // Optional, Int
  "ProofOfPayment": {},             // Optional, Object
  "Data": {}                        // Optional, Object
}
```

Multiple entries with the same FeedbackAuthID enable multidimensional feedback for a single task.

### Examples

#### Example 1: Simple Translation Service

- **Client**: Agent #789 (enterprise company)  
- **Server**: Agent #123 (specialized AI translator)
- **Task**: Translate contract from French to English

```json
{
  "FeedbackAuthID": "eip155:1:0xabc123",
  "AgentSkillId": "legal-translation",
  "TaskId": "contract-translation-001",
  "Rating": 88,
  "Data": {
    "accuracy": "good",
    "terminology": "appropriate",
    "timeDelivered": "on-time"
  }
}
```

#### Example 2: Multi-dimensional Feedback

The same FeedbackAuthID can have multiple entries to evaluate different aspects:

```json
[
  {
    "FeedbackAuthID": "eip155:1:0xdef456",
    "AgentSkillId": "data-analysis",
    "Rating": 92,
    "Data": { "dimension": "accuracy" }
  },
  {
    "FeedbackAuthID": "eip155:1:0xdef456",
    "AgentSkillId": "data-analysis", 
    "Rating": 78,
    "Data": { "dimension": "speed" }
  },
  {
    "FeedbackAuthID": "eip155:1:0xdef456",
    "AgentSkillId": "data-analysis",
    "Rating": 85,
    "Data": { "dimension": "communication" }
  }
]
```

## Validation Registry

The Validation Registry provides independent verification of agent tasks through on-chain authorization and off-chain data structures.

### Validation Requests

The Server Agent, in its Agent Card, SHOULD extend the A2A specifications by including a `ValidationRequestsURI`. This file can be hosted on centralized systems or IPFS. The JSON file should contain a dictionary `DataHash => DataURI` with an entry for each validation request. The structure of the individual DataURI file depends on the validation service requirements.

#### ValidationRequestsURI Structure

```json
{
  "0x1a2b3c4d...": "https://example.com/validation-request-1.json",
  "0x5e6f7890...": "ipfs://Qm...",
  "0x9abcdef0...": "https://server-agent.com/requests/medical-diagnosis-001.json"
}
```

#### Individual Validation Request Format

```json
{
  "AgentSkillId": "medical-diagnosis",
  "TaskId": "patient-analysis-001", 
  "contextId": "cardiology-consultation",
  "inputData": "Patient symptoms and medical history",
  "outputData": "Diagnosis and treatment recommendations",
  "validationType": "peer-review",
  "metadata": {
    "timestamp": "2024-08-28T10:00:00Z",
    "urgency": "standard",
    "specialization": "cardiology"
  }
}
```

### Validation Responses

When validation is completed, the `AgentValidatorAddress` calls `ValidationResponse(DataHash, Response)`. The Response is an integer where `0 ≤ x ≤ 100` and can be used both as binary (0, 100) or with any value between 0 and 100 for validations requiring nuanced scoring.

#### Smart Contract Validation Process

1. The smart contract checks if `DataHash` is still in the contract's memory
2. If the DataHash is not found or expired, the transaction fails
3. If successful, a `ValidationResponse` event is emitted with parameters: `(AgentValidatorID, AgentServerID, DataHash, Response)`

#### ValidationResponsesURI Structure

Symmetrically to the Validation Requests structure, the Validator Agent, in its Agent Card, COULD extend the A2A specifications by including a `ValidationResponsesURI`. This file can be hosted on centralized systems or IPFS. The JSON file should contain a dictionary `DataHash => DataURI` with an entry for each validation response.

```json
{
  "0x1a2b3c4d...": "https://validator.com/response-1.json",
  "0x5e6f7890...": "ipfs://Qm...",
  "0x9abcdef0...": "https://medical-validator.com/responses/diagnosis-review-001.json"
}
```

#### Individual Validation Response Format

```json
{
  "score": 92,
  "evidence": {
    "validatorCredentials": "Board-certified cardiologist, 15+ years experience",
    "reviewTime": "45 minutes",
    "methodology": "Comprehensive case review with literature cross-reference",
    "additionalRecommendations": "Consider stress test for complete evaluation"
  },
  "timestamp": "2024-08-28T11:30:00Z",
  "validatorSignature": "0x1b2c3d4e5f...",
  "AgentSkillId": "medical-diagnosis",
  "TaskId": "patient-analysis-001",
  "contextId": "cardiology-consultation"
}
```

### A2A Specification Compliance

Both the Validation Requests and Validation Responses JSON files MIGHT include `AgentSkillId`, `TaskId`, or `contextId` references, following A2A specifications naming conventions for consistency across the agent ecosystem.

### Hosting and Accessibility

- **Decentralized Storage**: Files can be hosted on IPFS for decentralized access
- **Centralized Systems**: Traditional web hosting is supported for performance and availability
- **Hybrid Approaches**: Agents may use multiple storage methods for redundancy

### Protocol Incentives

Incentives and slashing mechanisms related to validation and verification are managed by the specific protocol implementation. The ERC-8004 standard provides the infrastructure for validation authorization and response recording, while economic models are left to individual protocol designs.

## A2A Protocol Extensions

Following the Agent-to-Agent (A2A) Protocol specification, Agent Cards can include protocol-specific extensions:

### Extension Structure

```json
{
  "extensions": {
    "a2a-protocol": "1.2",
    "communication": {
      "protocols": ["https", "websocket", "libp2p"],
      "encryption": ["tls-1.3", "noise-protocol"],
      "authentication": ["jwt", "did-auth"]
    },
    "capabilities": {
      "input-formats": ["solidity", "json", "yaml"],
      "output-formats": ["json", "markdown", "pdf"],
      "languages": ["english", "spanish", "chinese"]
    },
    "sla": {
      "responseTime": "< 5 minutes",
      "availability": "99.9%",
      "concurrent-tasks": 10
    }
  }
}
```

## CAIP-10 Address Format

The `agentAddress` field follows the CAIP-10 account identifier standard:

### Format Structure

```
{namespace}:{reference}:{address}
```

### Examples

- **Ethereum Mainnet**: `eip155:1:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7`
- **Polygon**: `eip155:137:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7`
- **Arbitrum**: `eip155:42161:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7`
- **Solana**: `solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp:7S3P4HxJpyyigGzodYwHtCxZyUQe9JiBMHyRWXArAaKv`

### Namespace Specifications

- **`eip155`**: Ethereum and EVM-compatible chains
- **`solana`**: Solana blockchain
- **`cosmos`**: Cosmos ecosystem chains
- **`polkadot`**: Polkadot parachain ecosystem

## Multi-Chain Support

Agents can register on multiple blockchains while maintaining a single domain identity:

```json
{
  "registrations": [
    {
      "agentId": 12345,
      "agentAddress": "eip155:1:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7",
      "chain": { "chainId": 1, "network": "ethereum-mainnet" }
    },
    {
      "agentId": 67890,
      "agentAddress": "eip155:137:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7",
      "chain": { "chainId": 137, "network": "polygon-mainnet" }
    },
    {
      "agentId": 24680,
      "agentAddress": "eip155:42161:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7",
      "chain": { "chainId": 42161, "network": "arbitrum-one" }
    }
  ]
}
```

### Benefits

- **Cross-chain interoperability**: Single agent identity across multiple networks
- **Load distribution**: Distribute workload across different chains
- **Redundancy**: Maintain service availability if one chain experiences issues
- **Cost optimization**: Choose optimal chains for different transaction types

## Cryptographic Proofs

The `signature` field provides cryptographic proof that the agent controls the registered address:

### Signature Generation

```javascript
// Example signature generation (Ethereum)
const message = `Agent Registration Proof
Agent ID: ${agentId}
Domain: ${domain}
Address: ${address}
Timestamp: ${timestamp}`;

const signature = await web3.eth.personal.sign(message, address);
```

### Verification Process

1. **Extract** agent information from the card
2. **Reconstruct** the signed message
3. **Verify** signature against the claimed address
4. **Validate** timestamp is within acceptable range

## Discovery Mechanisms

### Primary Discovery

1. **Domain Resolution**: Query `https://{domain}/.well-known/agent-card.json`
2. **On-chain Lookup**: Use `resolveByAddress()` or `resolveByDomain()` functions
3. **Registry Indexing**: Scan blockchain events for agent registrations

### Secondary Discovery

- **Agent Directories**: Curated lists of agents
- **DHT Networks**: Distributed hash table lookups
- **Gossip Protocols**: Peer-to-peer agent discovery
- **Social Networks**: Agent recommendations and referrals

## Best Practices

### Security

- **HTTPS Only**: Never serve Agent Cards over HTTP
- **Input Validation**: Validate all Agent Card fields
- **Signature Verification**: Always verify address ownership
- **Rate Limiting**: Implement reasonable rate limits for card fetching

### Performance

- **CDN Usage**: Use Content Delivery Networks for global availability
- **Caching**: Implement appropriate cache headers
- **Compression**: Use gzip/brotli compression
- **Monitoring**: Monitor card availability and response times

### Maintenance

- **Version Control**: Track changes to Agent Card schema
- **Backward Compatibility**: Maintain compatibility with older versions
- **Update Notifications**: Notify clients of significant changes
- **Health Checks**: Regular validation of card accessibility

## Examples

### Minimal Agent Card

```json
{
  "version": "1.0",
  "registrations": [
    {
      "agentId": 1,
      "agentAddress": "eip155:1:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7",
      "signature": "0x1b2c3d4e5f..."
    }
  ],
  "trustModels": ["feedback"]
}
```

### Complete Enterprise Agent Card

```json
{
  "version": "1.0",
  "agent": {
    "name": "Enterprise Security Suite",
    "description": "Comprehensive smart contract security analysis platform",
    "vendor": "QuantPulsar Technologies",
    "version": "2.1.0",
    "capabilities": [
      "vulnerability-detection",
      "gas-optimization", 
      "formal-verification",
      "audit-reporting",
      "compliance-checking"
    ]
  },
  "registrations": [
    {
      "agentId": 12345,
      "agentAddress": "eip155:1:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7",
      "signature": "0x1b2c3d4e5f678901234567890abcdef...",
      "chain": {
        "chainId": 1,
        "network": "ethereum-mainnet",
        "registryContract": "0xRegistryAddress123..."
      },
      "registrationDate": "2024-08-27T10:00:00Z",
      "metadata": {
        "roles": ["server", "validator"],
        "status": "active",
        "tier": "enterprise"
      }
    }
  ],
  "trustModels": [
    {
      "type": "feedback",
      "config": {
        "minRating": 4.8,
        "minInteractions": 1000,
        "weightedScoring": true
      }
    },
    {
      "type": "tee-attestation", 
      "config": {
        "provider": "intel-sgx",
        "attestationEndpoint": "https://attestation.quantpulsar.ai",
        "mrenclave": "0x1234567890abcdef..."
      }
    },
    {
      "type": "stake-bond",
      "config": {
        "amount": "100 ETH",
        "slashingConditions": ["false-positive", "service-unavailable"],
        "bondContract": "0xBondContract456..."
      }
    }
  ],
  "endpoints": {
    "api": "https://api.enterprise.quantpulsar.ai",
    "websocket": "wss://ws.enterprise.quantpulsar.ai",
    "documentation": "https://docs.enterprise.quantpulsar.ai",
    "status": "https://status.enterprise.quantpulsar.ai",
    "support": "https://support.quantpulsar.ai"
  },
  "extensions": {
    "a2a-protocol": "1.2",
    "communication": {
      "protocols": ["https", "websocket", "grpc"],
      "encryption": ["tls-1.3", "noise-protocol"],
      "authentication": ["jwt", "did-auth", "mtls"],
      "rateLimit": {
        "requests": 10000,
        "period": "1h",
        "burst": 100
      }
    },
    "capabilities": {
      "input-formats": ["solidity", "vyper", "yul", "json", "yaml"],
      "output-formats": ["json", "xml", "markdown", "pdf", "sarif"],
      "languages": ["english", "spanish", "french", "chinese", "japanese"],
      "frameworks": ["hardhat", "foundry", "truffle", "brownie"],
      "blockchains": ["ethereum", "polygon", "arbitrum", "optimism"]
    },
    "sla": {
      "responseTime": "< 2 minutes",
      "availability": "99.95%",
      "concurrent-tasks": 50,
      "support": "24/7"
    },
    "pricing": {
      "model": "subscription",
      "tiers": ["basic", "professional", "enterprise"],
      "currency": ["ETH", "USDC", "USD"],
      "rateCard": "https://pricing.quantpulsar.ai/enterprise"
    },
    "compliance": {
      "certifications": ["soc2-type2", "iso27001"],
      "audits": ["trail-of-bits-2024", "consensys-diligence-2024"],
      "privacy": "gdpr-compliant"
    }
  },
  "metadata": {
    "lastUpdated": "2024-08-27T10:00:00Z",
    "maintainer": "security-team@quantpulsar.ai",
    "license": "proprietary",
    "terms": "https://quantpulsar.ai/terms",
    "privacy": "https://quantpulsar.ai/privacy"
  }
}
```

---

*This specification is part of the ERC-8004: Trustless Agents standard implementation. For smart contract documentation, see [IMPLEMENTATION_ERC8004.md](./IMPLEMENTATION_ERC8004.md).*