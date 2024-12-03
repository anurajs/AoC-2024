const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn isSafe(report: []isize) bool {
    const ascending: bool = if (report[0] < report[1]) true else false;
    for (1..report.len) |i| {
        if (ascending and (report[i] - report[i - 1] > 3 or report[i] - report[i - 1] < 1)) {
            return false;
        } else if (!ascending and (report[i - 1] - report[i] > 3 or report[i - 1] - report[i] < 1)) {
            return false;
        }
    }
    return true;
}

pub fn isSafeDampened(report: []isize) !bool {
    if (isSafe(report[1..])) return true;
    const ascending: bool = if (report[0] < report[1]) true else false;
    var damper_slice = std.ArrayList(isize).init(allocator);
    defer damper_slice.deinit();
    for (1..report.len) |i| {
        var problem = false;
        if (ascending and (report[i] - report[i - 1] > 3 or report[i] - report[i - 1] < 1)) {
            problem = true;
        } else if (!ascending and (report[i - 1] - report[i] > 3 or report[i - 1] - report[i] < 1)) {
            problem = true;
        }
        if (problem) {
            try damper_slice.appendSlice(report[0..i]);
            try damper_slice.appendSlice(report[i + 1 ..]);
            if (isSafe(damper_slice.items)) return true;
            damper_slice.clearRetainingCapacity();
            try damper_slice.appendSlice(report[0 .. i - 1]);
            try damper_slice.appendSlice(report[i..]);
            if (isSafe(damper_slice.items)) return true else return false;
        }
    }
    return true;
}
pub fn solveDayTwo() !void {
    var file = try std.fs.cwd().openFile("./problems/day2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buffer: [1024]u8 = undefined;
    var sum: usize = 0;
    var sum2: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var split_iterator = std.mem.splitScalar(u8, line, ' ');
        var report = std.ArrayList(isize).init(allocator);
        defer report.deinit();
        while (split_iterator.next()) |number| {
            const number_val: isize = try std.fmt.parseInt(isize, number, 10);
            try report.append(number_val);
        }
        sum += if (isSafe(report.items)) 1 else 0;
        sum2 += if (try isSafeDampened(report.items)) 1 else 0;
    }

    std.debug.print("The solution to part one is: {}\n", .{sum});
    std.debug.print("The solution to part two is: {}\n", .{sum2});
}
