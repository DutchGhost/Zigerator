const builtin = @import("builtin");
const TypeInfo = builtin.TypeInfo;
const TypeId = builtin.TypeId;

const iterator = @import("iterator.zig");
const Iterator = iterator.Iterator;
const DoubleEndedIterator = iterator.DoubleEndedIterator;
const ExactSizeIterator = iterator.ExactSizeIterator;

const utils = @import("utils.zig");

pub fn Map(comptime Iter: type, comptime Ctx: type, comptime F: type) type {
    return struct {
        const Ret = switch (@typeInfo(F)) {
            TypeId.Fn => |f| f.return_type orelse void,
            else => @compileError("Excpected a function."),
        };

        pub const Item = Ret;

        const Self = @This();

        iter: Iter,
        context: Ctx,
        mapfn: F,

        pub fn init(iter: Iter, context: Ctx, mapfn: F) Self {
            return Self{
                .iter = iter,
                .context = context,
                .mapfn = mapfn,
            };
        }

        pub fn next(self: *Self) ?Ret {
            var elem = self.iter.next() orelse return null;

            return self.mapfn(self.context, elem);
        }

        pub fn next_back(self: *Self) ?Ret {
            var elem = self.iter.next_back() orelse return null;

            return self.mapfn(self.context, elem);
        }

        pub fn len(self: *const Self) usize {
            return self.iter.len();
        }

        pub fn is_empty(self: *const Self) bool {
            return self.iter.is_empty();
        }

        pub usingnamespace Iterator(Self);
        pub usingnamespace DoubleEndedIterator(Self);
        pub usingnamespace ExactSizeIterator(Self);
    };
}
