// Expose functions as C ABI for other languages.
const std = @import("std");
const poseidon = @import("poseidon.zig");
const ed25519 = @import("ed25519.zig");
const hash = @import("hash.zig");

export fn poseidon_hash(input_ptr: [*]const u8, input_len: usize, out_ptr: [*]u8) void {
    const input = input_ptr[0..input_len];
    const result = poseidon.poseidon(input);
    @memcpy(out_ptr, &result);
}

export fn ed25519_verify(pubkey_ptr: [*]const u8, msg_ptr: [*]const u8, msg_len: usize, sig_ptr: [*]const u8) bool {
    var pubkey: [32]u8 = undefined;
    @memcpy(&pubkey, pubkey_ptr);
    const msg = msg_ptr[0..msg_len];
    var sig: [64]u8 = undefined;
    @memcpy(&sig, sig_ptr);
    return ed25519.verify(pubkey, msg, sig);
}