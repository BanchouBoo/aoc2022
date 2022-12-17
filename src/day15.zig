const std = @import("std");

const data = @embedFile("data/day15.txt");

const Int = i64;
const Point = [2]Int;

const Pair = struct {
    sensor: Point,
    beacon: Point,
    distance: Int,

    pub fn sensorContainsPoint(self: Pair, point: Point) bool {
        return manhattanDistance(self.sensor, point) <= self.distance;
    }
};

fn manhattanDistance(a: Point, b: Point) Int {
    return (std.math.absInt(a[0] - b[0]) catch unreachable) +
        (std.math.absInt(a[1] - b[1]) catch unreachable);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const p1_row = 2000000;
    var pairs = std.ArrayListUnmanaged(Pair){};

    var min_x: Int = std.math.maxInt(Int);
    var max_x: Int = std.math.minInt(Int);

    var sensor_iterator = std.mem.tokenize(u8, data, "\n");
    while (sensor_iterator.next()) |sensor_line| {
        var point_iterator = std.mem.tokenize(u8, sensor_line, "Sensor atx=,y:clbi");

        const pair = value: {
            const sensor = Point{
                try std.fmt.parseInt(Int, point_iterator.next().?, 10),
                try std.fmt.parseInt(Int, point_iterator.next().?, 10),
            };
            const beacon = Point{
                try std.fmt.parseInt(Int, point_iterator.next().?, 10),
                try std.fmt.parseInt(Int, point_iterator.next().?, 10),
            };
            break :value Pair{
                .sensor = sensor,
                .beacon = beacon,
                .distance = manhattanDistance(sensor, beacon),
            };
        };

        try pairs.append(allocator, pair);

        if (pair.sensor[1] - pair.distance <= p1_row and pair.sensor[1] + pair.distance >= p1_row) {
            const distance_to_row = std.math.absInt(pair.sensor[1] - p1_row) catch unreachable;
            const scan_distance = pair.distance - distance_to_row;
            min_x = @min(min_x, (pair.sensor[0] - scan_distance));
            max_x = @max(max_x, (pair.sensor[0] + scan_distance));
        }
    }

    // part 1
    {
        const width = std.math.absCast(max_x - min_x) + 1;

        var available_spaces_in_row = try allocator.alloc(bool, width);
        std.mem.set(bool, available_spaces_in_row, false);
        for (pairs.items) |pair| {
            const distance_to_row = std.math.absInt(pair.sensor[1] - p1_row) catch unreachable;
            if (distance_to_row > pair.distance) continue;
            const scan_distance = pair.distance - distance_to_row;
            var x: Int = pair.sensor[0] - scan_distance;
            while (x <= pair.sensor[0] + scan_distance) : (x += 1) {
                const point = Point{ x, p1_row };
                if (!std.mem.eql(Int, &point, &pair.sensor) and
                    !std.mem.eql(Int, &point, &pair.beacon))
                {
                    available_spaces_in_row[@intCast(usize, x - min_x)] = true;
                }
            }
        }

        var available_spaces_count: usize = 0;
        for (available_spaces_in_row) |space|
            available_spaces_count += @boolToInt(space);

        std.debug.print(
            "The number of positions that cannot contain a beacon in row {d} is {d}\n",
            .{ p1_row, available_spaces_count },
        );
    }

    // part 2
    {
        const min_range = 0;
        const max_range = 4000000;

        var extended_search: Int = 1;
        const tuning_frequency = outer: while (true) : (extended_search += 1) {
            for (pairs.items) |pair| {
                const extended_distance = pair.distance + extended_search;

                const min_y = @max(min_range, pair.sensor[1] - extended_distance);
                const max_y = @min(max_range, pair.sensor[1] + extended_distance);

                var y: Int = min_y;
                while (y <= max_y) : (y += 1) {
                    const distance_to_row = std.math.absInt(pair.sensor[1] - y) catch unreachable;
                    const scan_distance = extended_distance - distance_to_row;
                    const points = [2]Point{
                        Point{ pair.sensor[0] - scan_distance, y },
                        Point{ pair.sensor[0] + scan_distance, y },
                    };

                    for (points) |point| {
                        if (point[0] < min_range or point[0] > max_range or
                            point[1] < min_range or point[1] > max_range)
                            continue;

                        const in_range_of_sensor = for (pairs.items) |p| {
                            if (p.sensorContainsPoint(point)) break true;
                        } else false;

                        if (!in_range_of_sensor)
                            break :outer (point[0] * 4000000) + point[1];
                    }
                }
            }
        };

        std.debug.print("The tuning frequency of the distress beacos is {d}\n", .{tuning_frequency});
    }
}
