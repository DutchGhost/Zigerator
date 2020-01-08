const iterator = @import("iterator.zig");
const Iterator = iterator.Iterator;
const DoubleEndedIterator = iterator.DoubleEndedIterator;
const ExactSizeIterator = iterator.ExactSizeIterator;

pub fn Rev(comptime Iter: type) type {
    return struct {
        pub const Item = Iter.Item;

        const Self = @This();

        iter: Iter,

        pub fn init(iter: Iter) Self {
            return Self{ .iter = iter };
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

        pub fn is_empty(self: *const Self) bool {
            return self.iter.is_empty();
        }
        
        pub usingnamespace Iterator(Self);
        pub usingnamespace DoubleEndedIterator(Self);
        pub usingnamespace ExactSizeIterator(Self);
    };
}
