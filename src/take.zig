const iterator = @import("iterator.zig");
const Iterator = iterator.Iterator;
const DoubleEndedIterator = iterator.DoubleEndedIterator;
const ExactSizeIterator = iterator.ExactSizeIterator;

pub fn Take(comptime Iter: type) type {
    return struct {
        pub const Item = Iter.Item;

        const Self = @This();

        iter: Iter,
        n: usize,

        pub fn init(iter: Iter, n: usize) Self {
            return Self{ .iter = iter, .n = n };
        }

        pub fn next(self: *Self) ?Item {
            if (self.n != 0) {
                self.n -= 1;
                return self.iter.next();
            } else {
                return null;
            }
        }

        pub fn next_back(self: *Self) ?Item {
            if (self.n == 0) {
                return null;
            } else {
                var n = self.n;
                self.n -= 1;

                return self.iter.nth_back(self.iter.len() - n);
            }
        }

        pub fn nth(self: *Self, nth_elem: usize) ?Item {
            return self.iter.nth(nth_elem);
        }

        pub fn len(self: *const Self) usize {
            return self.iter.len();
        }

        pub usingnamespace Iterator(Self);
        pub usingnamespace DoubleEndedIterator(Self);
        pub usingnamespace ExactSizeIterator(Self);
    };
}
