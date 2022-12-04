const std = @import("std");

const MaskType = u99;

const data = @embedFile("data/day04.txt");

pub fn main() !void {
    var pairs = std.mem.tokenize(u8, data, "\n");
    var containing_pairs: usize = 0;
    var overlapping_pairs: usize = 0;

    while (pairs.next()) |pair| {
        var pair_split = std.mem.tokenize(u8, pair, "-,");
        const p1_min = std.fmt.parseInt(u8, pair_split.next().?, 10) catch unreachable;
        const p1_max = std.fmt.parseInt(u8, pair_split.next().?, 10) catch unreachable;
        const p2_min = std.fmt.parseInt(u8, pair_split.next().?, 10) catch unreachable;
        const p2_max = std.fmt.parseInt(u8, pair_split.next().?, 10) catch unreachable;

        const one = @as(u256, 1);
        const p1_mask = @truncate(
            MaskType,
            ((one << (p1_min - 1)) - 1) ^ ((one << (p1_max)) - 1),
        );
        const p2_mask = @truncate(
            MaskType,
            ((one << (p2_min - 1)) - 1) ^ ((one << (p2_max)) - 1),
        );
        const mask_or = p1_mask | p2_mask;

        containing_pairs += @boolToInt(mask_or == p1_mask or mask_or == p2_mask);
        overlapping_pairs += @boolToInt(p1_mask & p2_mask > 0);
    }

    std.log.info("The amount of pairs where one range fully contains another is {d}", .{containing_pairs});
    std.log.info("The amount of pairs where any overlap occurs is {d}", .{overlapping_pairs});
}
