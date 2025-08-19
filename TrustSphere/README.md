# TrustSphere - Decentralized Trust Network

A comprehensive decentralized trust and credibility system built on Stacks blockchain that enables cross-ecosystem reputation tracking and verification.

## 🌟 Overview

TrustSphere creates a decentralized network where participants can build and maintain their trust profiles across multiple platforms and ecosystems. By leveraging blockchain technology, it provides transparent, immutable, and verifiable trust scores that can be utilized across various decentralized applications.

## 🚀 Key Features

### Core Functionality
- **Decentralized Trust Scoring**: Participants earn trust scores through peer evaluations
- **Cross-Ecosystem Integration**: Connect and verify trust across multiple platforms
- **Stake-Based Evaluations**: Require STX deposits to submit evaluations, preventing spam
- **Verification System**: Admin-controlled verification for enhanced credibility
- **Transparent History**: All evaluations are permanently recorded on blockchain

### Trust Mechanics
- **Initial Trust Score**: New participants start with 5000/10000 (neutral)
- **Evaluation Range**: Scores range from 1-10 for each evaluation
- **Weighted Averaging**: Trust scores update using weighted averages of all evaluations
- **Minimum Deposit**: 2 STX required to submit evaluations

## 📋 Contract Functions

### Public Functions

#### `join-trust-network()`
Register as a new participant in the TrustSphere network
- Creates participant profile with neutral trust score
- No duplicate registrations allowed

#### `submit-trust-evaluation(evaluated-participant, score, evaluation-type)`
Submit a trust evaluation for another participant
- **Parameters:**
  - `evaluated-participant`: Principal address of the participant being evaluated
  - `score`: Trust score (1-10)
  - `evaluation-type`: Category of evaluation (string, max 50 chars)
- **Requirements:**
  - Cannot evaluate yourself
  - Requires minimum 2 STX balance
  - No duplicate evaluations allowed

#### `verify-participant(participant)`
Verify a participant profile (admin only)
- Marks participant as verified
- Enhances trust credibility

#### `integrate-ecosystem(ecosystem, ecosystem-admin, multiplier)`
Add ecosystem integration (admin only)
- Connect external platforms to TrustSphere
- Set trust score multipliers for cross-platform verification

### Read-Only Functions

#### `get-participant-profile(participant)`
Retrieve complete participant trust profile

#### `get-trust-evaluation(evaluator, evaluated-participant)`
Get specific evaluation details between two participants

#### `get-total-participants()`
Get total number of network participants

#### `is-participant-verified(participant)`
Check verification status of a participant

#### `get-trust-percentage(participant)`
Get trust score as percentage (0-100)

#### `get-ecosystem-info(ecosystem)`
Get integration details for specific ecosystem

## 🔧 Technical Specifications

### Constants
- `MIN_DEPOSIT_AMOUNT`: 2,000,000 microSTX (2 STX)
- Error codes range: 500-505

### Data Structures

#### Participant Profile
```clarity
{
    trust-score: uint,        // Current trust score (0-10000)
    evaluation-count: uint,   // Total evaluations received
    deposit-balance: uint,    // Accumulated deposits from evaluations
    join-block: uint,         // Block height when joined
    verified-participant: bool // Verification status
}
```

#### Trust Evaluation
```clarity
{
    score: uint,              // Evaluation score (1-10)
    deposit-amount: uint,     // STX deposited for this evaluation
    block-timestamp: uint,    // Block when evaluation was made
    evaluation-type: string   // Category of evaluation
}
```

## 🔐 Security Features

- **Anti-Self-Evaluation**: Prevents participants from rating themselves
- **Deposit Requirements**: Minimum STX stake required for evaluations
- **Duplicate Prevention**: One evaluation per evaluator-participant pair
- **Admin Controls**: Verification and ecosystem integration restricted to admin
- **Immutable Records**: All evaluations permanently stored on blockchain

## 🛣️ Roadmap

- [ ] Multi-signature admin controls
- [ ] Time-weighted trust decay
- [ ] Reputation categories and specializations
- [ ] Integration with popular DeFi protocols
- [ ] Mobile SDK for easy integration
- [ ] Dispute resolution mechanism

## 🤝 Contributing

Contributions are welcome!