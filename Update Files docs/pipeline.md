# Pipeline

## Full Flow with ZK Proofs

1. **User submits KYC data** via ReScript dapp or V SDK.
2. **Ballerina service** receives request and calls Gleam worker for KYC.
3. **Gleam worker** tokenizes PII (Vale), evaluates risk (Bosque), and if KYC passed, generates a zero-knowledge proof using Mojo prover.
4. **Mojo prover** uses Bend kernels for MSM/FFT acceleration and Zig crypto for Poseidon hash, producing a proof and public inputs:
   - public_wallet: user's wallet address
   - is_kyc_passed: 1 (if successful)
   - commitment_root: root of the KYC registry Merkle tree
5. **Ballerina** returns proof + public inputs to the client.
6. **Client** can submit the proof to the Solana program.
7. **Solana program** verifies the proof on-chain:
   - Uses hard-coded verification key
   - Checks that is_kyc_passed == 1
   - If valid, marks user as KYC-verified in a PDA account.

## Public Inputs

- `public_wallet`: 32-byte wallet address
- `is_kyc_passed`: 1-byte flag
- `commitment_root`: 32-byte Merkle root

## Circuit Constraints

- `user_wallet` (private) equals `public_wallet` (public)
- `poseidon(kyc_token_hash, user_wallet, provider_secret) == commitment_root` (public)
- If all hold, `is_kyc_passed = 1`

## Security

The proof reveals no private information (kyc_token_hash, user_wallet, provider_secret) while proving that the user is KYC-passed and belongs to the registry.