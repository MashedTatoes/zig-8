const std = @import("std");
const c8 = @import("src/system/Chip8.zig");

test "Chip8 Memory allocated"{
    const device : c8.Chip8 = try c8.Chip8.init();
    std.testing.expectEqual(device.memory.len, 4096);
    std.testing.expectEqual(device.V.len, 16);
    std.testing.expectEqual(device.screen.len, (32*64));
}

test "Chip8 program read"{
    var device : c8.Chip8 = try c8.Chip8.init();
    try device.loadProgram("C:\\Users\\CoopWinter2021\\Documents\\zig-8\\programs\\Airplane.ch8");
    std.testing.expectEqual(device.memory[0x200],0x6A);
}