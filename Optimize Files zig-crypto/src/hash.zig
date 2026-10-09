// Batch hashing for Merkle trees.
const std = @import("std");
const poseidon = @import("poseidon.zig");

// Batch hash multiple inputs.
pub fn batch_poseidon2(inputs: []const []const u8, outputs: [][32]u8) void {
    // In a real implementation, we'd use SIMD or GPU.
    for (inputs, outputs) |inp, out| {
        const h = poseidon.poseidon2(inp);
        @memcpy(out.ptr, &h);
    }
}

// Merkle tree root from leaves (simplified).
pub fn merkle_root(leaves: []const []const u8) [32]u8 {
    var layer = std.ArrayList([32]u8).init(std.heap.page_allocator);
    defer layer.deinit();
    // Hash leaves.
    for (leaves) |leaf| {
        var h: [32]u8 = undefined;
        batch_poseidon2(&.{leaf}, &.{h});
        layer.append(h) catch unreachable;
    }
    while (layer.items.len > 1) {
        var next = std.ArrayList([32]u8).init(std.heap.page_allocator);
        defer next.deinit();
        for (0..layer.items.len/2) |i| {
            var combined: [64]u8 = undefined;
            @memcpy(combined[0..32], &layer.items[i*2]);
            @memcpy(combined[32..64], &layer.items[i*2+1]);
            var h: [32]u8 = undefined;
            batch_poseidon2(&.{&combined}, &.{h});
            next.append(h) catch unreachable;
        }
        if (layer.items.len % 2 == 1) {
            next.append(layer.items[layer.items.len-1]) catch unreachable;
        }
        layer = next;
    }
    return layer.items[0];
}