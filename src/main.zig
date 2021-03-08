const std = @import("std");
const c8 = @import("system/Chip8.zig");
pub fn main() anyerror!void {
    const device : c8.Chip8 = try c8.Chip8.init();

    std.log.info("{d}", .{device.memory[0]});
}
