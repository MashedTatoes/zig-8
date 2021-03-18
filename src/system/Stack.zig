const std = @import("std");
const heap = std.heap;
const Allocator = std.mem.Allocator;
pub const StackError = error{
    MemoryAllocationFailed,
    OutOfRange

};

pub const Stack = struct{

    idx : u16 = 0,
    buff:[]u16,
    allocator : *Allocator,
    len : u16,

    pub fn init(size: u16) StackError!Stack{
        const allocator = std.heap.page_allocator;
        var buff = allocator.alloc(u16,size) catch |err|{
            return StackError.MemoryAllocationFailed;
        };

        return Stack {
            .buff = buff,
            .allocator = allocator,
            .len = size
        };

    }

    pub fn deinit(self: *Stack) void{
        self.allocator.free(self.buff);
    }

    pub fn push(self: *Stack,val : u16) StackError!void{
        if(self.idx + 1 > self.buff.len){
            return StackError.OutOfRange;
        }
        self.buff[self.idx] = val; 
        self.idx += 1;
    }

    pub fn pop(self: *Stack)StackError!u16 { 
        self.idx -= 1;
        if(self.idx < 0){
            return StackError.OutOfRange;
        }
        const val = self.buff[self.idx];
        return val;
    }

    pub fn peek(self: *Stack) StackError!u16{
        if(self.idx -1 < 0){
            return StackError.OutOfRange;
        }
        const val = self.buff[self.idx-1];
        return val;

    }


};