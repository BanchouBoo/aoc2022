const std = @import("std");

const data = @embedFile("data/day05.txt");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var data_split = std.mem.split(u8, data, "\n\n");

    var crates = std.mem.splitBackwards(u8, data_split.next().?, "\n");
    var p1_stacks = [1]std.ArrayListUnmanaged(u8){.{}} ** 9;
    var p2_stacks = [1]std.ArrayListUnmanaged(u8){.{}} ** 9;
    defer for (p1_stacks) |*stack| {
        stack.clearAndFree(allocator);
    };
    defer for (p2_stacks) |*stack| {
        stack.clearAndFree(allocator);
    };

    while (crates.next()) |row| {
        if (row[1] == '1') continue;
        var i: u8 = 1;
        while (i <= 33) {
            if (row[i] != ' ') {
                try p1_stacks[i / 4].append(allocator, row[i]);
                try p2_stacks[i / 4].append(allocator, row[i]);
            }
            i += 4;
        }
    }

    var instructions = std.mem.tokenize(u8, data_split.next().?, "\n");
    while (instructions.next()) |instruction| {
        var instruction_data = std.mem.tokenize(u8, instruction, "movefrt ");

        const amount = std.fmt.parseInt(u8, instruction_data.next().?, 10) catch unreachable;
        const from = (std.fmt.parseInt(u8, instruction_data.next().?, 10) catch unreachable) - 1;
        const to = (std.fmt.parseInt(u8, instruction_data.next().?, 10) catch unreachable) - 1;

        var i: u8 = 0;
        while (i < amount) {
            try p1_stacks[to].append(allocator, p1_stacks[from].pop());
            i += 1;
        }

        const slice = p2_stacks[from].items[p2_stacks[from].items.len - amount ..];
        p2_stacks[from].items.len -= amount;
        try p2_stacks[to].appendSlice(allocator, slice);
    }

    std.debug.print("The top of each stack for part 1 is ", .{});
    for (p1_stacks) |stack| {
        std.debug.print("{c}", .{stack.items[stack.items.len - 1]});
    }
    std.debug.print("\n", .{});

    std.debug.print("The top of each stack for part 2 is ", .{});
    for (p2_stacks) |stack| {
        std.debug.print("{c}", .{stack.items[stack.items.len - 1]});
    }
    std.debug.print("\n", .{});
}
