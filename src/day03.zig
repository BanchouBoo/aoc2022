const std = @import("std");

const data = @embedFile("data/day03.txt");

fn MultiLineIterator(comptime line_count: usize) type {
    return struct {
        buffer: []const u8,
        index: ?usize,

        pub fn next(self: *@This()) ?[line_count][]const u8 {
            var start = self.index orelse return null;
            var result: [3][]const u8 = .{ "", "", "" };
            var found_newlines: usize = 0;
            var index = start;
            for (self.buffer[start..]) |c| {
                if (c == '\n') {
                    result[found_newlines] = self.buffer[start..index];
                    start = index + 1;
                    found_newlines += 1;
                    if (found_newlines == line_count)
                        break;
                }
                index += 1;
            }

            if (start == self.buffer.len) {
                self.index = null;
            } else {
                self.index = start;
            }

            return result;
        }
    };
}

fn getPriority(char: u8) usize {
    return switch (char) {
        'a'...'z' => (char - 'a') + 1,
        'A'...'Z' => (char - 'A') + 27,
        else => unreachable,
    };
}

pub fn main() !void {
    var rucksack_groups = MultiLineIterator(3){ .buffer = data, .index = 0 };
    var p1_sum: usize = 0;
    var p2_sum: usize = 0;

    while (rucksack_groups.next()) |group| {
        // part 1
        for (group) |rucksack| {
            const half_size = rucksack.len / 2;
            const compartment_1 = rucksack[0..half_size];
            const compartment_2 = rucksack[half_size..];
            loop: for (compartment_1) |a| {
                for (compartment_2) |b| {
                    if (a == b) {
                        p1_sum += getPriority(a);
                        break :loop;
                    }
                }
            }
        }

        // part 2
        loop: for (group[0]) |a| {
            for (group[1]) |b| {
                if (a == b) {
                    for (group[2]) |c| {
                        if (a == c) {
                            p2_sum += getPriority(a);
                            break :loop;
                        }
                    }
                }
            }
        }
    }

    std.log.info("The sum of each compartment's duplicate items' priorities is {d}", .{p1_sum});
    std.log.info("The sum of each team's duplicate items' priorities is {d}", .{p2_sum});
}
