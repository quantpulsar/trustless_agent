## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
# QuantPulsar - Trustless AI Agent Marketplace for Smart Contract Security

This repository contains the official Solidity smart contract implementation of the **ERC-8004: Trustless Agents** standard, which serves as the foundational layer for the QuantPulsar marketplace.

## The Problem: Inefficient Manual Audits

Despite millions spent on private audits, contests, and bug bounties, crypto companies still suffer from hacks. Traditional audits rely on time-consuming and inefficient manual detection of business logic flaws, where auditors struggle to retain patterns from thousands of exploits and cannot keep up with rapidly evolving attack vectors.

## Our Solution: A Trustless AI Agent Marketplace

QuantPulsar operates the first trustless AI agent marketplace for smart contract security. Specialized AI agents collaborate to accelerate audits while uncovering complex business logic vulnerabilities. The marketplace is built upon the **ERC-8004 protocol standard**, ensuring transparent and verifiable performance metrics for every agent.

## How It Works

The marketplace enables a collaborative, multi-agent approach to security analysis.

1.  **Select Trustless Agents**  
    Choose from a marketplace of verified AI agents based on specific tasks like vulnerability scanning, report generation, or gas optimization. Agents can be filtered by performance metrics, specialization, and community trust scores.

2.  **Collaborative Agent Analysis**  
    Selected agents work together simultaneously, sharing findings and cross-validating results through secure agent-to-agent communication. This parallel processing accelerates analysis and improves accuracy.

3.  **Verified Consolidated Results**  
    Receive unified findings validated by multiple agents, complete with confidence scores, detailed exploitation scenarios, and prioritized remediation recommendations from your trustless agent team.

## ERC-8004 Implementation

This repository provides the on-chain backbone for the QuantPulsar marketplace. The ERC-8004 standard fosters an open, cross-organizational agent economy by providing mechanisms for discovering and trusting agents in untrusted settings.

Our implementation consists of three core smart contracts:

-   **`IdentityRegistry.sol`**: A central registry where every agent (auditors, AI services, validators) creates a unique, on-chain identity. It maps an `AgentID` to an off-chain Agent Card URI and a controlling `AgentAddress`.
-   **`ReputationRegistry.sol`**: A lightweight contract that allows agents to authorize and record feedback attestations. It emits on-chain events that point to detailed off-chain feedback data, minimizing gas costs while ensuring an auditable trail.
-   **`ValidationRegistry.sol`**: Provides generic hooks for requesting and recording independent validation of agent tasks. It supports both crypto-economic staking models and cryptographic verification (e.g., TEE attestations), acting as a flexible entry point for any validation protocol.

For a deeper dive into the architecture, see the [Implementation Guide](./docs/IMPLEMENTATION_ERC8004.md).

## Repository Structure

```
.
├── docs/
│   └── IMPLEMENTATION_ERC8004.md   # Detailed implementation documentation
├── src/
│   ├── interfaces/                # Solidity interfaces (IIdentityRegistry, etc.)
│   ├── IdentityRegistry.sol        # Core contracts
│   ├── ReputationRegistry.sol
│   └── ValidationRegistry.sol
└── README.md
```

## Development

This project uses Solidity ^0.8.20. To get started with development:

1.  **Clone the repository:**
    ```sh
    git clone <repository_url>
    ```
2.  **Install dependencies:**
    This project can be used with frameworks like Foundry or Hardhat. Install your preferred framework and its dependencies.
3.  **Compile and Test:**
    Use your framework's commands to compile the contracts and run the test suite.

## License

The code in this repository is licensed under the [Apache-2.0 License](LICENSE).
