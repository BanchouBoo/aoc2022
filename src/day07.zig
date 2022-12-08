const std = @import("std");

const data = @embedFile("data/day07.txt");

const Filesystem = struct {
    directories: std.StringHashMapUnmanaged(Directory) = .{},
};

const Directory = struct {
    file_size_sum: usize = 0,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var filesystem = Filesystem{};
    var current_path: []const u8 = "";

    var output = std.mem.tokenize(u8, data, "\n");
    while (output.next()) |line| {
        switch (line[0]) {
            '$' => {
                if (line[2] == 'c') {
                    const new_relative_path = line[5..];
                    const path = value: {
                        if (new_relative_path[0] == '.') {
                            var i: usize = current_path.len - 2;
                            while (current_path[i] != '/')
                                i -= 1;
                            break :value current_path[0 .. i + 1];
                        } else if (new_relative_path[0] == '/') {
                            break :value "/";
                        } else {
                            break :value try std.fmt.allocPrint(
                                allocator,
                                "{s}{s}/",
                                .{ current_path, new_relative_path },
                            );
                        }
                    };
                    current_path = path;

                    var result = try filesystem.directories.getOrPut(
                        allocator,
                        path,
                    );
                    if (!result.found_existing) {
                        result.value_ptr.* = Directory{};
                    }
                }
            },
            'd' => {},
            '0'...'9' => {
                var iter = std.mem.split(u8, line, " ");
                const size = try std.fmt.parseInt(usize, iter.next().?, 10);
                var path = current_path;
                while (filesystem.directories.getPtr(path)) |dir| {
                    dir.*.file_size_sum += size;
                    if (path.len == 1) break;
                    path = new_path: {
                        var i: usize = path.len - 2;
                        while (path[i] != '/')
                            i -= 1;
                        break :new_path path[0 .. i + 1];
                    };
                }
            },
            else => unreachable,
        }
    }

    var sum_less_or_equal_100000: usize = 0;
    const used_space = filesystem.directories.get("/").?.file_size_sum;
    const unused_space = 70000000 - used_space;
    const space_to_free = 30000000 - unused_space;
    var smallest_freeable_dir: usize = 70000000;

    var dir_iter = filesystem.directories.valueIterator();
    while (dir_iter.next()) |dir| {
        if (dir.file_size_sum <= 100000) {
            sum_less_or_equal_100000 += dir.file_size_sum;
        }

        if (dir.file_size_sum >= space_to_free and
            dir.file_size_sum < smallest_freeable_dir)
        {
            smallest_freeable_dir = dir.file_size_sum;
        }
    }

    std.debug.print("The sum of directories with a size of 100000 or less is {d}\n", .{sum_less_or_equal_100000});
    std.debug.print("The smallest directory that can be freed for the update is {d}\n", .{smallest_freeable_dir});
}
