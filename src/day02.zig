const std = @import("std");

const data = @embedFile("data/day02.txt");

const Result = enum(usize) {
    lose = 1,
    draw,
    win,

    pub fn value(self: Result) usize {
        return @enumToInt(self);
    }

    pub fn fromChar(char: u8) !Result {
        return switch (char) {
            'X' => .lose,
            'Y' => .draw,
            'Z' => .win,
            else => error.UnexpectedInput,
        };
    }
};

const Option = enum(usize) {
    rock = 1,
    paper,
    scissors,

    pub fn fromChar(char: u8) !Option {
        return switch (char) {
            'A', 'X' => .rock,
            'B', 'Y' => .paper,
            'C', 'Z' => .scissors,
            else => error.UnexpectedInput,
        };
    }

    pub fn fromResult(result: Result, opponent: Option) Option {
        return @intToEnum(Option, 1 + ((opponent.score() + result.value()) % 3));
    }

    pub fn score(self: Option) usize {
        return @enumToInt(self);
    }

    pub fn match(a: Option, b: Option) usize {
        return switch (@intCast(isize, a.score()) - @intCast(isize, b.score())) {
            -1, 2 => 0, // lose
            0 => 3, // draw
            1, -2 => 6, // win
            else => unreachable,
        };
    }
};

pub fn main() !void {
    var matches = std.mem.tokenize(u8, data, "\n");
    var p1_score: usize = 0;
    var p2_score: usize = 0;
    while (matches.next()) |match| {
        const opponent = try Option.fromChar(match[0]);
        // part 1
        {
            const me = try Option.fromChar(match[2]);
            p1_score += me.score() + me.match(opponent);
        }

        // part 2
        {
            const result = try Result.fromChar(match[2]);
            const me = Option.fromResult(result, opponent);
            p2_score += me.score() + me.match(opponent);
        }
    }
    std.log.info("Final score for part 1 is {d}", .{p1_score});
    std.log.info("Final score for part 2 is {d}", .{p2_score});
}
