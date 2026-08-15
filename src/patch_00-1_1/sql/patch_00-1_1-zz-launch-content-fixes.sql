-- Patch 1.1 launch-content corrections.
-- Onyxia's Lair was available at launch, so launch-era Onyxia attunement NPCs
-- must not remain in the module's hidden-content phase.
--
-- Lothos Riftwaker is intentionally NOT restored here: Lothos and the Molten Core
-- discovery/shortcut attunement were added in patch 1.3, where the existing 1.3
-- creature/gameobject layers restore Lothos (14387) and Core Fragment (179553).
UPDATE `creature` SET `phaseMask` = 1 WHERE `id1` IN (
    10182, -- Rokaro <Champion of the Horde>
    10321  -- Emberstrife
);
