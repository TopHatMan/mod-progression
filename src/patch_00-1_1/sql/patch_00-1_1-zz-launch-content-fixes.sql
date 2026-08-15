-- Patch 1.1 launch-content corrections.
-- Molten Core and Onyxia's Lair were available at launch, so their attunement NPCs
-- must not remain in the module's hidden-content phase.
UPDATE `creature` SET `phaseMask` = 1 WHERE `id1` IN (
    10182, -- Rokaro <Champion of the Horde>
    10321, -- Emberstrife
    14387  -- Lothos Riftwaker
);
