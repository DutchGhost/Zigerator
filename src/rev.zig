
const itermodule = @import("iterator.zig");
const Iterator = itermodule.Iterator;
const DoubleEndedIterator = itermodule.DoubleEndedIterator;

pub fn Rev(comptime Iter: type) type {
    return struct {
        const Self = @This();

        iter: Iter,

        pub fn init(iterator: Iter) Self {
            return Self { .iter = iterator};
        }

        pub fn next(self: *Self) ?Self.Item {
            return self.iter.next_back();
        }

        pub fn next_back(self: *Self) ?Self.Item {
            return self.iter.next();
        }

        usingnamespace Iterator(Self, Iter.Item);
        usingnamespace DoubleEndedIterator(Self);
    };
}