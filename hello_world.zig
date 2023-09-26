const std = @import("std");

test "stdout" {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, {s}\n", .{"world!"});
}

test "debug" {
    std.debug.print("Hello, {s}\n", .{"world!"});
}
