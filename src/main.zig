usingnamespace @import("iterator.zig");

const testing = @import("std").testing;

test "range iterate + enumerate" {
    var range = Range(usize).init(0, 4).enumerate();

    var next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 0, .b = 0 });

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 1, .b = 1 });

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 2, .b = 2 });

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 3, .b = 3 });

    next = range.next();
    testing.expectEqual(next, null);
}

test "range iterate + enumerate" {
    var range = Range(usize).init(0, 4).enumerate().rev();

    var next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 3, .b = 3 });

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 2, .b = 2 });

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 1, .b = 1 });

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 0, .b = 0 });

    next = range.next();
    testing.expectEqual(next, null);

    testing.expectEqual(range.is_empty(), true);
}

test "range nth" {
    var range = Range(usize).init(0, 10);

    var nth = range.nth(3);
    testing.expectEqual(nth, 3);

    var next = range.next();
    testing.expectEqual(next, 4);
}

test "take" {
    {
        var range = Range(usize).init(0, 100).rev().take(2);

        var next = range.next();
        testing.expectEqual(next, 99);

        next = range.next();
        testing.expectEqual(next, 98);

        testing.expectEqual(range.next(), null);
    }

    {
        var range = Range(usize).init(0, 100).take(3).rev();
        var next = range.next();
        testing.expectEqual(next, 2);

        next = range.next();
        testing.expectEqual(next, 1);

        next = range.next();
        testing.expectEqual(next, 0);

        testing.expectEqual(range.next(), null);
    }
}

test "sum" {
    var range = Range(usize).init(0, 10);
    var sum = range.sum();

    testing.expectEqual(sum, 9 + 8 + 7 + 6 + 5 + 4 + 3 + 2 + 1);
}

test "count" {
    {
        var counted = Range(usize).init(0, 10).count();
        testing.expectEqual(counted, 10);
    }

    {
        var counted = Range(usize).init(0, 100).take(10).rev().count();
        testing.expectEqual(counted, 10);
    }
}

test "filter" {
    var iter = Range(usize).init(0, 100).filter(.{struct {
        pub fn call(self: var, elem: *const usize) bool {
            return elem.* < 3;
        }
    }});

    var next = iter.next();
    testing.expectEqual(next, 0);

    next = iter.next();
    testing.expectEqual(next, 1);

    next = iter.next();
    testing.expectEqual(next, 2);

    testing.expectEqual(iter.next(), null);
}

test "filter reverse" {
    var iter = Range(usize).init(0, 100).filter(.{struct {
        pub fn call(self: var, elem: *const usize) bool {
            return elem.* < 3;
        }
    }}).rev();

    var next = iter.next();
    testing.expectEqual(next, 2);

    next = iter.next();
    testing.expectEqual(next, 1);

    next = iter.next();
    testing.expectEqual(next, 0);

    testing.expectEqual(iter.next(), null);
}

test "map" {
    var iter = Range(usize).init(0, 10).map(usize, .{struct {
        pub fn call(self: var, elem: usize) usize {
            return elem + 1;
        }
    }}).max_by_key(.{struct {
        pub fn call(self: var, elem: *const usize) usize {
            return elem.*;
        }
    }});

    testing.expectEqual(iter, 10);
}

const CollatsItem = struct {
    n: usize,
    collatz: usize,
};

fn transform(comptime T: type, elem: T) ?T {
    switch (elem) {
        1 => return null,
        else => |e| {
            if (e & 1 == 0) {
                return @divFloor(elem, 2);
            } else {
                return elem * 3 + 1;
            }
        },
    }
}

fn CollatzIterator(comptime T: type) type {
    return struct {
        current: ?T,
        const Self = @This();

        pub fn init(current: T) Self {
            return Self{ .current = current };
        }

        pub fn next(self: *Self) ?T {
            var elem = self.current orelse return null;

            self.current = transform(T, elem);
            return elem;
        }

        pub usingnamespace Iterator(Self, T);
    };
}

fn collatz(elem: var) CollatzIterator(@TypeOf(elem)) {
    return CollatzIterator(@TypeOf(elem)).init(elem);
}

test "collatz" {
    var collats = Range(usize).init(0, 1000000).filter(.{struct {
        pub fn call(self: var, elem: *usize) bool {
            return elem.* & 1 == 1;
        }
    }}).map(CollatsItem, .{struct {
        pub fn call(self: var, n: usize) CollatsItem {
            return CollatsItem{
                .n = n,
                .collatz = collatz(n).count(),
            };
        }
    }}).max_by_key(.{struct {
        pub fn call(self: var, elem: *const CollatsItem) usize {
            return elem.collatz;
        }
    }});

    testing.expectEqual(collats, CollatsItem{ .n = 837799, .collatz = 525 });
}
