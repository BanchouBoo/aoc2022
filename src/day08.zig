const std = @import("std");

const Direction = enum { left, right, up, down };

const data = @embedFile("data/day08.txt");
const width = value: {
    break :value std.mem.sliceTo(data, '\n').len;
};
const height = value: {
    @setEvalBranchQuota(100000);
    break :value std.mem.count(u8, data, "\n");
};

fn index(x: usize, y: usize) usize {
    return y * width + x;
}

fn getScenicScore(direction: Direction, x: usize, y: usize) usize {
    const tree = data[index(x, y) + y];

    return switch (direction) {
        .left => value: {
            var score: usize = 0;
            var col = x;
            while (col > 0) : (col -= 1) {
                const t = data[index(col - 1, y) + y];
                score += 1;
                if (t >= tree)
                    break;
            }
            break :value score;
        },

        .right => value: {
            var score: usize = 0;
            var col = x + 1;
            while (col < width) : (col += 1) {
                const t = data[index(col, y) + y];
                score += 1;
                if (t >= tree)
                    break;
            }
            break :value score;
        },

        .up => value: {
            var score: usize = 0;
            var row = y;
            while (row > 0) : (row -= 1) {
                const t = data[index(x, row - 1) + (row - 1)];
                score += 1;
                if (t >= tree)
                    break;
            }
            break :value score;
        },

        .down => value: {
            var score: usize = 0;
            var row = y + 1;
            while (row < height) : (row += 1) {
                const t = data[index(x, row) + row];
                score += 1;
                if (t >= tree)
                    break;
            }
            break :value score;
        },
    };
}

pub fn main() !void {
    var tree_visibility = comptime value: {
        @setEvalBranchQuota(100000);
        var result: [width * height]bool = undefined;
        var y: u8 = 0;
        while (y < height) : (y += 1) {
            var x: u8 = 0;
            while (x < width) : (x += 1) {
                if (y == 0 or x == 0 or y == height - 1 or x == width - 1)
                    result[index(x, y)] = true
                else
                    result[index(x, y)] = false;
            }
        }

        break :value result;
    };
    var scenic_scores = [1][4]usize{[4]usize{ 0, 0, 0, 0 }} ** (width * height);

    {
        var y: u8 = 1;
        while (y < height - 1) : (y += 1) {
            var left_max = data[index(0, y) + y];
            var right_max = data[index(width, y) + y];
            var x: u8 = 1;
            while (x < width - 1) : (x += 1) {
                const i_from_left = index(x, y);
                const left_tree = data[i_from_left + y];
                if (left_max >= left_tree) {
                    tree_visibility[i_from_left] = false or tree_visibility[i_from_left];
                } else {
                    left_max = left_tree;
                    tree_visibility[i_from_left] = true;
                }
                scenic_scores[i_from_left][0] = getScenicScore(.left, x, y);

                const i_from_right = index(width - x, y);
                const right_tree = data[i_from_right + y];
                if (right_max >= right_tree) {
                    tree_visibility[i_from_right] = false or tree_visibility[i_from_right];
                } else {
                    right_max = right_tree;
                    tree_visibility[i_from_right] = true;
                }
                scenic_scores[i_from_right][1] = getScenicScore(.right, width - x, y);
            }
        }
    }

    {
        var x: u8 = 1;
        while (x < width - 1) : (x += 1) {
            var top_max = data[index(x, 0)];
            var bottom_max = data[index(x, height - 1) + (height - 1)];
            var y: u8 = 1;
            while (y < height) : (y += 1) {
                const i_from_top = index(x, y);
                const top_tree = data[i_from_top + y];
                if (top_max >= top_tree) {
                    tree_visibility[i_from_top] = false or tree_visibility[i_from_top];
                } else {
                    top_max = top_tree;
                    tree_visibility[i_from_top] = true;
                }
                scenic_scores[i_from_top][2] = getScenicScore(.up, x, y);

                const i_from_bottom = index(x, height - y);
                const bottom_tree = data[i_from_bottom + (height - y)];
                if (bottom_max >= bottom_tree) {
                    tree_visibility[i_from_bottom] = false or tree_visibility[i_from_bottom];
                } else {
                    bottom_max = bottom_tree;
                    tree_visibility[i_from_bottom] = true;
                }
                scenic_scores[i_from_bottom][3] = getScenicScore(.down, x, height - y);
            }
        }
    }

    var visible_tree_count: u16 = 0;
    var max_scenic_score: usize = 0;
    {
        var y: u8 = 0;
        while (y < height) : (y += 1) {
            var x: u8 = 0;
            while (x < width) : (x += 1) {
                const i = index(x, y);
                visible_tree_count += @boolToInt(tree_visibility[i]);
                const tree_scores = scenic_scores[i];
                const score = tree_scores[0] * tree_scores[1] * tree_scores[2] * tree_scores[3];
                max_scenic_score = std.math.max(score, max_scenic_score);
            }
        }
    }

    std.debug.print("The amount of trees visible from the outside is {d}\n", .{visible_tree_count});
    std.debug.print("The highest scenic score is {d}\n", .{max_scenic_score});
}
