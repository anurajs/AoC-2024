const std = @import("std");
const Re = @import("mvzr");
const Captures = @import("regex").Captures;
const allocator = std.heap.page_allocator;

const Mult = struct {
    left: isize,
    right: isize,

    pub fn multiply(self: Mult) isize {
        return self.left * self.right;
    }
};

pub fn solveDayThree() !void {
    var file = try std.fs.cwd().openFile("./problems/day3.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buffer: [1024 * 1024]u8 = undefined;
    var input = std.ArrayList(u8).init(allocator);
    defer input.deinit();
    while (try in_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        try input.appendSlice(line);
    }
    var mul_re = Re.compile("mul\\((\\d{1,3}),(\\d{1,3})\\)").?;
    var current_index: usize = 0;
    var sum: isize = 0;
    var sum2: isize = 0;
    var enabled: bool = true;

    var iterator = mul_re.iterator(input.items);
    while (iterator.next()) |capture| {
        var next_do = std.mem.indexOf(u8, input.items[current_index..], "do()") orelse 2147483647;
        next_do += current_index;
        var next_dont = std.mem.indexOf(u8, input.items[current_index..], "don't()") orelse 2147483647;
        next_dont += current_index;
        const next_mult: usize = capture.start;
        if (next_do < next_mult and next_mult < next_dont) {
            enabled = true;
        } else if (next_dont < next_mult and next_mult < next_do) {
            enabled = false;
        }
        var mul_iter = std.mem.splitScalar(u8, capture.slice[4 .. capture.slice.len - 1], ',');
        const val = Mult{
            .left = try std.fmt.parseInt(isize, mul_iter.next().?, 10),
            .right = try std.fmt.parseInt(isize, mul_iter.next().?, 10),
        };
        sum += val.multiply();
        sum2 += if (enabled) val.multiply() else 0;
        current_index = capture.end;
    }

    std.debug.print("Answer to part 1 is: {}\n", .{sum});
    std.debug.print("Answer to part 2 is: {}", .{sum2});
}
