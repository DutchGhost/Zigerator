const itermodule = @import("iterator.zig");
const Iterator = itermodule.Iterator;

pub fn Take(comptime Iter: type) type {
    return struct {
        iter: Iter,
        n: usize,

        const Self = @This();

        pub fn init(iter: Iter, n: usize) Self {
            return Self { .iter = iter, .n = n};
        }

        pub fn next(self: *Self) ?Iter.Item {
            if (self.n != 0) {
                self.n -= 1;
                return self.iter.next();
            } else {
                return null;
            }
        }

        pub fn nth(self: *Self, nth_elem: usize) ?Iter.Item {
            return self.iter.nth(nth_elem);
        }
        
        usingnamespace Iterator(Self, Iter.Item);
    };
}