std = "lua51"

-- The imported addon exposes many globals through legacy XML callbacks and
-- consumes globals supplied by WoW, Titan Panel, and Ace. Ignore undefined
-- global diagnostics until those APIs are inventoried; syntax and the other
-- luacheck diagnostics remain active.
ignore = {
    "111",
    "113",
}

max_line_length = false

exclude_files = {
    "tests/lint/*",
}
