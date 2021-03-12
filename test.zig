const std = @import("std");
const c8 = @import("src/system/Chip8.zig");

test "Chip8 Memory allocated"{
    const device : c8.Chip8 = try c8.Chip8.init();
    std.testing.expectEqual(device.memory.len, 4096);
    std.testing.expectEqual(device.V.len, 16);
    std.testing.expectEqual(device.screen.len, (32*64));
    std.testing.expectEqual(device.stack.len,16);
}

test "Chip8 program read"{
    var device : c8.Chip8 = try c8.Chip8.init();
    
    const result = try device.loadProgram("C:\\Users\\CoopWinter2021\\Documents\\zig-8\\programs\\Airplane.ch8");
    std.testing.expectEqual(device.memory[0x200],0x6A);
    std.testing.expectEqual(result,356);
}

test "Chip8 control flow "{
    var device : c8.Chip8 = try c8.Chip8.init();
    
    std.debug.print("\n",.{});

    //JMP 0x200
    try device.executeInstruction(0x1200);

    std.testing.expectEqual(@as(u16,0x0200),device.PC);

    //Call 0x300
    try device.executeInstruction(0x2300);
    std.testing.expectEqual(@as(u16,0x0300),device.PC);
    std.testing.expectEqual(@as(u16,0x0200),try device.stack.peek());


    //Ret
    try device.executeInstruction(0x00EE);
    std.testing.expectEqual(@as(u16,0x0200),device.PC);
    

}

test "Chip8 logic flow"{
    var device : c8.Chip8 = try c8.Chip8.init();
    
    std.debug.print("\n",.{});
    //Load V[0], 1
    try device.executeInstruction(0x6001);
    std.testing.expectEqual(@as(u16,1),device.V[0]);

    // Skip next instruction if V[0] = 1
    try device.executeInstruction(0x3001);
    std.testing.expectEqual(@as(u16,0x0202), device.PC);

    //Skip next instruction if V[0] != 1
    try device.executeInstruction(0x4001);
    std.testing.expectEqual(@as(u16,0x202),device.PC);

    //Load V[1], 2
    try device.executeInstruction(0x6102);
    //Set V[0] = V[1]
    try device.executeInstruction(0x8010);
    //Skip next instruction if V[0] = V[1]
    try device.executeInstruction(0x5010);
    std.testing.expectEqual(@as(u16,0x204),device.PC);

}

test "Chip8 Register operations"{
    var device : c8.Chip8 = try c8.Chip8.init();
    
    std.debug.print("\n",.{});
    //Load V[1], 1
    try device.executeInstruction(0x6101);
    //Set V[0] = V[0] OR V[1]
    try device.executeInstruction(0x8011);
    std.testing.expectEqual(@as(u16,1),device.V[0]);
    //Set V[0] = V[0] AND V[1]
    try device.executeInstruction(0x8012);
    std.testing.expectEqual(@as(u16,1),device.V[0]);

}