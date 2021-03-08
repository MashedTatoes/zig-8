const std = @import("std");
const fs = std.fs;
const Allocator = std.mem.Allocator;
pub const Chip8Error = error{
    Chip8InitError,
    ProgramOpenError
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
    allocator : *Allocator,

    pub fn init() Chip8Error!Chip8 {

        var heap :[16 + 4096 + (64*32)] u8 = undefined;
        var allocator = &std.heap.FixedBufferAllocator.init(&heap).allocator;
        
        errdefer{
            std.debug.print("Error initialzing chip8\n",.{});
            allocator.free(&heap);
        }

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
            .screen = screen,
            .allocator = allocator
        };

    }

    pub fn loadProgram(self:*Chip8,path: []const u8 ) Chip8Error!void{
        
        
        var file =  fs.openFileAbsolute(path, fs.File.OpenFlags{.read = true,.write=false}) catch |err|{
            return Chip8Error.ProgramOpenError;
        };
        defer file.close();
        const result = file.preadAll(self.memory[0x200..],0) catch |err|{
            return Chip8Error.ProgramOpenError;
        };
        std.debug.print("{d}",.{result});

    }


};