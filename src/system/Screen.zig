pub usingnamespace  @cImport(
{ 
    @cInclude("glfw/glfw3.h");
});
const gl = @import("gl");
const Buffer = gl.Buffer;

const std = @import("std");
const heap = std.heap;
const VERTEX_SIZE = 3;
const Allocator = std.mem.Allocator;


pub const Screen = struct{
    window: ?*GLFWwindow = undefined,
    vbufferId: gl.Buffer = undefined,
    vertexBuffer : std.ArrayList(f32) = undefined,
    indexBufferId: gl.Buffer = undefined,
    indexBuffer : std.ArrayList(u32)= undefined,
    vao : gl.VertexArray = undefined,
    allocator: *Allocator,
    program : gl.Program = undefined,



    pub fn init() Screen{
        if(glfwInit() == GL_FALSE){
            std.debug.print("Error init GLFW",.{});
        }
        const window: ?*GLFWwindow = glfwCreateWindow(1024,780,"Zig-8!",null,null);
        glfwMakeContextCurrent(window);
        var screen = Screen{
            .window = window,
            .allocator = heap.c_allocator
        };

        
        if(gl.gladLoadGL(@ptrCast(gl.gladLoadProc,glfwGetProcAddress)) == false){
            std.debug.print("Failed to load GLAD\n", .{});
        }

        screen.vertexBuffer = std.ArrayList(f32).init(heap.c_allocator);
        screen.indexBuffer = std.ArrayList(u32).init(heap.c_allocator);
        screen.vao= gl.createVertexArray();
        gl.bindVertexArray(screen.vao);
        screen.vbufferId = gl.genBuffer();
        gl.bindBuffer(screen.vbufferId,gl.BufferTarget.array_buffer);
        gl.enableVertexAttribArray(0);
        gl.enableVertexArrayAttrib(screen.vao,0);
        gl.vertexAttribPointer(0,2,gl.Type.float,false,@sizeOf(f32),0);
        
        screen.indexBufferId = gl.genBuffer();
        gl.bindBuffer(screen.indexBufferId,gl.BufferTarget.index_buffer);
        

        //gl.glGenVertexArrays(1,@intToPtr(?*c_uint, screen.vao));

        return screen;

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