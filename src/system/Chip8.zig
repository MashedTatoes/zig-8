const std = @import("std");
const Allocator = std.mem.Allocator;
pub const Chip8Error = error{
    Chip8InitError
};


pub const Chip8 = struct{
    V: []u8,
    I: u16 = 0,
    SP: u16 = 0xFA0,
    PC: u16 = 0x200,
    delay: u8 = 0,
    sound: u8 = 0,
    memory: []u8,
    screen: []u8,
    key: u8 = 0,

    pub fn init() Chip8Error!Chip8 {

        var heap :[16 + 4096 + (64*32)] u8 = undefined;
        const allocator = &std.heap.FixedBufferAllocator.init(&heap).allocator;
        
        var register = allocator.alloc(u8, 16) catch|err|{

            return Chip8Error.Chip8InitError;
        };
        var mem = allocator.alloc(u8, 4096) catch|err|{
            return Chip8Error.Chip8InitError;
        };
        var screen = allocator.alloc(u8, 64*32) catch|err|{
            return Chip8Error.Chip8InitError;
        };
        


        return Chip8{
            .V = register,
            .memory = mem,
            .screen = screen
        };

    }


};