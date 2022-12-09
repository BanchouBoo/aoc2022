const std = @import("std");
const math = std.math;

const Vec2 = packed struct {
    x: i16,
    y: i16,

    pub fn move(self: *Vec2, direction: u8, distance: i16) void {
        switch (direction) {
            'L' => self.*.x -= distance,
            'R' => self.*.x += distance,
            'D' => self.*.y -= distance,
            'U' => self.*.y += distance,
            else => unreachable,
        }
    }

    pub fn max_axis_distance(a: Vec2, b: Vec2) i16 {
        return math.max(
            math.absInt(a.x - b.x) catch unreachable,
            math.absInt(a.y - b.y) catch unreachable,
        );
    }

    pub fn direction_to(a: Vec2, b: Vec2) Vec2 {
        return Vec2{
            .x = math.sign(b.x - a.x),
            .y = math.sign(b.y - a.y),
        };
    }

    pub fn add(a: Vec2, b: Vec2) Vec2 {
        return Vec2{
            .x = a.x + b.x,
            .y = a.y + b.y,
        };
    }

    pub fn toInt(self: Vec2) u32 {
        return @bitCast(u32, self);
    }
};

const data = @embedFile("data/day09.txt");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var rope = [1]Vec2{Vec2{ .x = 0, .y = 0 }} ** 10;

    var p1_visited_positions = std.AutoHashMapUnmanaged(u32, void){};
    try p1_visited_positions.put(allocator, rope[0].toInt(), {});

    var p2_visited_positions = std.AutoHashMapUnmanaged(u32, void){};
    try p2_visited_positions.put(allocator, rope[0].toInt(), {});

    var actions = std.mem.tokenize(u8, data, "\n");
    while (actions.next()) |action| {
        const direction = action[0];
        var distance = try std.fmt.parseInt(i16, action[2..], 10);
        while (distance > 0) : (distance -= 1) {
            rope[0].move(direction, 1);

            {
                var i: usize = 1;
                while (i < rope.len) : (i += 1) {
                    const head = rope[i - 1];
                    var tail = &rope[i];
                    while (tail.max_axis_distance(head) > 1) {
                        tail.* = tail.add(tail.direction_to(head));

                        if (i == 1)
                            try p1_visited_positions.put(allocator, tail.toInt(), {})
                        else if (i == rope.len - 1)
                            try p2_visited_positions.put(allocator, tail.toInt(), {});
                    }
                }
            }
        }
    }

    std.debug.print(
        "The amount of unique positions visited by the tail in part 1 is {d}\n",
        .{p1_visited_positions.size},
    );
    std.debug.print(
        "The amount of unique positions visited by the tail in part 2 is {d}\n",
        .{p2_visited_positions.size},
    );
}
