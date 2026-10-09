# Pipeline

## Build

1. Build Zig crypto: `zig build-lib -dynamic -O ReleaseFast src/ffi_expose.zig -lc`
2. Compile Vale PII to C: `vale compile src/tokenize.vale src/redact.vale -o libvale.a`
3. Build Mojo prover: `mojo build src/prover.moj -o libmojo.so`
4. Build Gleam workers: `gleam build`
5. Build Ballerina service: `bal build`
6. Build V SDK: `v build`
7. Build ReScript dapp: `npm run build`
8. Build Solana program: `cargo build-bpf`

## Run

1. Start Zig crypto library and ensure it's in LD_LIBRARY_PATH.
2. Start Gleam workers: `gleam run -m kyc_worker`
3. Start Ballerina service: `bal run`
4. Run dapp: `npm start`
5. Deploy Solana program to devnet.

## Integration

All components communicate via HTTP or FFI. The Ballerina service calls Gleam workers over HTTP. Gleam workers call Mojo, Vale, Bosque via FFI (assuming shared libraries). The dapp calls Ballerina directly.