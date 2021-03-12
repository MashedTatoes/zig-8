const std = @import("std");
const Stack = @import("Stack.zig").Stack;
const fs = std.fs;
const Allocator = std.mem.Allocator;
pub const Chip8Error = error{
    Chip8InitError,
    ProgramOpenError,
    ProgramTooLarge,
    CouldNotFindProgram
};


pub const Chip8 = struct{
    V: []u16,
    I: u16 = 0,
    SP: u16 = 0,
    PC: u16 = 0x200,
    delay: u8 = 0,
    sound: u8 = 0,
    memory: []u8,
    screen: []u8,
    stack: Stack,
    key: u8 = 0,
    allocator : *Allocator,
    instructionSet : InstructionSet,

    pub fn init() Chip8Error!Chip8 {

        var heap :[32 + 4096 + (64*32) + 32] u8 = undefined;
        
        const allocator = &std.heap.FixedBufferAllocator.init(&heap).allocator;
        

        errdefer{
            std.debug.print("Error initialzing chip8\n",.{});
            allocator.free(&heap);
        }

        var register = allocator.alloc(u16, 16) catch|err|{

            return Chip8Error.Chip8InitError;
        };
        var mem = allocator.alloc(u8, 4096) catch|err|{
            return Chip8Error.Chip8InitError;
        };
        var screen = allocator.alloc(u8, 64*32) catch|err|{
            return Chip8Error.Chip8InitError;
        };
        
       var stack : Stack = Stack.init(16) catch |err|{
           return Chip8Error.Chip8InitError;
        };
        
        for (register) |v, i|{
            register[i] = 0;
        }
        
        
        var device = Chip8{
            .V = register,
            .memory = mem,
            .screen = screen,
            .allocator = allocator,
            .instructionSet = InstructionSet.init(),
            .stack = stack
        };

       try device.fillInstructionSet();

        return  device;

    }

    

    pub fn loadProgram(self:*Chip8,path: []const u8 ) Chip8Error!u64{
        
        
        var file =  fs.openFileAbsolute(path, fs.File.OpenFlags{.read = true,.write=false}) catch |err|{
            return Chip8Error.ProgramOpenError;
        };
        var size:u64 =  file.getEndPos() catch |err| {
            return Chip8Error.ProgramOpenError;
        };
        std.debug.print("{d}",.{size});

        if(size > 0xDFF){
            return Chip8Error.ProgramTooLarge;
        }

        defer file.close();
        const result = file.preadAll(self.memory[0x200..],0) catch |err|{
            return Chip8Error.ProgramOpenError;
        };
        return size;

    }

    fn fillInstructionSet(self: *Chip8) Chip8Error!void{
        self.instructionSet.set[0] = Operation { .func = sysInstruction};
        self.instructionSet.set[1] = Operation { .func = jump};
        self.instructionSet.set[2] = Operation { .func = call};
        self.instructionSet.set[3] = Operation{.func = skipEqual};
        self.instructionSet.set[4] = Operation{.func = skipNotEqual};
        self.instructionSet.set[5] = Operation{.func = skipEqualReg};
        self.instructionSet.set[6] = Operation{.func = load};
        self.instructionSet.set[7] = Operation{.func = addReg};
        self.instructionSet.set[8] = Operation{.func = bitRegOperations};

    }

    fn sysInstruction(self: *Chip8,data : u16) InstructionError!void{
        const lowerByte = data & 0x00FF;
        
        try switch(data){
            0x00E0 => clear(),
            0x00EE => ret(self),

            else => return InstructionError.NotImplemented,
        };
        

    }

    pub fn executeInstruction(self: *Chip8,instr : u16) InstructionError!void{
        const idx = ((instr & 0xF000) >> 8) >> 4;

        try self.instructionSet.set[idx].func(self,instr);
        

    }

    fn loadIntoRegister(self: *Chip8, x: u16, val: u16) void{
        self.V[x] = val;

    }



    fn clear() InstructionError!void{
        std.debug.print("Clear",.{});
    }

    fn ret(self: *Chip8) InstructionError!void{
        
        self.PC = self.stack.pop() catch |err|{
            return InstructionError.ExecutionError;
        };
        std.debug.print("RET \t {d}\n",.{self.PC});
        
    }

    fn jump(self: *Chip8, data : u16) InstructionError!void {
        const addr : u16 = data & 0x0FFF;
        std.debug.print("JMP \t {d}\n",.{addr});
        self.PC = addr;

    }

    fn call(self:*Chip8, data: u16) InstructionError!void{
        const addr : u16 = data & 0x0FFF;
        std.debug.print("CALL \t {d}\n", .{addr});
        self.stack.push(self.PC) catch |err|{
            return InstructionError.ExecutionError;
        };
        self.PC = addr;
    }

    fn skipNotEqual(self: *Chip8, data:u16) InstructionError!void{
        const x = (data & 0x0F00) >> 8;
        const kk =  data & 0x00FF;

        std.debug.print("SNE \t V{d} != {d}\n", .{x,kk});
        if(self.V[x] != kk){
            self.PC +=2;
        }

    }

    fn skipEqual(self: *Chip8, data:u16) InstructionError!void{
        const x = (data & 0x0F00) >> 8;
        const kk =  data & 0x00FF;

        std.debug.print("SE \t V{d} = {d}\n", .{x,kk});
        if(self.V[x] == kk){
            self.PC +=2;
        }
        
    }

    fn skipEqualReg(self: *Chip8, data:u16) InstructionError!void{
        const x = (data & 0x0F00) >> 8;
        const y = (data & 0x00F0) >> 4;
        std.debug.print("SE \t V{d} = V{d}\n", .{x,y});
        if(self.V[x] == self.V[y]){
            self.PC += 2;
        }
    }

    fn load(self: *Chip8, data:u16) InstructionError!void{
        const x = (data & 0x0F00) >> 8;
        const kk =  data & 0x00FF;

        std.debug.print("LD \t V{d},{d}\n",.{x,kk});
        self.V[x] = kk;

    }

    fn addReg(self: *Chip8, data:u16) InstructionError!void{
        const x = (data & 0x0F00) >> 8;
        const kk =  data & 0x00FF;

        std.debug.print("ADD \t V{d},{d}",.{x,kk});
        self.V[x] += kk;


    }

    fn bitRegOperations(self: *Chip8, data:u16) InstructionError!void{
        const x = (data & 0x0F00) >> 8;
        const y = (data & 0x00F0) >> 4;
        const op = data & 0x000F;

        const result = switch(op){
            0 => self.V[y],
            1 => self.V[x] | self.V[y],
            2 => self.V[x] & self.V[y],
            3 => self.V[x] ^ self.V[y],
            4 => blk :{
                const result = self.V[x] + self.V[y];
                if(result > 255){
                    self.V[0xF] = 1;
                }
                break: blk result & 0xFF;

            },
            5=> blk :{
                const result = self.V[x] - self.V[y];
                if(self.V[x] > self.V[y]){
                    self.V[0xF] = 1;
                }
                break: blk result;
            },
            6=> blk:{
                const result = self.V[x] >> 1;
                if(self.V[x] & 1 == 1){
                    self.V[0xF] = 1;
                }
                else{
                    self.V[0xF] = 0;
                }
                break: blk result;
            },
            7 => blk:{
                const result = self.V[y] - self.V[x];
                if(self.V[y] > self.V[x]){
                    self.V[0xF] = 1;
                }
                else{
                    self.V[0xF] = 0;
                }
                break: blk result;
            },
            0xE => blk:{
                const result = self.V[x] * 2;
                if(self.V[x] & 1 == 1){
                    self.V[0xF] = 1;
                }
                else{
                    self.V[0xF] = 0;
                }
                break: blk result;
            },
            else => blk:{
                const result = 0;
                std.debug.print("Unknown operation\n",.{});
                break:blk result;
            }
        };
        
        self.V[x] = result;
        


    }





};

pub const InstructionError = error{
    NotImplemented,
    ExecutionError
};

pub const Operation = union{
    func : fn(*Chip8, u16) InstructionError!void,
    

};



pub const InstructionSet = struct{
    set : [16]Operation,

    pub fn init() InstructionSet{

        const set = [_]Operation{Operation{.func = notImplemented}} ** 16;



        return InstructionSet{
            .set = set
        };

    }

    pub fn notImplemented(self: *Chip8, ins:u16 ) InstructionError!void{
        return InstructionError.NotImplemented;
    }
    


};