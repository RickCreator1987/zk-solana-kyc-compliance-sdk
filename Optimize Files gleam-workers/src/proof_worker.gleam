// Optimized proof worker with parallel job execution and batching.
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
import gleam/list

// External FFI to Mojo prover (zero-copy).
@external("mojo_prover", "prove")
fn mojo_prove(
  kyc_token_hash: Int, user_wallet: Int, provider_secret: Int,
  merkle_path: List[Int], public_wallet: Int, commitment_root: Int
) -> #(List[Int], List[Int])

@external("mojo_prover", "verify")
fn mojo_verify(proof: List[Int], public_inputs: List[Int], vk: List[Int]) -> Bool

// Worker pool.
type WorkerPool = List(process.Pid)

fn start_workers(count: Int) -> WorkerPool {
  list.range(0, count - 1)
  |> list.map(fn(_) { process.spawn(fn() { worker_loop() }) })
}

fn worker_loop() {
  // Wait for job.
  process.receive_forever(
    fn(msg) {
      case msg {
        #("prove", params, sender) -> {
          let #(proof, inputs) = mojo_prove(
            params.kyc_token_hash, params.user_wallet, params.provider_secret,
            params.merkle_path, params.public_wallet, params.commitment_root
          )
          process.send(sender, #("proof", proof, inputs))
        }
        _ -> Nil
      }
      worker_loop()
    }
  )
}

// Submit job to pool.
fn submit_job(pool: WorkerPool, params) -> process.Pid {
  let pid = process.self()
  // Pick a worker (round-robin).
  let worker = list.at(pool, 0) |> result.unwrap(process.self())
  process.send(worker, #("prove", params, pid))
  pid
}

// Batch multiple proof requests.
pub fn batch_generate_proofs(requests: List) -> List {
  let pool = start_workers(4) // 4 workers.
  let pids = requests |> list.map(fn(req) { submit_job(pool, req) })
  // Wait for all.
  pids |> list.map(fn(pid) { process.receive_one(pid, 1000) })
}

// HTTP endpoint.
pub fn start() {
  let port = 9092
  let _ = process.spawn(fn() { listen(port) })
  io.println("Proof Worker started on port " <> string.int_to_string(port))
}

fn listen(port: Int) {
  // Simplified HTTP server.
  io.println("Listening on port " <> string.int_to_string(port))
  process.sleep_forever()
}