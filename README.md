# Progression

This fork turns `mod-progression` back into a **server-wide patch progression module**.

Instead of broad custom phases, the server selects a historical World of Warcraft patch and applies every patch data layer up to that point. The immediate development target is Vanilla (`1.1` through `1.12`) on an AzerothCore 3.3.5 server.

## Configuration

Set the active patch in `mod_progression.conf`:

```ini
Progression.Patch = 0
```

Patch `0` is **1.1: World of Warcraft**.

Patch SQL is cumulative. For example, selecting patch `5` (1.6) applies the SQL layers for 1.1, 1.2, 1.3, 1.4, 1.5 and 1.6 in order.

The module auto-detects both supported source folder names:

- `mod-02-progression` — Ashbringer/module-ordering layout
- `mod-progression` — normal AzerothCore layout

If you use another folder name, set `Progression.ModuleDirectory`.

## Patch map

### Vanilla

| ID | Patch | Title |
|---:|:---:|---|
| 0 | 1.1 | World of Warcraft |
| 1 | 1.2 | Mysteries of Maraudon |
| 2 | 1.3 | Ruins of the Dire Maul |
| 3 | 1.4 | The Call to War |
| 4 | 1.5 | Battlegrounds |
| 5 | 1.6 | Assault on Blackwing Lair |
| 6 | 1.7 | Rise of the Blood God |
| 7 | 1.8 | Dragons of Nightmare |
| 8 | 1.9 | The Gates of Ahn'Qiraj |
| 9 | 1.10 | Storms of Azeroth |
| 10 | 1.11 | Shadow of the Necropolis |
| 11 | 1.12 | Drums of War |

TBC and Wrath patch SQL has also been restored as a foundation, but the active accuracy audit is currently focused on Vanilla.

## Accuracy model

A 3.3.5 client/core cannot literally become a 1.1 client. The goal is to emulate the historical server experience as closely as practical:

1. **Exact data gating** — creatures, gameobjects, quests, vendors, recipes, loot, dungeon/raid access, world bosses and events.
2. **Core/runtime rules** — level/expansion limits, honor availability, weather, quest UI behavior, battleground rules and other settings AzerothCore exposes.
3. **Server-side approximations** — damage/healing scaling and other behavior where 3.3.5 mechanics differ materially.
4. **Client-limited behavior** — documented explicitly when the 3.3.5 client prevents faithful emulation.

See `docs/vanilla-patch-roadmap.md` for the audit plan and known gaps.

## SQL loading and reset

The module uses AzerothCore's database updater to load the selected patch directories. Startup logging now reports the resolved module source directory and how many cumulative patch directories were queued.

During development, this can be used to force patch SQL to re-run:

```ini
Progression.Reset = 1
```

After the desired SQL has been reapplied successfully, turn it back off:

```ini
Progression.Reset = 0
```

## Current 1.1 correction

The historical patch SQL hid Lothos Riftwaker, Rokaro and Emberstrife even though Molten Core and Onyxia's Lair belong to the launch-era 1.1 content set. A final 1.1 correction layer restores those NPCs to the normal world phase.

This is the first of a larger Vanilla patch-by-patch audit.
