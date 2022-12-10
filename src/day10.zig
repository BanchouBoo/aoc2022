const std = @import("std");

const data = @embedFile("data/day10.txt");
const width = 40;

var register: i8 = 1;
var cycle: u16 = 0;
var signal_sum: u16 = 0;

fn incrementCycle() void {
    cycle += 1;

    // part 1
    if (cycle >= 20 and (cycle - 20) % 40 == 0)
        signal_sum += cycle * @intCast(u8, register);

    // part 2
    const index_in_row = (cycle - 1) % width;
    if (std.math.absInt(@intCast(i8, index_in_row) - register) catch unreachable <= 1)
        std.debug.print("##", .{})
    else
        std.debug.print("  ", .{});

    if (index_in_row == width - 1)
        std.debug.print("\n", .{});
}

pub fn main() !void {
    var intsructions = std.mem.tokenize(u8, data, "\n");
    while (intsructions.next()) |instruction| {
        switch (instruction[0]) {
            'a' => {
                incrementCycle();
                incrementCycle();
                register += try std.fmt.parseInt(i8, instruction[5..], 10);
            },
            'n' => incrementCycle(),
            else => unreachable,
        }
    }
    std.debug.print("The sum of the signal strengths is {d}\n", .{signal_sum});
}
