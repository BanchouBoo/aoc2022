const std = @import("std");

const Object = enum { air, rock, sand };

const data = @embedFile("data/day14.txt");

const Path = struct {
    points: [][2]usize,
};

const Map = struct {
    storage: std.AutoHashMapUnmanaged([2]usize, Object) = .{},
    horizontal_bounds: [2]usize = .{ std.math.maxInt(usize), 0 },
    height: usize,

    pub fn occupied(self: Map, position: [2]usize) bool {
        return (position[1] == self.height - 1) or self.storage.contains(position);
    }

    pub fn get(self: Map, position: [2]usize) Object {
        return if (self.storage.get(position)) |object|
            object
        else if (position[1] == self.height - 1)
            .rock
        else
            .air;
    }

    pub fn add(
        self: *Map,
        allocator: std.mem.Allocator,
        position: [2]usize,
        value: Object,
    ) !void {
        self.horizontal_bounds[0] = @min(self.horizontal_bounds[0], position[0]);
        self.horizontal_bounds[1] = @max(self.horizontal_bounds[1], position[0]);
        try self.storage.put(allocator, position, value);
    }

    pub fn draw(self: Map) void {
        var y: usize = 0;
        while (y < self.height) : (y += 1) {
            var x: usize = self.horizontal_bounds[0];
            while (x < self.horizontal_bounds[1]) : (x += 1) {
                switch (self.get(.{ x, y })) {
                    .air => std.debug.print(" ", .{}),
                    .rock => std.debug.print("#", .{}),
                    .sand => std.debug.print(".", .{}),
                }
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var max_y: usize = 0;

    var paths = std.ArrayListUnmanaged(Path){};

    var path_iterator = std.mem.tokenize(u8, data, "\n");
    while (path_iterator.next()) |path| {
        var point_iterator = std.mem.tokenize(u8, path, " ->");
        var points = std.ArrayListUnmanaged([2]usize){};
        while (point_iterator.next()) |point| {
            var coordinate_iterator = std.mem.split(u8, point, ",");
            const x = try std.fmt.parseInt(usize, coordinate_iterator.next().?, 10);
            const y = try std.fmt.parseInt(usize, coordinate_iterator.next().?, 10);
            try points.append(allocator, [2]usize{ x, y });
            max_y = @max(max_y, y);
        }
        points.shrinkAndFree(allocator, points.items.len);
        try paths.append(allocator, Path{ .points = points.items });
    }

    // extra space on the bottom for part 2
    var map = Map{ .height = max_y + 2 + 1 };

    // fill out paths with rock
    for (paths.items) |path| {
        var i: usize = 0;
        while (i < path.points.len - 1) : (i += 1) {
            var point_a = path.points[i];
            var point_b = path.points[i + 1];
            const start_x = @min(point_a[0], point_b[0]);
            const end_x = @max(point_a[0], point_b[0]);
            const start_y = @min(point_a[1], point_b[1]);
            const end_y = @max(point_a[1], point_b[1]);

            var y: usize = start_y;
            while (y <= end_y) : (y += 1) {
                var x: usize = start_x;
                while (x <= end_x) : (x += 1) {
                    try map.add(allocator, .{ x, y }, .rock);
                }
            }
        }
    }

    var p1_rested_sand_count: usize = 0;
    var p2_rested_sand_count: usize = 0;
    while (!map.occupied(.{ 500, 0 })) : (p2_rested_sand_count += 1) {
        var sand = [2]usize{ 500, 0 };
        while (true) {
            // check straight down
            if (!map.occupied(.{ sand[0], sand[1] + 1 })) {
                sand[1] += 1;
            }
            // check down-left
            else if (!map.occupied(.{ sand[0] - 1, sand[1] + 1 })) {
                sand[0] -= 1;
                sand[1] += 1;
            }
            // check down-right
            else if (!map.occupied(.{ sand[0] + 1, sand[1] + 1 })) {
                sand[0] += 1;
                sand[1] += 1;
            }
            // sand at rest, add to the map and start the next grain
            else {
                try map.add(allocator, sand, .sand);
                break;
            }

            if (sand[1] == map.height - 3 and p1_rested_sand_count == 0)
                p1_rested_sand_count = p2_rested_sand_count;
        }
    }

    std.debug.print("The amount of sand at rest in part 1 is {d}\n", .{p1_rested_sand_count});
    std.debug.print("The amount of sand at rest in part 2 is {d}\n", .{p2_rested_sand_count});
}
