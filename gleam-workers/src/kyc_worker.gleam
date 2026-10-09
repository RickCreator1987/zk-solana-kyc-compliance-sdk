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

// External FFI to Mojo prover (assume compiled to shared library).
@external("mojo_prover", "generate_kyc_proof")
fn generate_proof(user_id: String, name: String, email: String) -> String

// External FFI to Vale PII tokenization.
@external("vale_pii", "tokenize")
fn tokenize_pii(text: String) -> String

// External FFI to Bosque policy.
@external("bosque_policy", "evaluate_risk")
fn evaluate_risk(user_data: String) -> Int

pub fn start() {
  let port = 9091
  let _ = process.spawn(fn() { listen(port) })
  io.println("KYC Worker started on port " <> string.int_to_string(port))
}

fn listen(port: Int) {
  // Simplified: use a loop with accept. In practice, use gleam_http/erlang.
  // We'll assume a server is set up via erlang: httpd.
  // For brevity, we'll just handle one request.
  // Actual implementation would use gleam_http/erlang's server functions.
  // Placeholder: accept a request, process, respond.
  // We'll use a mock: just print.
  io.println("Listening on port " <> string.int_to_string(port))
  // Simulate a loop.
  process.sleep_forever()
}

// This function would be called from the HTTP server.
pub fn handle_kyc_request(req: request.Request) -> response.Response {
  let body = request.require_body(req)
  let user_data = json.decode(body) |> result.unwrap( json.object([]) )
  let user_id = json.get_string(user_data, "userId") |> result.unwrap("")
  let name = json.get_string(user_data, "name") |> result.unwrap("")
  let email = json.get_string(user_data, "email") |> result.unwrap("")

  // Tokenize PII.
  let tokenized_name = tokenize_pii(name)
  let tokenized_email = tokenize_pii(email)

  // Evaluate risk via Bosque policy.
  let risk_score = evaluate_risk("{\"name\": \"" <> tokenized_name <> "\", \"email\": \"" <> tokenized_email <> "\"}")

  // Generate ZK proof.
  let proof = generate_proof(user_id, tokenized_name, tokenized_email)

  let response_body = json.object([
    ("status", json.string("approved")),
    ("riskScore", json.int(risk_score)),
    ("proof", json.string(proof))
  ])
  response.set_body(response_body, response.new(200))
}