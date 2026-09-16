# Roadmap

Open, forward-looking items only, in priority order. Everything already
done is in `CHANGELOG.md` and git history, not repeated here.

### 1. Reduce the remaining global API surface

Around 55 public `tcl_*` functions and several writable globals currently
form the de facto module interface, and `TitanCritLine.lua` still adds
`removekey` to Lua's own global `table` library rather than keeping it as
a local helper.

Needs converting internal-only functions to locals or fields on the
`TitanCritLine` addon table, and moving `table.removekey` off the global
`table` library. Not started - low risk but touches most files, so best
done as one deliberate pass rather than incrementally.

## Parked

Not active priorities, revisit only if the situation changes.

### HoT full-effect vs. largest tick

Decide whether HoT records should represent the full effect (sum of every
tick until the aura ends) or just the largest individual tick. The
current code preserves the legacy aggregate-over-the-effect behavior;
changing it would need a decision on which is actually more useful to
show, not just a technical change.
