
const gl = @import("gl");
const math = @import("zlm");
const glfw = @import("glfw");
const Mat4 = math.Mat4;
const Buffer = gl.Buffer;

const std = @import("std");
const heap = std.heap;
const VERTEX_SIZE = 3;
const Allocator = std.mem.Allocator;
const fragmentShader = @embedFile("./shader/c8frag.glsl");
const vertexShader = @embedFile("./shader/c8vert.glsl");
const clear = .{.color = true,.depth = false, .stencil = false};
const math_f32 = math.specializeOn(f32);
var mesh_width : f32 = 0.0;
var mesh_height:f32 = 0.0;

pub const pixel_screen_width = 64;
pub const pixel_screen_height = 32;


pub const Screen = struct{
    window: ?*glfw.Window = undefined,
    vbufferId: gl.Buffer = undefined,
    vertexBuffer : std.ArrayList(f32) = undefined,
    indexBufferId: gl.Buffer = undefined,
    indexBuffer : std.ArrayList(u32)= undefined,
    vao : gl.VertexArray = undefined,
    allocator: *Allocator,
    program : gl.Program = undefined,
    projection: math_f32.Mat4 = math_f32.Mat4.zero,

    pub fn init(width: f32, height: f32) Screen{
        if(glfw.init() == false){
            std.debug.print("Error init GLFW",.{});
        }
        const window: ?*glfw.Window = glfw.createWindow(@floatToInt(i32,width),@floatToInt(i32,height),"Zig-8!",null,null);
        glfw.makeContextCurrent(window);
        var screen = Screen{
            .window = window,
            .allocator = heap.c_allocator,
            .projection = math_f32.Mat4.createOrthogonal(0,width,0,height,-1.0,1.0)
        };

        mesh_width = width/pixel_screen_width;
        mesh_height = height/pixel_screen_height;
        
        if(gl.gladLoadGL(@ptrCast(gl.gladLoadProc,glfw.getProcAddress)) == false){
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
        gl.vertexAttribPointer(0,4,gl.Type.float,false,@sizeOf(f32)*4,0);
        
        screen.indexBufferId = gl.genBuffer();
        gl.bindBuffer(gl.BufferTarget.element_array_buffer,screen.indexBufferId);
        screen.initShaderProgram(fragmentShader,vertexShader);
        gl.useProgram(screen.program);
        const ortho =  [_] [4][4]f32{
            screen.projection.fields
        };
        std.debug.print("{s}\n",.{@TypeOf(ortho)});
        gl.programUniformMatrix4(screen.program,gl.getUniformLocation(screen.program,"u_mvp"),false,&ortho);
        gl.programUniform2f(screen.program,gl.getUniformLocation(screen.program,"pixelSize"),mesh_width,mesh_height);
        gl.bindBuffer(gl.BufferTarget.array_buffer,gl.Buffer.invalid);
        gl.bindBuffer(gl.BufferTarget.element_array_buffer,gl.Buffer.invalid);
        gl.useProgram(gl.Program.invalid);
        gl.bindVertexArray(gl.VertexArray.invalid);
        //gl.glGenVertexArrays(1,@intToPtr(?*c_uint, screen.vao));

        return screen;

    }

    pub fn render(self: *Screen) void{
        gl.clearColor(0, 0, 0, 1.0);
        gl.clear(clear);

        gl.useProgram(self.program);
        gl.bindVertexArray(self.vao);
        gl.bindBuffer(gl.BufferTarget.element_array_buffer,self.indexBufferId);
        gl.drawElements(gl.PrimitiveType.triangles,self.indexBuffer.capacity,gl.ElementType.u32,null);
        glfw.swapBuffers(self.window);



    }

    pub fn setPixels(self: *Screen, pixels:  [] const u8) void{
        
        self.vertexBuffer.shrinkAndFree(0);
        self.indexBuffer.shrinkAndFree(0);
        var pixelCount : u32 = 0;
        for(pixels) |val,i|{
           var pixel = @intToFloat(f32,i);
           
            if(val == 1){
                
                
                const pixelY = @round( pixel /pixel_screen_width);
                const pixelX = @mod( pixel, pixel_screen_width);
                
                self.vertexBuffer.appendSlice(&[4*4]f32 {
                    0,0,pixelX,pixelY, //Top left
                    mesh_width,0,pixelX,pixelY, //Top right
                    mesh_width,mesh_height,pixelX,pixelY, //Bottom right
                    0,mesh_height,pixelX,pixelY //Bottom left
                }) catch |err|{
                    std.debug.print("Couldnt insert mesh\n", .{});
                };
                
                self.indexBuffer.appendSlice(&[_]u32{
                (4 * pixelCount) + 0, 
                (4 * pixelCount) + 1, 
                (4 * pixelCount) + 2,
                (4 * pixelCount) + 2,
                (4* pixelCount)+ 3,
                (4*pixelCount) + 0})catch |err|{
                    std.debug.print("Couldnt insert index buffer\n", .{});
                };
                pixelCount += 1;
            }
            
        }
       

        

        gl.bindBuffer(gl.BufferTarget.array_buffer,self.vbufferId);
        gl.bufferData(gl.BufferTarget.array_buffer,f32,self.vertexBuffer.items[0..],gl.BufferUsage.static_draw);
        gl.bindBuffer(gl.BufferTarget.element_array_buffer,self.indexBufferId);
        gl.bufferData(gl.BufferTarget.element_array_buffer,u32, self.indexBuffer.items[0..],gl.BufferUsage.static_draw);

    }

    pub fn pollEvents(self: *Screen) void{
        glfw.pollEvents();
    }

    pub fn shouldClose(self: *Screen) bool{
        
        return  glfw.windowShouldClose(self.window) != false;
    }

    pub fn deinit(self: *Screen) void{
        glfw.terminate();
        self.vertexBuffer.shrinkAndFree(0);
        self.indexBuffer.shrinkAndFree(0);
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

