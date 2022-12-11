const std = @import("std");

const data = @embedFile("data/day11.txt");

const ItemList = std.ArrayListUnmanaged(u64);
const Monkey = struct {
    items: ItemList,
    inspected_items: u64,
    oper_fn: *const fn (u64, u64) u64,
    oper_val: u64,
    test_val: u64,
    throw_to: [2]usize,

    pub fn inspectItemPart1(self: Monkey, old: u64) u64 {
        return self.inspectItemPart2(old) / 3;
    }

    pub fn inspectItemPart2(self: Monkey, old: u64) u64 {
        return if (self.oper_val != 0)
            self.oper_fn(old, self.oper_val)
        else
            self.oper_fn(old, old);
    }

    pub fn testItem(self: Monkey, item: u64) usize {
        return self.throw_to[@boolToInt(item % self.test_val == 0)];
    }
};

fn add(a: u64, b: u64) u64 {
    return a + b;
}

fn mul(a: u64, b: u64) u64 {
    return a * b;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var p2_mod: usize = 1;

    var source_monkeys: [8]Monkey = undefined;
    var chunks = std.mem.split(u8, data, "\n\n");
    while (chunks.next()) |chunk| {
        var chunk_iter = std.mem.tokenize(u8, chunk, "\n");
        const monkey_line = chunk_iter.next().?;
        const monkey_index = monkey_line[7] - '0';

        const item_line = chunk_iter.next().?;
        var items: ItemList = .{};
        var item_iter = std.mem.tokenize(u8, item_line[18..], ", ");
        while (item_iter.next()) |item|
            try items.append(allocator, std.fmt.parseInt(u64, item, 10) catch unreachable);

        const operation_line = chunk_iter.next().?;
        const oper_fn = switch (operation_line[23]) {
            '+' => &add,
            '*' => &mul,
            else => unreachable,
        };
        const oper_val_slice = operation_line[25..];
        const oper_val = if (std.mem.eql(u8, oper_val_slice, "old"))
            0
        else
            std.fmt.parseInt(u64, oper_val_slice, 10) catch unreachable;

        const test_line = chunk_iter.next().?;
        const test_val = std.fmt.parseInt(u64, test_line[21..], 10) catch unreachable;
        p2_mod *= test_val;

        var throw_to: [2]usize = undefined;
        const true_line = chunk_iter.next().?;
        throw_to[1] = true_line[29] - '0';

        const false_line = chunk_iter.next().?;
        throw_to[0] = false_line[30] - '0';

        source_monkeys[monkey_index] = Monkey{
            .items = items,
            .inspected_items = 0,
            .oper_fn = oper_fn,
            .oper_val = oper_val,
            .test_val = test_val,
            .throw_to = throw_to,
        };
    }

    {
        var monkeys = try allocator.create([8]Monkey);
        std.mem.copy(Monkey, monkeys[0..], source_monkeys[0..]);
        for (monkeys) |*monkey, i|
            monkey.*.items.items = try allocator.dupe(u64, source_monkeys[i].items.items);
        var most_active_monkeys: [2]usize = .{ 0, 0 };
        const rounds: usize = 20;
        var round: usize = 0;
        while (round < rounds) : (round += 1) {
            for (monkeys) |*monkey, i| {
                monkey.*.inspected_items += monkey.items.items.len;
                for (most_active_monkeys) |*m| {
                    if (m.* == i) break;
                    if (monkey.inspected_items > monkeys[m.*].inspected_items) {
                        m.* = i;
                        break;
                    }
                }
                while (monkey.items.popOrNull()) |old| {
                    const new = monkey.inspectItemPart1(old);
                    try monkeys[monkey.testItem(new)].items.append(allocator, new);
                }
            }
        }
        const monkey_business = monkeys[most_active_monkeys[0]].inspected_items *
            monkeys[most_active_monkeys[1]].inspected_items;
        std.debug.print("The level of monkey business for part 1 is {d}\n", .{monkey_business});
    }

    {
        var monkeys = try allocator.create([8]Monkey);
        std.mem.copy(Monkey, monkeys[0..], source_monkeys[0..]);
        for (monkeys) |*monkey, i|
            monkey.*.items.items = try allocator.dupe(u64, source_monkeys[i].items.items);
        var most_active_monkeys: [2]usize = .{ 0, 0 };
        const rounds: usize = 10000;
        var round: usize = 0;
        while (round < rounds) : (round += 1) {
            for (monkeys) |*monkey, i| {
                monkey.*.inspected_items += monkey.items.items.len;
                for (most_active_monkeys) |*m| {
                    if (m.* == i) break;
                    if (monkey.inspected_items > monkeys[m.*].inspected_items) {
                        m.* = i;
                        break;
                    }
                }
                while (monkey.items.popOrNull()) |old| {
                    const new = monkey.inspectItemPart2(old) % p2_mod;
                    try monkeys[monkey.testItem(new)].items.append(allocator, new);
                }
            }
        }
        const monkey_business = monkeys[most_active_monkeys[0]].inspected_items *
            monkeys[most_active_monkeys[1]].inspected_items;
        std.debug.print("The level of monkey business for part 2 is {d}\n", .{monkey_business});
    }
}
