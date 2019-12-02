/// Expect a `next` function to be defined:
/// fn next(self: *Self) ?Item

const Enumerate = @import("enumerate.zig").Enumerate;
const Rev = @import("rev.zig").Rev;

pub fn Iterator(comptime Self: type, comptime _Item: type) type {
    return struct {
        pub const Item = _Item;

        pub fn enumerate(self: Self) Enumerate(Self) {
            return Enumerate(Self).init(self);
        }

        pub fn rev(self: Self) Rev(Self) {
            return Rev(Self).init(self);
        }

        pub usingnamespace if (!@hasDecl(Self, "nth")) struct {
            pub fn nth(self: *Self, nth_elem: usize) ?Item {
                var n = nth_elem;
                while(self.next()) |elem| {
                    if (n == 0) return elem;
                    n -= 1;
                }

                return null;
            }
        } else struct {};

    };
}

pub fn DoubleEndedIterator(comptime Self: type) type {
    return struct {
        usingnamespace Iterator(Self, Self.Item);
    };
}

pub fn ExactSizeIterator(comptime Self: type) type {
    return struct {
        usingnamespace Iterator(Self, Self.Item);
    };
}

pub fn Range(comptime T: type) type {
    return struct {
        begin: T,
        end: T,

        const Self = @This();

        pub fn init(begin: T, end: T) Self {
            return Self { .begin = begin, .end = end};
        }

        fn nth(self: *Self, nth_elem: usize) ?T {
            if (self.begin + nth_elem < self.end) {
                self.begin += nth_elem;
                return self.begin;
            }
            return null;
        }

        fn next(self: *Self) ?T {
            if (self.begin >= self.end) {
                return null;
            }

            var ret = self.begin;
            self.begin += 1;
            return ret;
        }

        fn next_back(self: *Self) ?T {
            if (self.begin < self.end) {
                self.end -= 1;
                return self.end;
            }
            return null;
        }

        fn len(self: *const Self) usize {
            return self.end - self.begin;
        }

        pub usingnamespace Iterator(Self, T);
        pub usingnamespace DoubleEndedIterator(Self);
    };
}

pub fn Tuple(comptime A: type, comptime B: type) type {
    return struct {
        a: A,
        b: B,
    };
}