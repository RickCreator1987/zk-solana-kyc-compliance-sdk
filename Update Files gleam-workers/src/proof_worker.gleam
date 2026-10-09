import gleam/erlang/process
import gleam/erlang/atom
import gleam/http/request
import gleam/http/response
import gleam/http
import gleam/json
import gleam/io
import gleam/string
import gleam/result
import gleam/option

// External FFI to Mojo prover.
@external("mojo_prover", "prove")
fn mojo_prove(kyc_token_hash: String, user_wallet: String, provider_secret: String, public_wallet: String, commitment_root: String) -> #(String, String)

// External FFI to get public inputs format.
@external("mojo_prover", "verify")
fn mojo_verify(proof: String, public_inputs: String, verification_key: String) -> Bool

pub fn start() {
  let port = 9092
  let _ = process.spawn(fn() { listen(port) })
  io.println("Proof Worker started on port " <> string.int_to_string(port))
}

fn listen(port: Int) {
  // Simplified HTTP server placeholder.
  io.println("Listening on port " <> string.int_to_string(port))
  process.sleep_forever()
}

// Function to generate proof from KYC data.
pub fn generate_proof(kyc_token_hash: String, user_wallet: String, provider_secret: String, public_wallet: String, commitment_root: String) -> #(String, String) {
  // Call Mojo.
  mojo_prove(kyc_token_hash, user_wallet, provider_secret, public_wallet, commitment_root)
}