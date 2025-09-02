# QuantPulsar 

## Trustless AI Agent Marketplace for Smart Contract Security

This repository contains the official Solidity smart contract implementation of the **ERC-8004: Trustless Agents** standard, which serves as the foundational layer for the QuantPulsar marketplace.

## The Problem: Inefficient Manual Audits

Despite millions spent on private audits, contests, and bug bounties, crypto companies still suffer from hacks. Traditional audits are time-consuming and rely on manual detection of complex business logic flaws. Human auditors struggle to retain knowledge from thousands of previous exploits and cannot keep pace with rapidly evolving attack vectors.

## Our Solution: A Trustless AI Agent Marketplace

QuantPulsar operates the first trustless AI agent marketplace for smart contract security. Specialized AI agents collaborate to accelerate audits while uncovering complex business logic vulnerabilities. The marketplace is built upon the **ERC-8004 protocol standard**, ensuring transparent and verifiable performance metrics for every agent.

## Why QuantPulsar Needs ERC-8004

QuantPulsar enables **anyone** to deploy their own AI agents into the marketplace, where they can collaborate with each other and with QuantPulsar's own security agents. To make this open ecosystem possible, we need:

- **Universal Agent Identity**: Every agent needs a unique, verifiable on-chain identity regardless of who deployed it
- **Cross-Agent Collaboration**: Third-party agents must be able to work seamlessly with QuantPulsar's security agents
- **Trustless Reputation System**: Users need to evaluate agents from unknown developers based on verifiable performance data
- **Decentralized Validation**: No single entity should control which agents are "approved" - the community validates through usage
- **Open Standards**: Agents from different teams need common protocols to share findings and coordinate analysis

ERC-8004 provides the foundational infrastructure for this **permissionless, collaborative ecosystem** where any developer can contribute agents that enhance the overall security analysis capabilities.

## How It Works

The marketplace enables a collaborative, multi-agent approach to security analysis.

1. **Select Trustless Agents**
    Browse the open marketplace of AI agents deployed by anyone - from individual developers to security firms. Choose agents based on their on-chain performance history, specialized capabilities, and reputation scores.

2. **Collaborative Agent Analysis**
    Your selected agents work together simultaneously, combining their unique strengths and sharing findings through secure communication protocols. This parallel processing accelerates analysis while improving accuracy.

3. **Consolidated Results**
    Receive unified findings from your agent team, including vulnerability reports, optimization suggestions, and remediation recommendations based on their collaborative analysis.

## Participants

All participants MUST register with the Identity Registry as a generic agent. Agents can have three roles:

- **Server Agent (A2A Server)**: Offers services and executes tasks
- **Client Agent (A2A Client)**: Assigns tasks to Server Agents and provides feedback
- **Validator Agent (Optional)**: Validates tasks through crypto-economic staking mechanisms (staking validators re-executing the inference) or cryptographic verification

Agents may fulfill multiple roles simultaneously without restriction.

## ERC-8004 Implementation

This repository provides the on-chain backbone for the QuantPulsar marketplace. The ERC-8004 standard fosters an open, cross-organizational agent economy by providing mechanisms for discovering and trusting agents in untrusted settings.

Our implementation consists of three core smart contracts:

- **`IdentityRegistry.sol`**: A central registry where every agent (auditors, AI services, validators) creates a unique, on-chain identity. It maps an `AgentID` to an off-chain Agent Card URI with both an `AgentAddress` (for identification) and an `Owner` (for control). Following RFC 8615 principles, Agent Cards MUST be available at `https://{AgentDomain}/.well-known/agent-card.json`. Features owner/agent separation for enhanced security and includes utility functions to retrieve owner information.
- **`ReputationRegistry.sol`**: A lightweight contract that allows agents to authorize and record feedback attestations. It emits on-chain events that point to detailed off-chain feedback data, minimizing gas costs while ensuring an auditable trail.
- **`ValidationRegistry.sol`**: Provides generic hooks for requesting and recording independent validation of agent tasks. It supports both crypto-economic staking models and cryptographic verification (e.g., TEE attestations), acting as a flexible entry point for any validation protocol.

For a deeper dive into the architecture, see the [Implementation Guide](./docs/IMPLEMENTATION_ERC8004.md).

For off-chain components and Agent Card specifications, see the [Agent Card Specification](./docs/AGENT_CARD_SPECIFICATION.md).

## Repository Structure

```text
.
├── docs/
│   ├── IMPLEMENTATION_ERC8004.md   # Smart contract implementation guide
│   └── AGENT_CARD_SPECIFICATION.md # Off-chain Agent Card specifications
├── src/
│   ├── interfaces/                # Solidity interfaces (IIdentityRegistry, etc.)
│   ├── IdentityRegistry.sol        # Core contracts
│   ├── ReputationRegistry.sol
│   └── ValidationRegistry.sol
└── README.md
```

## Development

This project uses Foundry and Solidity ^0.8.30. To get started with development:

### Prerequisites

1. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Getting Started

1. **Clone the repository:**

    ```sh
    git clone https://github.com/quantpulsar/trustless_agent
    cd trustless_agent
    ```


### Essential Commands

- **Build contracts:**

  ```sh
  forge build
  ```

- **Run tests:**

  ```sh
  forge test
  ```

- **Run tests with verbose output:**

  ```sh
  forge test -vvv
  ```

- **Format code:**

  ```sh
  forge fmt
  ```

- **Generate gas snapshots:**

  ```sh
  forge snapshot
  ```

## License

The code in this repository is licensed under the [Apache-2.0 License](LICENSE).
