const std = @import("std");

const data = @embedFile("data/day12.txt");
const width = value: {
    break :value std.mem.sliceTo(data, '\n').len;
};
const height = value: {
    @setEvalBranchQuota(12000);
    break :value std.mem.count(u8, data, "\n");
};

const Queue = std.PriorityQueue(*Node, void, distanceFn);
const Node = struct {
    position: [2]usize,
    value: u8,
    distance: usize,
    visited: bool,
};

fn distanceFn(_: void, a: *Node, b: *Node) std.math.Order {
    return std.math.order(a.distance, b.distance);
}

fn index(x: usize, y: usize) usize {
    return y * width + x;
}

fn fromIndex(i: usize) [2]usize {
    const x = i % width;
    const y = (i - x) / width;
    return .{ x, y };
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var start_position: [2]usize = undefined;
    var end_position: [2]usize = undefined;

    var p1_nodes: [width * height]Node = undefined;
    var p1_queue = Queue.init(allocator, {});
    var p2_nodes: [width * height]Node = undefined;
    var p2_queue = Queue.init(allocator, {});
    {
        var i: usize = 0;
        for (data) |c| {
            switch (c) {
                '\n' => continue,
                'S' => {
                    start_position = fromIndex(i);
                    p1_nodes[i].value = 'a';
                    p1_nodes[i].distance = 0;
                    p1_nodes[i].position = start_position;
                    p1_nodes[i].visited = true;

                    p2_nodes[i] = p1_nodes[i];
                },
                'E' => {
                    end_position = fromIndex(i);
                    p1_nodes[i].value = 'z';
                    p1_nodes[i].distance = std.math.maxInt(usize);
                    p1_nodes[i].position = end_position;
                    p1_nodes[i].visited = false;

                    p2_nodes[i] = p1_nodes[i];
                },
                'a' => {
                    p1_nodes[i].value = c;
                    p1_nodes[i].distance = std.math.maxInt(usize);
                    p1_nodes[i].position = fromIndex(i);
                    p1_nodes[i].visited = false;

                    p2_nodes[i] = p1_nodes[i];
                    p2_nodes[i].distance = 0;
                },
                else => {
                    p1_nodes[i].value = c;
                    p1_nodes[i].distance = std.math.maxInt(usize);
                    p1_nodes[i].position = fromIndex(i);
                    p1_nodes[i].visited = false;

                    p2_nodes[i] = p1_nodes[i];
                },
            }
            try p1_queue.add(&p1_nodes[i]);
            try p2_queue.add(&p2_nodes[i]);
            i += 1;
        }
    }

    var p1_distance: usize = undefined;
    var p2_distance: usize = undefined;
    inline for (.{ 1, 2 }) |part| {
        var queue: *Queue = undefined;
        var nodes: *[width * height]Node = undefined;
        var distance: *usize = undefined;
        if (part == 1) {
            queue = &p1_queue;
            nodes = &p1_nodes;
            distance = &p1_distance;
        } else {
            queue = &p2_queue;
            nodes = &p2_nodes;
            distance = &p2_distance;
        }
        distance.* = while (true) {
            const current = queue.remove();
            if (current.position[0] == end_position[0] and
                current.position[1] == end_position[1])
                break current.distance;

            current.visited = true;

            const neighbors = value: {
                var result: [4][2]usize = undefined;
                var i: usize = 0;

                const position = current.position;

                // left
                if (position[0] > 0) {
                    result[i] = [2]usize{ position[0] - 1, position[1] };
                    i += 1;
                }

                // up
                if (position[1] > 0) {
                    result[i] = [2]usize{ position[0], position[1] - 1 };
                    i += 1;
                }

                // right
                if (position[0] < width - 1) {
                    result[i] = [2]usize{ position[0] + 1, position[1] };
                    i += 1;
                }

                // down
                if (position[1] < height - 1) {
                    result[i] = [2]usize{ position[0], position[1] + 1 };
                    i += 1;
                }

                break :value result[0..i];
            };

            for (neighbors) |n| {
                const node = &nodes[index(n[0], n[1])];
                if (!node.visited) {
                    const too_high = @as(usize, @boolToInt(current.value < node.value - 1));
                    const cost = @max(1, std.math.maxInt(usize) * too_high);
                    const i = for (queue.items) |item, i| {
                        if (item == node)
                            break i;
                    } else unreachable;
                    _ = queue.removeIndex(i);
                    node.distance = @min(node.distance, current.distance +| cost);
                    try queue.add(node);
                }
            }
        } else unreachable;
    }

    std.debug.print(
        "The shortest distance to the target position from the start position is {d}\n",
        .{p1_distance},
    );

    std.debug.print(
        "The shortest distance to the target position from the any 'a' is {d}\n",
        .{p2_distance},
    );
}
