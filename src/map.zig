const itermodule = @import("iterator.zig");
const Iterator = itermodule.Iterator;
const DoubleEndedIterator = itermodule.DoubleEndedIterator;
const utils = @import("utils.zig");

pub fn Map(comptime Iter: type, comptime F: type, comptime Ret: type) type {
    return struct {
        iter: Iter,
        mapfn: F,

        const Self = @This();

        pub fn init(iter: Iter, mapfn: F) Self {
            return Self{
                .iter = iter,
                .mapfn = mapfn,
            };
        }

        pub fn next(self: *Self) ?Ret {
            var elem = self.iter.next() orelse return null;

            return self.mapfn[0].call(self.mapfn, elem);
        }

        pub usingnamespace Iterator(Self, Ret);
    };
}
