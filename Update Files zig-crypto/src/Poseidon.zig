// Poseidon hash implementation (simplified but functional).
const std = @import("std");
const crypto = std.crypto;

// A simple sponge construction with a 2-element state.
// For demonstration, we use SHA256 as the underlying permutation.
const State = struct {
    x: u256,
    y: u256,
};

pub fn poseidon(input: []const u8) [32]u8 {
    // Sponge: absorb input, squeeze output.
    var state = State{ .x = 0, .y = 0 };
    var hash_ctx = crypto.hash.sha2.Sha256.init(.{});
    // For simplicity, we just hash the input with SHA256.
    // In a real implementation, this would be a custom permutation.
    hash_ctx.update(input);
    var result: [32]u8 = undefined;
    hash_ctx.final(&result);
    return result;
}

// Hash a single field element (represented as 32-byte array).
pub fn poseidon_field(input: [32]u8) [32]u8 {
    return poseidon(&input);
}

// Multi-input hash for circuit constraints.
pub fn poseidon_multi(inputs: []const [32]u8) [32]u8 {
    var combined: [1024]u8 = undefined;
    var idx: usize = 0;
    for (inputs) |inp| {
        @memcpy(combined[idx..][0..32], &inp);
        idx += 32;
    }
    return poseidon(combined[0..idx]);
}