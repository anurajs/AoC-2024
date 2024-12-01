const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const Pair = struct {
    left: isize,
    right: isize,

    pub fn findDifference(self: Pair) isize {
        if (self.left > self.right) {
            return self.left - self.right;
        }
        return self.right - self.left;
    }
};

pub fn solveDayOne() !void {
    var file = try std.fs.cwd().openFile("./problems/day1.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var line_count: usize = 0;
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |_| {
        line_count += 1;
    }

    try file.seekTo(0);

    const allocator = gpa.allocator();
    var left = try allocator.alloc(isize, line_count);
    var right = try allocator.alloc(isize, line_count);
    var pairs = try allocator.alloc(Pair, line_count);
    defer allocator.free(left);
    defer allocator.free(right);
    defer allocator.free(pairs);
    var i: usize = 0;
    var left_map = std.AutoHashMap(isize, isize).init(allocator);
    var right_map = std.AutoHashMap(isize, isize).init(allocator);
    defer left_map.deinit();
    defer right_map.deinit();
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (i += 1) {
        var splits = std.mem.split(u8, line, "   ");
        const left_str = splits.next().?;
        const right_str = splits.next().?;

        const left_val = try std.fmt.parseInt(isize, left_str, 0);
        const right_val = try std.fmt.parseInt(isize, right_str, 0);
        left[i] = left_val;
        right[i] = right_val;
        const left_entry = try left_map.getOrPut(left_val);
        const right_entry = try right_map.getOrPut(right_val);
        if (!left_entry.found_existing) {
            left_entry.value_ptr.* = 0;
        }
        if (!right_entry.found_existing) {
            right_entry.value_ptr.* = 0;
        }
        left_entry.value_ptr.* += 1;
        right_entry.value_ptr.* += 1;
    }
    std.mem.sort(isize, left, {}, comptime std.sort.asc(isize));
    std.mem.sort(isize, right, {}, comptime std.sort.asc(isize));
    var sum: isize = 0;
    for (0..left.len) |y| {
        pairs[y] = Pair{ .left = left[y], .right = right[y] };
        const difference = pairs[y].findDifference();
        sum += difference;
    }
    std.debug.print("total difference: {d}\n", .{sum});

    sum = 0;
    var iter = left_map.keyIterator();
    while (iter.next()) |left_val| {
        const add = left_map.get(left_val.*).? * left_val.* * (right_map.get(left_val.*) orelse 0);
        sum += add;
    }
    std.debug.print("sim score: {d}\n", .{sum});
}
