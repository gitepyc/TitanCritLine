# Roadmap

Design decisions deferred until there's a concrete reason to make them -
none of these block current compatibility or day-to-day use.

- Replace spell-name record keys with spell IDs and provide a migration.
- Decide whether HoT records should represent the full effect or the largest
  individual tick. The current code preserves the legacy aggregate behavior.
- Redesign the saved-variable schema and versioned migrations.
- Replace the static 40-row filter UI.
- Reduce the remaining global API surface and remove the `table` extension.

For what's already done, see [CHANGELOG.md](../CHANGELOG.md). For what's
still outstanding to actually verify in-game, see
[TESTING.md](TESTING.md).
