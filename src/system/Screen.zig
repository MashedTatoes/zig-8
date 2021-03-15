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
const fragmentShader = @embedFile("./shader/c8frag.glsl");
const vertexShader = @embedFile("./shader/c8vert.glsl");
const clear = .{.color = true,.depth = false, .stencil = false};


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
        gl.enable(gl.Capabilities.debug_output);
        

        screen.vertexBuffer = std.ArrayList(f32).init(heap.c_allocator);
        screen.indexBuffer = std.ArrayList(u32).init(heap.c_allocator);
        screen.vao= gl.createVertexArray();
        gl.bindVertexArray(screen.vao);
        screen.vbufferId = gl.genBuffer();
        gl.bindBuffer(gl.BufferTarget.array_buffer,screen.vbufferId);
        gl.enableVertexAttribArray(0);
        gl.enableVertexArrayAttrib(screen.vao,0);
        gl.vertexAttribPointer(0,3,gl.Type.float,false,@sizeOf(f32)*3,0);
        
        screen.indexBufferId = gl.genBuffer();
        gl.bindBuffer(gl.BufferTarget.element_array_buffer,screen.indexBufferId);
        screen.initShaderProgram(fragmentShader,vertexShader);
        gl.useProgram(screen.program);
        gl.bindBuffer(gl.BufferTarget.array_buffer,gl.Buffer.invalid);
        gl.bindBuffer(gl.BufferTarget.element_array_buffer,gl.Buffer.invalid);
        gl.useProgram(gl.Program.invalid);
        gl.bindVertexArray(gl.VertexArray.invalid);
        //gl.glGenVertexArrays(1,@intToPtr(?*c_uint, screen.vao));

        return screen;

    }

    pub fn render(self: *Screen) void{
        gl.clearColor(0.5, 0.3, 0.3, 1.0);
        gl.clear(clear);

        gl.useProgram(self.program);
        gl.bindVertexArray(self.vao);
        gl.bindBuffer(gl.BufferTarget.element_array_buffer,self.indexBufferId);
        gl.drawElements(gl.PrimitiveType.triangles,self.indexBuffer.capacity,gl.ElementType.u32,null);
        glfwSwapBuffers(self.window);



    }

    pub fn setPixels(self: *Screen, pixels:  [] const u8) void{
        
        self.vertexBuffer.shrinkAndFree(0);
        self.indexBuffer.shrinkAndFree(0);
        var pixelCount : u32 = 0;
        for(pixels) |val,i|{
           var pixel = @intToFloat(f32,i);
            if(val == 1){
                
                self.vertexBuffer.appendSlice(&[4*3]f32 {
                    0,0,pixel,
                    1,0,pixel,
                    1,1,pixel,
                    0,1,pixel
                }) catch |err|{
                    std.debug.print("Couldnt insert mesh\n", .{});
                };
                
                self.indexBuffer.appendSlice(&[_]u32{
                0 * pixelCount, 
                1 * pixelCount, 
                2 * pixelCount,
                2 * pixelCount,
                3* pixelCount,
                0*pixelCount})catch |err|{
                    std.debug.print("Couldnt insert index buffer\n", .{});
                };
            }
            
        }

        gl.bindBuffer(gl.BufferTarget.array_buffer,self.vbufferId);
        gl.bufferData(gl.BufferTarget.array_buffer,f32,self.vertexBuffer.items[0..],gl.BufferUsage.static_draw);
        gl.bindBuffer(gl.BufferTarget.element_array_buffer,self.indexBufferId);
        gl.bufferData(gl.BufferTarget.element_array_buffer,u32, self.indexBuffer.items[0..],gl.BufferUsage.static_draw);

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

    fn loadShaders(self: *Screen) void{
        
    }

    fn initShaderProgram(self: *Screen,fragSource : []const u8, vertSource: []const u8) void{
        self.program = gl.createProgram();
        const vertexShaderID = compileShader(gl.ShaderType.vertex,vertSource);
        if(vertexShaderID == gl.Shader.invalid){
            std.debug.print("Error creating vertex shader:\n {s}\n", .{vertSource});
        }
        const fragmentShaderID = compileShader(gl.ShaderType.fragment,fragSource);

        if(fragmentShaderID == gl.Shader.invalid){
            std.debug.print("Error creating vertex shader:\n {s}\n", .{fragSource});
        }

        gl.attachShader(self.program,vertexShaderID);
        gl.attachShader(self.program,fragmentShaderID);

        gl.linkProgram(self.program);
        gl.validateProgram(self.program);
        gl.deleteShader(vertexShaderID);
        gl.deleteShader(fragmentShaderID);


        
    }

    fn compileShader(shaderType: gl.ShaderType, src: []const u8) gl.Shader{
        var id = gl.createShader(shaderType);
        gl.shaderSource(id, 1, &[1][]const u8 {src});
        gl.compileShader(id);
        var result = gl.getShader(id,gl.ShaderParameter.compile_status);
        if(result == 0){
            var len = gl.getShader(id,gl.ShaderParameter.info_log_length);
            var msg = gl.getShaderInfoLog(id,std.heap.c_allocator);
            std.debug.print("{s}", .{msg});
        }
        
        return id;

    }

    

};



