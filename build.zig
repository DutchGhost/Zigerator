const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addStaticLibrary("Zigerator", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    var main_tests = b.addTest("src/main.zig");
    var zip_tests = b.addTest("src/zip.zig");
    var take_tests = b.addTest("src/take.zig");

    main_tests.setBuildMode(mode);
    zip_tests.setBuildMode(mode);
    take_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
    test_step.dependOn(&zip_tests.step);
    test_step.dependOn(&take_tests.step);
}
