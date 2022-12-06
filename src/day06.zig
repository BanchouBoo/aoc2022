const std = @import("std");

const data = @embedFile("data/day06.txt");

fn findEndOfUniqueString(input: []const u8, length: u8) usize {
    var set = std.StaticBitSet(26).initEmpty();

    return for (input) |char, i| {
        const before_count = set.count();

        if (before_count == length)
            break i;

        set.set(char - 'a');
        if (set.count() == before_count) {
            for (input[i - before_count .. i - 1]) |char_2| {
                if (char == char_2) break;
                set.toggle(char_2 - 'a');
            }
        }
    } else unreachable;
}

pub fn main() !void {
    std.debug.print(
        "The amount of characters processed before the packet marker is {d}\n",
        .{findEndOfUniqueString(data, 4)},
    );

    std.debug.print(
        "The amount of characters processed before the message marker is {d}\n",
        .{findEndOfUniqueString(data, 14)},
    );
}
