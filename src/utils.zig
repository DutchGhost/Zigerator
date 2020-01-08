const builtin = @import("builtin");
const Declaration = builtin.TypeInfo.Declaration;
const TypeId = builtin.TypeId;
const Data = builtin.TypeInfo.Declaration.Data;

const std = @import("std");
const mem = std.mem;

/// Returns `T` if the flag was true, and empty struct otherwise.
pub fn mixin_if(comptime flag: bool, comptime T: type) type {
    if (flag) {
        return T;
    } else {
        return struct {};
    }
}

pub fn has_fn(comptime T: type, comptime name: []const u8, sig: type) bool {
    var decls = switch (@typeInfo(T)) {
        TypeId.Struct => |s| s.decls,
        TypeId.Union => |u| u.decls,
        TypeId.Enum => |e| e.decls,
        else => @compileError("Expected a struct, union or enum."),
    };

    for (decls) |decl| {
        if (mem.eql(u8, decl.name, name)) {
            switch (decl.data) {
                Data.Fn => |f| {
                    if (f.fn_type == sig) {
                        return true;
                    }
                },
                else => continue,
            }
        }
    }

    return false;
}

pub fn has_item(comptime T: type, comptime name: []const u8) bool {
    return @hasDecl(T, name);
}

pub fn __requires(comptime T: type) type {
    return struct {
        const Self = @This();

        decls: []Declaration,

        pub fn init() Self {
            return Self{
                .decls = switch (@typeInfo(T)) {
                    TypeId.Struct => |s| s.decls,
                    TypeId.Union => |u| u.decls,
                    TypeId.Enum => |e| e.decls,
                    else => @compileError("Expected a struct, union or enum."),
                },
            };
        }

        pub fn has_fn(comptime self: Self, comptime name: []const u8, sig: type) Self {
            for (self.decls) |decl| {
                //@compileLog(@typeName(Self));
                //@compileLog(decl.name);
                if (mem.eql(u8, decl.name, name)) {
                    switch (decl.data) {
                        Data.Fn => |f| {
                            if (f.fn_type == sig) {
                                return self;
                            }
                        },
                        else => continue,
                    }
                }
            }
            return @compileError("Expected type `" ++ @typeName(T) ++ "` to have a function called `" ++ name ++ "` with the following signature: `" ++ @typeName(sig) ++ "`.");
        }

        pub fn has_item(comptime self: Self, comptime name: []const u8) Self {
            if (!@hasDecl(T, name)) {
                @compileError("Expected type `" ++ @typeName(T) ++ "` to declare `" ++ name ++ "`.");
            }

            return self;
        }
    };
}

pub fn requires(comptime T: type) __requires(T) {
    return __requires(T).init();
}
