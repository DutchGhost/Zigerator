const Enumerate = @import("enumerate.zig").Enumerate;
const Rev = @import("rev.zig").Rev;
const Take = @import("take.zig").Take;
const Filter = @import("filter.zig").Filter;
const Map = @import("map.zig").Map;
const Zip = @import("zip.zig").Zip;

const traits = @import("traits.zig");
const utils = @import("utils.zig");
const builtin = @import("builtin");

usingnamespace traits;

/// Expect a `next` function to be defined:
/// fn next(self: *Self) ?Item
pub fn Iterator(comptime Self: type) type {
    return struct {
        const Item = Self.Item;

        pub fn enumerate(self: Self) Enumerate(Self) {
            return Enumerate(Self).init(self);
        }

        pub fn rev(self: Self) Rev(Self) {
            return Rev(Self).init(self);
        }

        pub fn take(self: Self, n: usize) Take(Self) {
            return Take(Self).init(self, n);
        }

        pub fn filter(self: Self, context: var, predicate: fn (@TypeOf(context), *Item) bool) Filter(Self, @TypeOf(context), @TypeOf(predicate)) {
            return Filter(Self, @TypeOf(context), @TypeOf(predicate)).init(self, context, predicate);
        }

        pub fn map(self: Self, context: var, func: var) Map(Self, @TypeOf(context), @TypeOf(func)) {
            return Map(Self, @TypeOf(context), @TypeOf(func)).init(self, context, func);
        }

        pub fn zip(self: Self, other: var) Zip(Self, @TypeOf(other)) {
            return Zip(Self, @TypeOf(other)).init(self, other);
        }

        pub fn max_by_key(self: Self, cmp: var) ?Item {
            var _self = self;
            var current_greatest_elem = _self.next() orelse return null;
            var current_greatest_key = cmp[0].call(cmp, &current_greatest_elem);

            while (_self.next()) |e| {
                var current_key = cmp[0].call(cmp, &e);

                if (current_key > current_greatest_key) {
                    current_greatest_elem = e;
                    current_greatest_key = current_key;
                }
            }

            return current_greatest_elem;
        }

        pub fn fold(self: Self, context: var, init: var, f: fn (@TypeOf(context), @TypeOf(init), Item) @TypeOf(init)) @TypeOf(init) {
            var _self = self;
            var _init = init;

            while (_self.next()) |elem| {
                _init = f(context, _init, elem);
            }

            return _init;
        }

        const nth_fallback = struct {
            pub fn nth(self: *Self, nth_elem: usize) ?Item {
                var n = nth_elem;
                while (self.next()) |elem| {
                    if (n == 0) return elem;
                    n -= 1;
                }

                return null;
            }
        };

        const count_fallback = struct {
            pub fn count(self: Self) usize {
                return self.fold({}, @as(usize, 0), struct {
                    fn call(ctx: void, _count: usize, _: Item) usize {
                        return _count + 1;
                    }
                }.call);
            }
        };

        const last_fallback = struct {
            pub fn last(self: Self) ?Item {
                var none: ?usize = null;
                return self.fold({}, none, struct {
                    fn call(ctx: void, _: ?Item, elem: Item) ?Item {
                        return elem;
                    }
                }.call);
            }
        };

        const sum_impl = struct {
            pub fn sum(_self: Self) Item {
                var self = _self;
                var _sum = @as(Item, 0);

                while (self.next()) |elem| {
                    _sum += elem;
                }

                return _sum;
            }
        };

        pub usingnamespace utils.mixin_if(!@hasDecl(Self, "nth"), nth_fallback);
        pub usingnamespace utils.mixin_if(!@hasDecl(Self, "count"), count_fallback);
        pub usingnamespace utils.mixin_if(!@hasDecl(Self, "last"), last_fallback);
        pub usingnamespace utils.mixin_if(is_integral(Self.Item), sum_impl);
    };
}

/// Expects a `next_back` function to be defined:
/// fn next_back(self: *Self) ?Item
pub fn DoubleEndedIterator(comptime Self: type) type {
    return struct {
        const nth_back_fallback = struct {
            pub fn nth_back(self: *Self, n: usize) ?Self.Item {
                var _n = n;
                while (self.next_back()) |elem| {
                    if (_n == 0) {
                        return elem;
                    }
                    _n -= 1;
                }

                return null;
            }
        };
        pub usingnamespace utils.mixin_if(!@hasDecl(Self, "nth_back"), nth_back_fallback);
    };
}

/// Expects a `len` function to be defined:
/// fn len(self: *const Self) usize
pub fn ExactSizeIterator(comptime Self: type) type {
    return struct {
        const is_empty_fallback = struct {
            pub fn is_empty(self: *const Self) bool {
                return self.len() == 0;
            }
        };

        pub usingnamespace utils.mixin_if(!@hasDecl(Self, "is_empty"), is_empty_fallback);
    };
}

pub fn Range(comptime T: type) type {
    return struct {
        begin: T,
        end: T,

        pub const Item = T;
        const Self = @This();

        pub fn init(begin: T, end: T) Self {
            return Self{ .begin = begin, .end = end };
        }

        pub fn next(self: *Self) ?T {
            if (self.begin >= self.end) {
                return null;
            }

            var ret = self.begin;
            self.begin += 1;
            return ret;
        }

        pub fn nth(self: *Self, nth_elem: usize) ?T {
            if (self.begin + nth_elem < self.end) {
                self.begin += nth_elem;
                return self.next();
            }
            return null;
        }

        pub fn last(self: Self) ?T {
            if (self.is_empty()) {
                return null;
            } else {
                self.start = self.end;
                return self.end - 1;
            }
        }

        pub fn next_back(self: *Self) ?T {
            if (self.begin < self.end) {
                self.end -= 1;
                return self.end;
            }
            return null;
        }

        pub fn len(self: *const Self) usize {
            return self.end - self.begin;
        }

        pub usingnamespace Iterator(Self);
        pub usingnamespace DoubleEndedIterator(Self);
        pub usingnamespace ExactSizeIterator(Self);
    };
}

pub fn Tuple(comptime A: type, comptime B: type) type {
    return struct {
        a: A,
        b: B,
    };
}
