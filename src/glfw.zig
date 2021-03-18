const c = @cImport(
{ 
    @cInclude("glfw/glfw3.h");
});

pub const Monitor = c.GLFWmonitor;
pub const Window = c.GLFWwindow;

pub const GlProc = c.GLFWglproc;

pub const KeyFun = c.GLFWkeyfun;

pub fn init() bool{
    return  c.glfwInit() == 1;
}

pub fn createWindow(width: i32, height: i32, title: [*] const u8,moniter : ?*Monitor, window : ?*Window) ?*Window{
    return c.glfwCreateWindow(@intCast(c_int,width),@intCast(c_int,height),title,moniter,window);
}

pub fn makeContextCurrent(context: ?*Window) void {
    c.glfwMakeContextCurrent(context);
}



pub fn setKeyCallback(window: ?*Window,keyFun : KeyFun) KeyFun{
    return @as(KeyFun,c.glfwSetKeyCallback(window,keyFun));

}

pub fn swapBuffers(window: ?*Window) void{
    c.glfwSwapBuffers(window);
}

pub fn getProcAddress( proc :[*] const u8 ) GlProc{
    return c.glfwGetProcAddress(proc);
}

pub fn windowShouldClose(window : ?* Window) bool{
    return c.glfwWindowShouldClose(window) == 1;
}

pub fn pollEvents() void{
    c.glfwPollEvents();
}

pub fn terminate() void{
    c.glfwTerminate();
}

