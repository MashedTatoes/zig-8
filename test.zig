const std = @import("std");
const c8 = @import("src/system/Chip8.zig");

test "Chip8 Memory allocated"{
    const device : c8.Chip8 = try c8.Chip8.init();
    std.testing.expectEqual(device.memory.len, 4096);
    std.testing.expectEqual(device.V.len, 16);
    std.testing.expectEqual(device.screen.len, (32*64));
}