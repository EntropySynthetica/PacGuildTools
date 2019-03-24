-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

PacsAddon = {}

PacsAddon.name = "PacGuildTools"
PacsAddon.version = 1

-- Initialize our Variables
function PacsAddon:Initialize()
    PacsAddon.CreateSettingsWindow()

    PacsAddon.savedVariables = ZO_SavedVars:NewAccountWide("PacGuildToolsSavedVariables", 1, nil, {})


    activeGuild = PacsAddon.savedVariables.activeGuild
    for guildIndex = 1, 5 do
        if activeGuild == GetGuildName(guildIndex) then
            activeGuildID = guildIndex
        end
    end

    guildName = GetGuildName(activeGuildID)
    guildMemberNum = GetNumGuildMembers(activeGuildID)

    masterList = {}
    for guildMemberIndex = 1, guildMemberNum do
        local displayName, note, rankIndex, status, secsSinceLogoff = GetGuildMemberInfo(activeGuildID, guildMemberIndex)

        if status == 1 then
            statusString = "Online"
        elseif status == 2 then
            statusString = "Away"
        elseif status == 3 then
            statusString = "Do Not Distrub"
        elseif status == 4 then
            statusString = "Offline"
        end

        local data = {
                        index = guildMemberIndex,
                        displayName = displayName,
                        note = note,
                        rankIndex = rankIndex,
                        status = status,
                        statusString = statusString,
                        secsSinceLogoff = secsSinceLogoff,
                        logoffString = SecondsToClock(secsSinceLogoff),
                    }
        masterList[guildMemberIndex] = data

    end

    
    PacsAddon.savedVariables.guildRoster = masterList
    d("PacGuildTools Initialize")
    d("Active Guild " .. activeGuild)
    d("Active Guild ID " .. activeGuildID)
end


function PacsAddon.OnAddOnLoaded(event, addonName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName == PacsAddon.name then
        PacsAddon:Initialize()
    end
end


-- This function runs when typing /pgt_raffle
function pgt_raffle(extra)

    local mustBeOnline = PacsAddon.savedVariables.mustBeOnline
    local activeGuild = PacsAddon.savedVariables.activeGuild
    local guildMemberNum = GetNumGuildMembers(activeGuildID)

    for guildIndex = 1, 5 do
        if activeGuild == GetGuildName(guildIndex) then
            activeGuildID = guildIndex
        end
    end
    
    if mustBeOnline == true then
        repeat
            local rafflewinner = math.random(1, guildMemberNum)
            local displayName, note, rankIndex, status, secsSinceLogoff = GetGuildMemberInfo(activeGuildID, rafflewinner)
            winnerName = displayName
            if status == 1 then
                statusString = "Online"
            elseif status == 2 then
                statusString = "Away"
            elseif status == 3 then
                statusString = "Do Not Distrub"
            elseif status == 4 then
                statusString = "Offline"
            end

            -- d("Debug Winner is " .. winnerName .. " and is " .. statusString .. " " .. status)
        until(status ~= 4)

        d("Winner is " .. winnerName .. " and is " .. statusString)

    else
        local rafflewinner = math.random(1, guildMemberNum)
        local displayName, note, rankIndex, status, secsSinceLogoff = GetGuildMemberInfo(activeGuildID, rafflewinner)
        winnerName = displayName
        if status == 1 then
            statusString = "Online"
        elseif status == 2 then
            statusString = "Away"
        elseif status == 3 then
            statusString = "Do Not Distrub"
        elseif status == 4 then
            statusString = "Offline"
        end
        d("Winner is " .. winnerName .. " and is " .. statusString)
    end
end

function SecondsToClock(seconds)
    local seconds = tonumber(seconds)
  
    if seconds <= 0 then
      return "00:00:00";
    else
      hours = string.format("%02.f", math.floor(seconds/3600));
      mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
      secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
      return hours..":"..mins..":"..secs
    end
end

-------------------------------------------------------------------------------------------------
--  Menu Functions --
-------------------------------------------------------------------------------------------------
function PacsAddon.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Pacrooti's Guild Tools",
        displayName = "Pacrooti's Guild Tools",
        author = "Erica Z",
        version = PacsAddon.version,
        slashCommand = "/pgt",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local cntrlOptionsPanel = LAM2:RegisterAddonPanel("PacsAddon_settings", panelData)

    guildNames = {}
    for guildIndex = 1, 5 do
        local guildName = GetGuildName(guildIndex)
        table.insert(guildNames, guildName)
    end


    local optionsData = {
        [1] = {
            type = "header",
            name = "Guild Selection",
        },

        [2] = {
            type = "dropdown",
            name = "Select active guild",
            tooltip = "Dropdown's tooltip text.",
            choices = guildNames,
            getFunc = function() return PacsAddon.savedVariables.activeGuild end,
            setFunc = function(newValue) PacsAddon.savedVariables.activeGuild = newValue end,
        },

        [3] = {
            type = "header",
            name = "Raffle Settings",
        },

        [4] = {
            type = "checkbox",
            name = "Must be Online to Win",
            default = true,
            getFunc = function() return PacsAddon.savedVariables.mustBeOnline end,
            setFunc = function(newValue) PacsAddon.savedVariables.mustBeOnline = newValue end,
        }
    }

    LAM2:RegisterOptionControls("PacsAddon_settings", optionsData)
 
end


SLASH_COMMANDS["/pgt_raffle"] = pgt_raffle

EVENT_MANAGER:RegisterForEvent(PacsAddon.name, EVENT_ADD_ON_LOADED, PacsAddon.OnAddOnLoaded)