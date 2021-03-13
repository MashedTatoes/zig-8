pub usingnamespace  @cImport(
    {@cInclude("GLFW/glfw3.h");
});


const std = @import("std");

pub const Screen = struct{
    window: ?*GLFWwindow = undefined,

    pub fn init() Screen{
        if(glfwInit() == GL_FALSE){
            std.debug.print("Error init GLFW",.{});
        }
        const window: ?*GLFWwindow = glfwCreateWindow(1024,780,"Zig-8!",null,null);
        glfwMakeContextCurrent(window);
        return Screen{
            .window = window
        };

    }

    pub fn render(self: *Screen) void{
        glClearColor(0.2, 0.3, 0.3, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glfwSwapBuffers(self.window);



    }

    pub fn pollEvents(self: *Screen) void{
        glfwPollEvents();
    }

    pub fn shouldClose(self: *Screen) bool{
        
        return  glfwWindowShouldClose(self.window) != 0;
    }

    pub fn deinit(self: *Screen) void{
        glfwTerminate();
    }

};