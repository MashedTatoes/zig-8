const std = @import("std");
const Chip8 = @import("system/Chip8.zig").Chip8;



pub fn main() anyerror!void {
    var device : Chip8 = try Chip8.init(); 
    
   // std.log.info("{d}", .{device.memory[0]});
    const programSize = try device.loadProgram("C:\\Users\\CoopWinter2021\\Documents\\zig-8\\programs\\Airplane.ch8");
    device.run(programSize);
    //try device.instructionSet.set[0].func(&device, 0x00E0);
    device.deinit();
    
}


