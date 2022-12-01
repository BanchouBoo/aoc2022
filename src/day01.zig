const std = @import("std");
const Allocator = std.mem.Allocator;

const data = @embedFile("data/day01.txt");

fn getElfCalorieCounts(allocator: Allocator, input: []const u8) ![][2]usize {
    var elf_calorie_list = std.ArrayListUnmanaged([2]usize){};
    errdefer elf_calorie_list.clearAndFree(allocator);

    var elf_inventories = std.mem.split(u8, input, "\n\n");
    var i: usize = 0;
    while (elf_inventories.next()) |inventory| {
        var items = std.mem.split(u8, inventory, "\n");
        var calories: usize = 0;
        while (items.next()) |item| {
            if (item.len > 0)
                calories += std.fmt.parseInt(usize, item, 10) catch return error.InvalidInput;
        }
        try elf_calorie_list.append(allocator, .{ i, calories });
        i += 1;
    }

    return elf_calorie_list.items;
}

fn elfSort(_: void, lhs: [2]usize, rhs: [2]usize) bool {
    return lhs[1] > rhs[1];
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var output = try getElfCalorieCounts(allocator, data);
    defer allocator.free(output);

    std.sort.insertionSort([2]usize, output, {}, elfSort);

    var sum: usize = 0;
    for (output[0..3]) |item| {
        sum += item[1];
    }
    std.log.info("Sum of top three elves' calories: {d}\n", .{sum});
}
