const iterator = @import("iterator.zig");
const Iterator = iterator.Iterator;
const DoubleEndedIterator = iterator.DoubleEndedIterator;
const ExactSizeIterator = iterator.ExactSizeIterator;

pub fn Filter(comptime Iter: type, comptime Ctx: type, comptime F: type) type {
    return struct {
        pub const Item = Iter.Item;

        const Self = @This();

        iter: Iter,
        context: Ctx,
        predicate: F,

        pub fn init(iter: Iter, context: Ctx, predicate: F) Self {
            return Self{
                .iter = iter,
                .context = context,
                .predicate = predicate,
            };
        }

        pub fn next(self: *Self) ?Item {
            while (true) {
                var elem = self.iter.next() orelse return null;

                if (self.predicate(self.context, &elem)) {
                    return elem;
                }
            }
        }

        pub fn next_back(self: *Self) ?Item {
            while (true) {
                var elem = self.iter.next_back() orelse return null;

                if (self.predicate(self.context, &elem)) {
                    return elem;
                }
            }
        }

        pub usingnamespace Iterator(Self);
        pub usingnamespace DoubleEndedIterator(Self);
    };
}
