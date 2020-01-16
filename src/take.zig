const iterator = @import("iterator.zig");
const Iterator = iterator.Iterator;
const DoubleEndedIterator = iterator.DoubleEndedIterator;
const ExactSizeIterator = iterator.ExactSizeIterator;

const builtin = @import("builtin");
const TypeId = builtin.TypeId;

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
            if (self.n > nth_elem) {
                self.n -= nth_elem + 1;
                return self.iter.nth(nth_elem);
            } else {
                if (self.n > 0) {
                    var elem = self.iter.nth(self.n - 1);
                    self.n = 0;

                    const ITER_ITEM = switch (@typeInfo(Iter.Item)) {
                        TypeId.Struct => Iter.Item,
                        TypeId.Enum => Iter.Item,
                        TypeId.Union => Iter.Item,
                        else => return null,
                    };

                    if (@hasDecl(ITER_ITEM, "deinit")) {
                        elem.deinit();
                    }
                }

                return null;
            }
        }

        pub fn len(self: *const Self) usize {
            return self.iter.len();
        }

        pub usingnamespace Iterator(Self);
        pub usingnamespace DoubleEndedIterator(Self);
        pub usingnamespace ExactSizeIterator(Self);
    };
}

const testing = @import("std").testing;

test "take" {
    const Range = iterator.Range;

    var range = Range(usize).init(0, 100).take(2);

    var next = range.next();
    testing.expectEqual(next, 0);

    next = range.next();
    testing.expectEqual(next, 1);

    testing.expectEqual(range.next(), null);
}

test "take reverse" {
    const Range = iterator.Range;

    var range = Range(usize).init(0, 100).take(3).rev();
    var next = range.next();
    testing.expectEqual(next, 2);

    next = range.next();
    testing.expectEqual(next, 1);

    next = range.next();
    testing.expectEqual(next, 0);

    testing.expectEqual(range.next(), null);
}

test "take nth" {
    const Range = iterator.Range;

    var range = Range(usize).init(0, 100).take(50);

    var nth = range.nth(49);
    testing.expectEqual(nth, 49);

    testing.expectEqual(range.next(), null);
}
