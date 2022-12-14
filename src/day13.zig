const std = @import("std");

const data = @embedFile("data/day13.txt");

const CompareResult = enum { lt, eq, gt };

const Item = union(enum) {
    integer: i8,
    list: std.ArrayListUnmanaged(Item),

    pub fn compare(a: Item, b: Item) CompareResult {
        if (a == .integer and b == .integer) {
            return compareInt(a.integer, b.integer);
        } else if (a == .list and b == .list) {
            return compareList(a.list.items, b.list.items);
        } else {
            return if (a == .list)
                compareList(a.list.items, &[1]Item{(b)})
            else
                compareList(&[1]Item{(a)}, b.list.items);
        }
    }

    pub fn sort(self: Item) void {
        std.sort.insertionSort(Item, self.list.items, {}, lessThan);
    }

    pub fn getDecoderKey(self: Item) usize {
        var result: usize = 1;
        var found: usize = 0;
        for (self.list.items) |item, i| {
            if (item == .list and item.list.items.len == 1) {
                const subitem = item.list.items[0];
                if (subitem == .integer and (subitem.integer == 2 or subitem.integer == 6)) {
                    result *= i + 1;
                    found += 1;
                    if (found == 2)
                        return result;
                }
            }
        } else unreachable;
    }

    fn lessThan(_: void, lhs: Item, rhs: Item) bool {
        return lhs.compare(rhs) == .lt;
    }

    fn compareInt(a: anytype, b: @TypeOf(a)) CompareResult {
        return @intToEnum(CompareResult, std.math.sign(a - b) + 1);
    }

    fn compareList(a: []Item, b: []Item) CompareResult {
        const length = @min(a.len, b.len);
        var i: usize = 0;
        return while (i < length) : (i += 1) {
            const result = a[i].compare(b[i]);
            if (result != .eq) break result;
        } else compareInt(@intCast(isize, a.len), @intCast(isize, b.len));
    }
};

fn parseLine(allocator: std.mem.Allocator, line: []const u8) !Item {
    var result = std.ArrayListUnmanaged(Item){};
    var list_depth: usize = 0;
    var line_index: usize = 1;
    while (line_index < line.len - 1) {
        switch (line[line_index]) {
            '[' => {
                var list = &result;
                var depth: usize = 0;
                while (depth < list_depth) : (depth += 1) {
                    list = &list.items[list.items.len - 1].list;
                }
                try list.append(allocator, Item{ .list = .{} });
                list_depth += 1;
                line_index += 1;
            },
            ']' => {
                list_depth -= 1;
                line_index += 1;
            },
            '0'...'9' => {
                const slice = for (line[line_index..]) |c, i| {
                    switch (c) {
                        ',', ']' => break line[line_index .. line_index + i],
                        else => continue,
                    }
                } else unreachable;
                var list = &result;
                var depth: usize = 0;
                while (depth < list_depth) : (depth += 1) {
                    list = &list.items[list.items.len - 1].list;
                }
                try list.append(allocator, Item{ .integer = try std.fmt.parseInt(i8, slice, 10) });
                line_index += slice.len;
            },
            ',' => {
                line_index += 1;
            },
            else => unreachable,
        }
    }

    return Item{ .list = result };
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var sum: usize = 0;
    var packet_list = Item{ .list = .{} };
    var chunks = std.mem.split(u8, data, "\n\n");
    {
        var i: usize = 1;
        while (chunks.next()) |chunk| : (i += 1) {
            var line_iter = std.mem.tokenize(u8, chunk, "\n");
            const left_line = line_iter.next().?;
            const right_line = line_iter.next().?;

            const left = try parseLine(allocator, left_line);
            const right = try parseLine(allocator, right_line);

            if (left.compare(right) == .lt)
                sum += i;

            try packet_list.list.append(allocator, left);
            try packet_list.list.append(allocator, right);
        }
    }

    var divider_packet_1 = [1]Item{Item{ .integer = 2 }};
    var divider_packet_2 = [1]Item{Item{ .integer = 6 }};
    try packet_list.list.append(allocator, Item{ .list = .{ .items = divider_packet_1[0..] } });
    try packet_list.list.append(allocator, Item{ .list = .{ .items = divider_packet_2[0..] } });

    packet_list.sort();
    const decoder_key = packet_list.getDecoderKey();

    std.debug.print("The sum of the indices of correctly ordered pairs is {d}\n", .{sum});

    std.debug.print("The decoder key is {d}\n", .{decoder_key});
}
