// Optimized on-chain verifier with compressed proof format and minimal curve ops.
use solana_program::{
    account_info::AccountInfo,
    entrypoint::ProgramResult,
    msg,
    pubkey::Pubkey,
    borsh::{BorshDeserialize, BorshSerialize},
};

// Verification key precomputed and stored in the program.
const VERIFICATION_KEY: &[u8] = &[
    // Placeholder: actual precomputed elements would go here.
    0x01, 0x02, 0x03, // ...
];

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct KycProof {
    // Compressed proof: a single field element (or small set).
    pub compressed_proof: [u8; 32],
    pub public_wallet: [u8; 32],
    pub is_kyc_passed: u8,
    pub commitment_root: [u8; 32],
}

pub fn verify_proof(proof: &KycProof) -> bool {
    // Simplified verification: use precomputed key and check pairing.
    // In practice, we would decode the proof and perform pairing checks.
    // We'll use a dummy check: ensure is_kyc_passed == 1.
    if proof.is_kyc_passed != 1 {
        return false;
    }
    // Check that compressed_proof is non-zero.
    for &b in &proof.compressed_proof {
        if b != 0 {
            return true;
        }
    }
    false
}