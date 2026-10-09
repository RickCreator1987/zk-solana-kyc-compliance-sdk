# Architecture

The ZK Solana KYC Compliance SDK is a multi-language system for on-chain KYC verification using zero-knowledge proofs.

## Components

- **Ballerina Service**: Public API gateway.
- **Gleam Workers**: Process KYC jobs and generate proofs.
- **Mojo Prover**: ZK proving engine with GPU acceleration via Bend.
- **Zig Crypto**: Cryptographic primitives (Poseidon, Ed25519).
- **Vale PII**: PII tokenization and redaction.
- **Bosque Policy**: Deterministic compliance rules.
- **V SDK**: Client SDK for V language.
- **ReScript DApp**: Frontend demo.
- **Solana Program**: On-chain verifier.

## Data Flow

1. User submits KYC data via ReScript dapp or V SDK.
2. Ballerina service receives request and calls Gleam worker.
3. Gleam worker tokenizes PII via Vale, evaluates risk via Bosque, and requests proof from Mojo prover.
4. Mojo prover uses Bend kernels for MSM/FFT to generate proof.
5. Gleam worker returns result to Ballerina, which responds.
6. User can submit proof to Solana program for on-chain verification.