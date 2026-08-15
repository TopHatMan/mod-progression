# Unified Progression Architecture

`mod-progression` is becoming **Unified Progression**: one progression engine rather than several modules with overlapping hooks, SQL loaders and competing definitions of what is unlocked.

The repository name remains `mod-progression` during the rewrite.

## Design goal

For any player or realm, progression should be answerable from a small explicit state:

```text
scope + historical patch + level milestone
```

From that state the module should be able to answer two questions consistently:

1. What content should exist and be accessible?
2. For whom should that content be visible and usable?

No second module should be able to independently answer those questions differently.

## The three axes

### 1. Level progression

This replaces the large Boolean bracket matrix from `mod-progression-system` with one value:

```ini
Progression.LevelCap = 60
```

The intended ladder is:

`10 -> 20 -> 30 -> 40 -> 50 -> 60 -> 70 -> 80`

The module sets AzerothCore's maximum player level to the active milestone and uses runtime map/access rules where appropriate instead of mutating the same `disables` rows used by historical patch data.

### 2. Historical patch progression

```ini
Progression.Patch = 0
```

Patch progression describes the historical content timeline. During Vanilla this means 1.1 through 1.12 rather than broad custom phases.

The two availability rules are intentionally an intersection:

> content is available only when the level milestone allows it **and** the historical patch allows it.

Example: the level-50 stage is high enough for Maraudon, but patch 1.1 still keeps Maraudon closed. It becomes available when the realm or character is both at the appropriate level milestone and patch 1.2-or-later.

### 3. Progression scope

The merge of Individual Player Progression should decide **whose progression state is being evaluated**, not introduce another independent content model.

Planned scopes:

- `Server` — everyone shares the configured level/patch state.
- `Character` — each character has an individual state evaluated against the same unlock definitions.
- potentially `Account` — shared progression across characters if desired later.

Individual Player Progression contributes useful persistence, player-aware phasing and bot-aware behavior. Unified Progression remains authoritative for what a particular patch/milestone actually unlocks.

## Atomic unlock bundles

A historical feature must be represented as a logical bundle rather than a collection of unrelated SQL statements.

A bundle can contain:

- creatures,
- gameobjects,
- quest starters/endpoints,
- quest items and loot,
- vendors/trainers,
- conditions and disables,
- instance access,
- scripts/runtime rules.

All dependent pieces must advance together.

### Molten Core discovery example

The Vanilla audit exposed the failure mode clearly. The old data hides both Lothos Riftwaker and the Core Fragment before their unlock and restores both in the 1.3 layer. A temporary 1.1 correction restored Lothos without restoring the Core Fragment, allowing the quest to be accepted while its required object remained invisible.

That state is invalid even if each individual SQL line looks reasonable in isolation.

The rewrite therefore treats a progression unlock as an atomic feature: if a quest becomes available, every progression-controlled dependency required to complete it must be available in the same effective state.

## Deterministic state reconciliation

The existing implementation uses AzerothCore's DB updater to replay cumulative patch directories. `Progression.Reset = 1` currently clears `patch_*` updater records and executes the selected patch SQL again.

That is useful during development, but it is **not a complete rollback model** because SQL is replayed over an already-mutated world database.

The target architecture needs deterministic reconciliation:

```text
current database state
        +
selected progression state
        ↓
expected progression-owned state
        ↓
minimal repairs / validation
```

A progression change should therefore be safe in both directions:

```text
1.1 -> 1.3
1.3 -> 1.1
1.1 -> 1.12 -> 1.4
```

without relying on the administrator to remember which rows were changed by a previous patch.

### Ownership rule

Every field or row modified by progression should have one documented owner.

Examples:

- historical world visibility -> patch/content bundle
- level-cap access -> runtime level-gating layer
- character-specific visibility -> scope/phasing layer
- player damage/healing era adjustment -> one unified tuning subsystem

Two subsystems should never write competing values to the same progression-owned state.

## Validation

The module should validate important invariants at startup and during progression changes.

Planned checks include:

- content bundle has all required NPC/gameobject/quest dependencies,
- an unlocked quest does not depend on a progression-hidden object,
- historical content expected to be hidden is not accidentally left visible,
- phase masks owned by the module match the selected patch/scope,
- a level unlock does not bypass a historical patch restriction,
- only one subsystem owns player damage/healing adjustment,
- configuration values resolve to a valid patch and milestone.

Validation should report actionable IDs and expected/actual values rather than silently attempting broad database changes.

## Migrating `mod-progression-system`

The old module contains useful data and scripts, but its independent Boolean brackets should not be copied as-is.

Migration strategy:

1. **Instance milestone gates** — migrate to runtime level-cap rules.
2. **Level cap** — own through `Progression.LevelCap` and AzerothCore's max-player-level configuration.
3. **Patch-era endgame gates** — own through historical patch/content bundles.
4. **Special raid mechanics** — audit and port selectively so duplicate core scripts are not compiled.
5. **Bracket-specific loot/vendor/event SQL** — audit against the historical timeline before migration.
6. **Old down SQL** — replace with deterministic reconciliation wherever possible.

## Migrating Individual Player Progression

Individual Player Progression should be merged by capability rather than copied wholesale.

Preserve and adapt:

- character progression persistence,
- player-aware creature/gameobject visibility,
- restored historical encounters and quest chains,
- Playerbots integration,
- useful per-era mechanics that are not already owned by the patch engine.

Retire or consolidate:

- duplicate content timelines,
- duplicate phase-mask ownership,
- duplicate damage/healing scaling,
- database mutations that conflict with historical patch bundles,
- independent progression-stage definitions that describe the same unlock twice.

## Why level gating is runtime instead of another SQL unlock ladder

The old bracket module used baseline SQL to add map disables and later bracket SQL to delete them. That works when the level bracket is the only progression dimension.

It fails once historical patches and individual progression are added. A level unlock can delete a row that the historical layer still needs locked.

Runtime level checks avoid that collision while the historical layer remains authoritative for historical world state.

## Current recommended development configuration

For a Vanilla 1.1 realm while the audit is underway:

```ini
Progression.LevelGating.Enabled = 1
Progression.LevelCap = 60
Progression.Patch = 0
Progression.Reset = 0
```

Use `Progression.Reset = 1` only deliberately while testing SQL reapplication, then return it to `0`.

## Admin visibility

Use:

```text
.progression info
```

to see the active patch ID, level-gating state, effective level cap, patch-era cap and SQL reset state.

The finished rewrite should expand this command so it can also report progression scope, effective character state and validation failures.
