-- github.com/cxmplex

local f=CreateFrame("Frame");
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

local disabled
last_command_received = ""

local function getHealPower()
    local heal_power = GetSpellBonusDamage(7)
    local spell_power = GetSpellBonusHealing()

    if spell_power > heal_power then
        return spell_power
    else
        return heal_power
    end
end

local function calculateMaxHeal()
    local total_heal = 0
    --iterate max possible 40 raid members
    for i = 1, 40 do
        local power = getHealPower() * 2
        local unit = "raid" .. i
        if UnitExists(unit) and IsSpellInRange(115310, "spell", unit) then --check to see if in range of revival
            local healable_hp = UnitHealthMax(unit) - UnitHealth(unit)
            if healable_hp < power then
                total_heal = total_heal + healable_hp
            else
                total_heal = total_heal + power
            end
        end
    end
    return total_heal
end

-- On combat enable/disable
f:SetScript("OnEvent", function(self, event)
    if event=="PLAYER_REGEN_DISABLED" then
        disabled = 1
    elseif event=="PLAYER_REGEN_ENABLED" then
        if last_command_received and last_command_received == "d" then
            disabled = 1
        else
            disabled = 0
        end
    end
    --verify spell is not on cd
    local _, duration, _, _ = GetSpellCooldown(115310, "spell")
    if disabled == 0 and duration == 0 then
        local total_heal = calculateMaxHeal()
        print("Revival can be cast for " .. total_heal)
    end
end)

function HPEAddonCommands(msg, _)
    local _, _, cmd, _ = string.find(msg, "%s?(%w+)%s?(.*)")
    if cmd == "e" then
        disabled = 0
        last_command_received = cmd
    elseif cmd == "d" then
        disabled = 1
        last_command_received = cmd
    else
        print("Please enter a valid command.")
    end
end

SLASH_HPE1 = "/hpe"
SlashCmdList["HPE"] = HPEAddonCommands
