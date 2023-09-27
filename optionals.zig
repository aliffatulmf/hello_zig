const std = @import("std");

fn returnOpional(i: i8) ?i8 {
    if (i < 5) {
        return 1;
    } else if (i > 10) {
        return 2;
    }
    return null;
}

test {
    const optional = returnOpional;

    try std.testing.expectEqual(?i8, @TypeOf(optional(7)));
    try std.testing.expectEqual(i8, @TypeOf(optional(7).?));

    try std.testing.expectEqual(?i8, @TypeOf(optional(12)));
    try std.testing.expectEqual(i8, @TypeOf(optional(12).?));

    try std.testing.expectEqual(?i8, @TypeOf(optional(6)));
    try std.testing.expectEqual(i8, @TypeOf(optional(6).?));

    try std.testing.expect(optional(12).? == 2);
    try std.testing.expect(optional(6) == null);
}
