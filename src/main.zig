const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
pub fn main() !void {
    try day1.solveDayOne();
    // try day2.solveDayTwo();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
