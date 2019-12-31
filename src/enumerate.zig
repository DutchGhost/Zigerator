const itermodule = @import("iterator.zig");
const Iterator = itermodule.Iterator;
const DoubleEndedIterator = itermodule.DoubleEndedIterator;
const ExactSizeIterator = itermodule.ExactSizeIterator;

const Tuple = itermodule.Tuple;

pub fn Enumerate(comptime Iter: type) type {
    return struct {
        
        const Self = @This();

        iter: Iter,
        count: usize,

        pub fn init(iterator: Iter) Self {
            return Self { .iter = iterator, .count = 0};
        }

        pub fn next(self: *Self) ?Self.Item {
            var elem = self.iter.next() orelse return null;
            var i = self.count;
            self.count += 1;
            return Self.Item { .a = i, .b = elem};
        }
        
        pub fn next_back(self: *Self) ?Self.Item {
            var elem = self.iter.next_back() orelse return null;
            var __len = self.iter.len();
            return Self.Item {.a = self.count + __len, .b = elem};
        }

        pub fn len(self: *const Self) usize {
            return self.iter.len();
        }

        usingnamespace Iterator(Self, Tuple(usize, Iter.Item));
        usingnamespace DoubleEndedIterator(Self);
        usingnamespace ExactSizeIterator(Self);
    };
}
