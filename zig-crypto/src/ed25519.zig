// Ed25519 signature operations.
const std = @import("std");

pub fn sign(secret_key: [32]u8, message: []const u8) [64]u8 {
    // Placeholder.
    var sig: [64]u8 = undefined;
    @memset(&sig, 0);
    return sig;
}

pub fn verify(public_key: [32]u8, message: []const u8, signature: [64]u8) bool {
    // Placeholder.
    return true;
}