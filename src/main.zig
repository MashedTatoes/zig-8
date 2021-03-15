const std = @import("std");
const Chip8 = @import("system/Chip8.zig").Chip8;
const fs = std.fs;
const Allocator = std.mem.Allocator;
pub fn readFile(path: []const u8, allocator: *Allocator) anyerror![]u8{
    
    var rom : []u8 = undefined;
    
    var file = try fs.openFileAbsolute(path, fs.File.OpenFlags{.read = true,.write=false});
    var size:u64 =  try file.getEndPos();
    rom = try allocator.alloc(u8,size);
    std.debug.print("\nProgram {s} size(bytes): {d} \n",.{path,size});


    defer file.close();
    const result = file.preadAll(rom,0);
    return rom;

}


pub fn main() anyerror!void {
    
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Enter program path:\n",.{});
    var buffer : [128]u8 = undefined;
    var inputSize = try stdin.read(&buffer);
    const line = std.mem.trimRight(u8,buffer[0..inputSize],"\r\n");
    var rom : []u8 = try readFile(line,std.heap.c_allocator);

    
    var device : Chip8 = try Chip8.init(); 
    try device.loadRom(rom);
    device.run(rom.len);
    
    device.deinit();
    
}


