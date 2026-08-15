# Unified Progression Architecture

`mod-progression` is becoming the single progression module rather than requiring multiple modules with overlapping hooks and database loaders.

## The three layers

### 1. Level progression

This replaces the large Boolean bracket matrix from `mod-progression-system` with one value:

```ini
Progression.LevelCap = 60
```

The intended ladder is:

`10 -> 20 -> 30 -> 40 -> 50 -> 60 -> 70 -> 80`

The module sets AzerothCore's maximum player level to the active milestone and uses `OnPlayerCanEnterMap` to enforce dungeon/raid milestone access without mutating the same `disables` rows used by historical patch SQL.

### 2. Historical patch progression

```ini
Progression.Patch = 0
```

Patch SQL handles historical content state. During Vanilla this means 1.1 through 1.12 rather than broad custom phases.

The two rules are intentionally an intersection:

> content is available only when the level milestone allows it **and** the historical patch allows it.

Example: the level-50 stage is high enough for Maraudon, but patch 1.1 still keeps Maraudon closed. It becomes available when the server is both at the level-50-or-higher milestone and patch 1.2-or-later.

### 3. Progression scope (next merge)

The eventual merge of individual progression should decide **whose progression state is being evaluated**, not introduce a third independent content model.

Planned scopes:

- `Server` — everyone shares the configured level/patch state.
- `Character` — individual character progression, based on the same content rules.
- potentially `Account` — shared progression across characters if desired later.

This lets the individual-progression module contribute persistence/phasing mechanics while the unified module remains the one source of truth for what each stage actually unlocks.

## Migrating `mod-progression-system`

The old module contains useful data and scripts, but its 39 independent Boolean brackets should not be copied as-is. The migration strategy is:

1. **Instance milestone gates** — migrated to runtime level-cap rules. This is now implemented for the Vanilla/TBC/Wrath instance IDs represented by the old baseline `disables` file.
2. **Level cap** — migrated to `Progression.LevelCap` and AzerothCore `CONFIG_MAX_PLAYER_LEVEL`.
3. **Patch-era endgame gates** — owned by the historical patch SQL already restored in this repository.
4. **Special raid mechanics** — audit and port selectively (Molten Core rune handling, Kazzak behavior, SSC/Tempest Keep requirements, etc.) so we do not compile duplicate core scripts.
5. **Bracket-specific loot/vendor/event SQL** — audit against the historical patch timeline before porting. These files often overlap the same tables as patch SQL and cannot safely be bulk-copied.
6. **Old `down` SQL** — retire where runtime gating or deterministic patch SQL makes it unnecessary.

## Why level gating is runtime instead of another SQL unlock ladder

The old bracket module used a baseline SQL file to add map disables and later bracket SQL to `DELETE` those disables. That works when level bracket is the only progression dimension.

It fails once historical patches are added. A level unlock could delete a row that the patch layer still needs locked. Runtime level checks avoid that collision entirely, while patch SQL remains authoritative for historical world state.

## Current recommended configuration

For the current Vanilla 1.1 server:

```ini
Progression.LevelGating.Enabled = 1
Progression.LevelCap = 60
Progression.Patch = 0
```

That keeps the server at level 60 and patch 1.1 while the Vanilla patch audit continues.

## Admin visibility

Use:

```text
.progression info
```

to see the active patch ID, level-gating state, effective level cap, patch-era cap, and SQL reset state.
