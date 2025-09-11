# BitFortress Protocol 🏰

## Bitcoin-Native Liquid Staking with Fortress-Grade Security

BitFortress transforms STX into productive, Bitcoin-secured yield through an **innovative liquid staking protocol**. It combines the security guarantees of Bitcoin finality with advanced staking incentives, governance participation, and adaptive withdrawal mechanics.

The protocol enables users to deposit STX, earn compounding rewards, and maintain liquidity through **fortress tokens**—a fungible representation of staked positions. Built on **Stacks Layer 2**, BitFortress delivers institutional-grade infrastructure with retail accessibility.

---

## 🔑 Core Features

* **Bitcoin-Finalized Security** – All staking operations rely on Bitcoin’s settlement layer.
* **Liquid Staking** – Users receive **fortress tokens (FRT)** that maintain liquidity while earning rewards.
* **Dynamic Tiers** – A tier-based system offering higher multipliers and governance weight for larger stakes.
* **Premium Yields** – Locking periods up to 12 months earn premium APYs (up to **15%**).
* **Governance Participation** – Stakers shape protocol parameters via proposal and voting mechanisms.
* **Emergency Fortress Mode** – Multi-sig controlled failsafe to pause protocol operations during anomalies.
* **Adaptive Withdrawals** – Cooldown periods to protect against cascading withdrawals and maintain stability.

---

## ⚙️ System Overview

BitFortress operates as a **liquid staking + governance protocol** on Stacks, integrating three primary layers:

1. **Staking Layer**

   * Users deposit STX into the protocol.
   * Fortress tokens are minted 1:1, representing staked positions.
   * Rewards accrue over time based on deposit size, lock duration, and tier multiplier.

2. **Governance Layer**

   * Users accumulate governance power proportional to their stake and tier level.
   * Governance proposals are submitted and voted on by fortress token holders.
   * Key parameters (e.g., reward rates, cooldowns, tier rules) can evolve via governance.

3. **Security Layer**

   * Protocol operations are finalized on Bitcoin through Stacks consensus.
   * Emergency fortress mode enables controlled halts.
   * Cooldown withdrawal periods prevent systemic liquidity risks.

---

## 🧱 Contract Architecture

The protocol is implemented as a **single Clarity smart contract** with modular components:

* **Token Management**

  * `fortress-token`: fungible representation of staked STX and rewards.
  * Minting and burning aligned with staking/withdrawal logic.

* **Vault Management**

  * `StakingVaults` map maintains user positions.
  * Tracks deposits, fortress token balances, reward accrual, governance weight, and lock durations.

* **Tier System**

  * `FortressTiers` map defines multiplier configurations, governance weights, and premium access.
  * Dynamic tier assignment based on deposit thresholds.

* **Governance**

  * `Proposals` map stores proposals with metadata, voting periods, and quorum thresholds.
  * Governance power directly linked to staked amounts and tier multipliers.

* **Security & Controls**

  * `protocol-paused` and `fortress-mode` toggles for safety.
  * Withdrawal cooldown mechanisms for systemic protection.

---

## 📊 Data Flow

**Staking Lifecycle:**

1. **Stake:** User deposits STX → fortress tokens minted → vault updated.
2. **Reward Accrual:** Rewards accumulate per block based on deposit, tier multiplier, and lock duration.
3. **Claim Rewards:** User claims rewards → fortress tokens minted → vault updated.
4. **Withdrawal:** User initiates withdrawal → cooldown enforced → fortress tokens burned → STX returned.

**Governance Lifecycle:**

1. **Submit Proposal:** Requires minimum governance power.
2. **Voting Period:** Users cast votes weighted by governance power.
3. **Execution:** Proposals reaching quorum and majority are eligible for execution (via governance hooks).

---

## 📖 Public Functions

* `stake-in-fortress (amount lock-duration)` → Deposit STX and mint fortress tokens.
* `claim-staking-rewards` → Claim accumulated staking rewards.
* `initiate-withdrawal (amount)` → Begin withdrawal cooldown for STX.
* `complete-withdrawal` → Burn fortress tokens and withdraw STX after cooldown.
* `submit-governance-proposal (title desc period)` → Submit protocol governance proposal.
* `cast-governance-vote (proposal-id support)` → Cast governance vote.
* `emergency-fortress-mode` / `deactivate-fortress-mode` → Protocol safety toggles.

---

## 📡 Read-Only Queries

* `get-protocol-stats` → Returns global protocol state and totals.
* `get-user-vault (user)` → Returns vault details for a user.
* `get-proposal-details (proposal-id)` → Returns governance proposal details.
* `get-fortress-tier (tier-level)` → Returns tier configuration.
* `calculate-potential-rewards (user)` → Simulates reward accumulation for a user.

---

## 🚀 Getting Started

1. **Deploy Contract**

   * Deploy the contract to Stacks blockchain (testnet/mainnet).

2. **Initialize Tiers**

   ```clarity
   (contract-call? .bitfortress initialize-fortress-tiers)
   ```

3. **Stake STX**

   ```clarity
   (contract-call? .bitfortress stake-in-fortress u10000000 u4320) ;; 10 STX locked 3 months
   ```

4. **Claim Rewards**

   ```clarity
   (contract-call? .bitfortress claim-staking-rewards)
   ```

5. **Withdraw STX**

   ```clarity
   (contract-call? .bitfortress initiate-withdrawal u10000000)
   (contract-call? .bitfortress complete-withdrawal)
   ```

---

## 🔒 Security Considerations

* Protocol integrates **multi-sig emergency controls** for halting operations.
* Withdrawal cooldowns reduce **flash liquidity drains**.
* Governance requires quorum thresholds to prevent **whale dominance**.
* Comprehensive error codes ensure strict validation across operations.

---

## 📜 License

This protocol is released under the **MIT License**.
