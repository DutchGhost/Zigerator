const itermodule = @import("iterator.zig");
const Iterator = itermodule.Iterator;
const DoubleEndedIterator = itermodule.DoubleEndedIterator;
const ExactSizeIterator = itermodule.ExactSizeIterator;

pub fn Rev(comptime Iter: type) type {
    return struct {
        const Self = @This();

        iter: Iter,

        pub fn init(iterator: Iter) Self {
            return Self{ .iter = iterator };
        }

        pub fn next(self: *Self) ?Self.Item {
            return self.iter.next_back();
        }

        pub fn next_back(self: *Self) ?Self.Item {
            return self.iter.next();
        }

        pub fn len(self: *const Self) usize {
            return self.iter.len();
        }

        pub usingnamespace Iterator(Self, Iter.Item);
        pub usingnamespace DoubleEndedIterator(Self);
        pub usingnamespace ExactSizeIterator(Self);
    };
}
