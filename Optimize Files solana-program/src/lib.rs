// Optimized program with minimal account writes and rent-efficient storage.
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    pubkey::Pubkey,
    borsh::{BorshDeserialize, BorshSerialize},
    rent::Rent,
    system_program,
    sysvar::Sysvar,
};
use borsh::BorshSerialize;

mod verify_proof;
use verify_proof::{KycProof, verify_proof};

entrypoint!(process_instruction);

fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let account_info_iter = &mut accounts.iter();
    let user_account = next_account_info(account_info_iter)?;
    let system_program = next_account_info(account_info_iter)?;

    let proof_data = KycProof::try_from_slice(instruction_data)?;

    // Verify proof.
    if !verify_proof(&proof_data) {
        msg!("Proof verification failed");
        return Err(solana_program::program_error::ProgramError::InvalidArgument);
    }

    // Ensure account is owned by program.
    if user_account.owner != program_id {
        // Create PDA account if needed.
        let (pda, bump_seed) = Pubkey::find_program_address(&[b"kyc", &proof_data.public_wallet], program_id);
        if user_account.key != &pda {
            // Initialize account.
            let rent = Rent::get()?;
            let space = 1; // Just a flag.
            let lamports = rent.minimum_balance(space);
            system_program::create_account(
                system_program,
                user_account,
                &rent,
                lamports,
                space as u64,
                program_id,
            )?;
        }
        // Write flag.
        let mut data = user_account.try_borrow_mut_data()?;
        data[0] = 1; // Mark as KYC-verified.
    } else {
        // Account exists, just update.
        let mut data = user_account.try_borrow_mut_data()?;
        data[0] = 1;
    }

    msg!("KYC verified for user");
    Ok(())
}