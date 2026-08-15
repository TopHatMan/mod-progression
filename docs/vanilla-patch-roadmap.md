# Vanilla Patch Accuracy Roadmap

The current goal is to make `mod-progression` emulate the **historical Vanilla patch cycle** while running on AzerothCore/3.3.5.

The restored historical SQL is useful source material, but it is not assumed to be correct. Each patch must be audited against historical patch notes, known content-release timing and the behavior available in AzerothCore.

## Status

| Patch | Historical layer restored | Accuracy audit | Priority |
|:---:|:---:|:---:|---|
| 1.1 | Yes | In progress | **Current live server** |
| 1.2 | Yes | Pending | Next |
| 1.3 | Yes | Pending | Next |
| 1.4 | Yes | Pending | High |
| 1.5 | Yes | Pending | High |
| 1.6 | Yes | Pending | High |
| 1.7 | Yes | Pending | High |
| 1.8 | Yes | Pending | High |
| 1.9 | Yes | Pending | High |
| 1.10 | Yes | Pending | High |
| 1.11 | Yes | Pending | High |
| 1.12 | Yes | Pending | High |

## Historical progression target

The working patch ladder is:

- **1.1 — World of Warcraft:** launch-era leveling, Molten Core, Onyxia and launch dungeons.
- **1.2 — Mysteries of Maraudon:** Maraudon and its related content.
- **1.3 — Ruins of the Dire Maul:** Dire Maul; audit Azuregos, Kazzak, meeting stones and related additions.
- **1.4 — The Call to War:** PvP Honor System; audit Children's Week, Gurubashi Arena changes, elemental invasions and class quest additions.
- **1.5 — Battlegrounds:** Warsong Gulch and Alterac Valley; audit the 1.5 honor-system changes and world hubs.
- **1.6 — Assault on Blackwing Lair:** Blackwing Lair and Darkmoon Faire-era content.
- **1.7 — Rise of the Blood God:** Zul'Gurub and Arathi Basin-era content.
- **1.8 — Dragons of Nightmare:** Nightmare dragons and related world changes.
- **1.9 — The Gates of Ahn'Qiraj:** AQ war effort/opening state, AQ20/AQ40 and associated world/content changes.
- **1.10 — Storms of Azeroth:** weather and dungeon-set upgrade era.
- **1.11 — Shadow of the Necropolis:** Naxxramas and Scourge Invasion.
- **1.12 — Drums of War:** Silithus/EPL world PvP and late-Vanilla systems.

This list is an audit framework, not a claim that every existing SQL row is already historically correct.

## What to audit for every patch

### World and content availability
- Creature spawns and phase masks
- Gameobject spawns
- Dungeon and raid access
- World bosses
- Quest starters/enders and quest chains
- Flight masters, transports and zone hubs
- Seasonal/world events

### Items and economy
- Vendor inventories
- Reputation vendors
- Loot tables and drop locations
- Recipes and profession trainers
- Item stats/availability where server-side data can reproduce the historical version
- Auction-house NPC availability and behavior

### Classes and combat
- Trainer spell availability
- Rank availability
- Server-side spell data that can safely be backported
- Damage/healing approximation required because the core is 3.3.5
- Talent differences: document separately where client DBC changes are required

### PvP
- Honor system on/off
- Rank rewards
- Battleground availability
- Battleground marks/rewards
- Arathi/Alterac rule changes
- World PvP objectives

### Quality-of-life and core features
- Weather
- Quest markers/sparkles/POI
- Meeting stones / group-finding behavior
- Mail expiration
- XP-to-gold at level cap
- Dual spec, Dungeon Finder and later-expansion systems
- Expansion and level-cap enforcement

## 1.1 audit: immediate issues

### Fixed
- **Lothos Riftwaker (14387):** historical SQL incorrectly left him hidden with `phaseMask = 16384`. 1.1 correction restores him.
- **Rokaro (10182) / Emberstrife (10321):** restored with the same launch-era Onyxia attunement correction.

### Next checks
1. Verify every Molten Core and Onyxia attunement NPC/quest required by the launch content is present.
2. Verify Maraudon is actually unavailable until 1.2.
3. Verify Dire Maul, Azuregos and Kazzak stay unavailable until their intended patch.
4. Audit 1.1 vendor inventories so later recipes/items do not leak into the launch economy.
5. Audit trainer spells and profession recipes for later-patch additions.
6. Audit holiday/event tables so later events do not accidentally run at 1.1.
7. Check later-expansion NPC leakage not covered by the existing hidden-content list.

## Loader reliability

A patch emulator is useless if the database layers silently fail to run. The loader therefore must:

- auto-detect the actual module source folder;
- support both `mod-progression` and `mod-02-progression`;
- validate every selected patch SQL directory before invoking `DBUpdater`;
- log the active patch and cumulative directory count;
- log missing directories as errors instead of silently skipping them;
- allow `Progression.Reset = 1` to reapply `patch_*` SQL while developing.

## Evidence policy

For future patch audits:

- Prefer archived/original Blizzard patch notes when available.
- Use Blizzard's Classic historical/re-release documentation as corroboration.
- Use Warcraft Wiki/Wowpedia-style archives when original Blizzard pages are unavailable, and label those findings as secondary.
- Treat the old module's patch SQL and embedded patch notes as implementation history, not authoritative historical evidence.

## Known client/core limitation

This project runs on the 3.3.5 client and AzerothCore. Some authentic patch differences cannot be reproduced only with world SQL. Those should be classified as:

- **Exact** — reproduce directly in DB/core configuration.
- **Approximation** — reproduce the player-facing effect with server code.
- **Client patch required** — requires DBC/client data changes.
- **Not practical** — document rather than fake it.

The objective is a coherent historical progression experience, not pretending the 3.3.5 client is byte-for-byte a 1.1 client.
