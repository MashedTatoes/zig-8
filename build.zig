const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zig-8", "src/main.zig");
    
    const tests = b.addTest("test.zig");

    exe.addIncludeDir("deps/glfw/include");
    exe.addIncludeDir("deps/glad/include");
    exe.addCSourceFile("deps/glad/src/glad.c",&[_][]const u8 {});
    
    exe.addLibPath("deps/glfw/src/Release");

    exe.addPackagePath("gl","deps/zgl-glad/zgl.zig");
    exe.addPackagePath("zlm","deps/zlm/zlm-generic.zig");
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("shell32");
    

    tests.addIncludeDir("deps/glfw/include");
    tests.addLibPath("deps/glfw/src/Release");

    tests.linkSystemLibrary("glfw3");
    tests.linkSystemLibrary("c");
    tests.linkSystemLibrary("opengl32");
    tests.linkSystemLibrary("user32");
    tests.linkSystemLibrary("gdi32");
    tests.linkSystemLibrary("shell32");

    exe.setTarget(target);
    exe.setBuildMode(mode);
    
    exe.install();
    
    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const test_step = b.step("test","Test");
    test_step.dependOn(&tests.step);
    

}
