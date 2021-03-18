const glfw = @import("glfw");

pub const Keyboard = struct{

    pub var currentKeyPressed : u8 = 0xFF;

    pub fn init(window : ?*glfw.Window) void{
        _ =glfw.setKeyCallback(window,keyCallback);
    }

    fn keyCallback(window : ?*glfw.Window, key: c_int, scancode : c_int,action : c_int, mods: c_int) callconv(.C) void{
    
        
        if(action == 1){
            currentKeyPressed = mapKey(key);
            
        }

    }

    fn mapKey(key : c_int) u8 {
        return switch(key){
             81 => 1,
             87 => 2,
             69 => 3,
             82 => 0xC,
             65 => 4,
             83 => 5,
             68 => 6,
             70 => 0xD,
             90 => 7,
             88 => 8,
             67 => 9,
             86 => 0xE,
             49 => 0xA,
             50 => 0,
             51 => 0xB,
             52 => 0xF,
             else => 0xFF


        };


    }


};



