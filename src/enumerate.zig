const iterator = @import("iterator.zig");
const Iterator = iterator.Iterator;
const DoubleEndedIterator = iterator.DoubleEndedIterator;
const ExactSizeIterator = iterator.ExactSizeIterator;

const Tuple = iterator.Tuple;

pub fn Enumerate(comptime Iter: type) type {
    return struct {
        pub const Item = Tuple(usize, Iter.Item);

        const Self = @This();

        iter: Iter,
        count: usize,

        pub fn init(iter: Iter) Self {
            return Self{ .iter = iter, .count = 0 };
        }

        pub fn next(self: *Self) ?Self.Item {
            var elem = self.iter.next() orelse return null;
            var i = self.count;
            self.count += 1;
            return Self.Item{ .a = i, .b = elem };
        }

        pub fn next_back(self: *Self) ?Self.Item {
            var elem = self.iter.next_back() orelse return null;
            var _len = self.iter.len();
            return Self.Item{ .a = self.count + _len, .b = elem };
        }

        pub fn len(self: *const Self) usize {
            return self.iter.len();
        }

        pub fn is_empty(self: *const Self) bool {
            return self.iter.is_empty();
        }

        usingnamespace Iterator(Self);
        usingnamespace DoubleEndedIterator(Self);
        usingnamespace ExactSizeIterator(Self);
    };
}
