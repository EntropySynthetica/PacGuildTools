
-- Required Libraries
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

-- Initialize our Namespace Table
PacsAddon = {}

PacsAddon.name = "PacGuildTools"
PacsAddon.version = "1.0.0"

-- Initialize our Variables
function PacsAddon:Initialize()
    PacsAddon.CreateSettingsWindow()

    PacsAddon.savedVariables = ZO_SavedVars:NewAccountWide("PacGuildToolsSavedVariables", 1, nil, {})

    enableDebug = PacsAddon.savedVariables.enableDebug
    activeGuild = PacsAddon.savedVariables.activeGuild

    -- If this is the first run, or the saved settings file is missing lets set the first guild as the default
    if isempty(activeGuild) then
        activeGuild = GetGuildName(1)
        PacsAddon.savedVariables.activeGuild = activeGuild
    end

    -- Currently the Saved Settings saves the Guilds Name.  Lets grab the active guilds index ID.  
    for guildIndex = 1, 5 do
        if activeGuild == GetGuildName(guildIndex) then
            activeGuildID = guildIndex
        end
    end

    -- Grab the active guilds name and number of members from the ESO API
    guildName = GetGuildName(activeGuildID)
    guildMemberNum = GetNumGuildMembers(activeGuildID)

    -- Grab the guild roster from the ESO API
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

    -- Save the Guild Roster to the saved settings file so we can convert it to CSV outside of ESO.  The saved settings file is only 
    -- written to when logging out, or doing a /reloadui
    PacsAddon.savedVariables.guildRoster = masterList

    -- Debug output if we have that enabled. 
    if enableDebug == true then
        d("PacGuildTools Initialized")
        d("Active Guild " .. activeGuild)
        d("Active Guild ID " .. activeGuildID)
    end
end


function PacsAddon.OnAddOnLoaded(event, addonName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName == PacsAddon.name then
        PacsAddon:Initialize()
    end
end


-- This function runs when typing /pgt_raffle
function pgt_raffle(extra)

    -- Figure out which guild is the active one, and if the winner must be online. 
    local mustBeOnline = PacsAddon.savedVariables.mustBeOnline
    local activeGuild = PacsAddon.savedVariables.activeGuild
    local guildMemberNum = GetNumGuildMembers(activeGuildID)

    for guildIndex = 1, 5 do
        if activeGuild == GetGuildName(guildIndex) then
            activeGuildID = guildIndex
        end
    end
    
    -- If the member must be online we run the raffle and check their status.  We keep re-running the raffle until we get an online winner. 
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

            -- Todo, enable the following to print when debug is on.  
            -- d("Debug Winner is " .. winnerName .. " and is " .. statusString .. " " .. status)
        until(status ~= 4)

        d("Winner is " .. winnerName)

    -- If member must be online is false we will just pick and display the first winner, along with their online status. 
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

-- Summon Pacrooti!!!
function summon_pacrooti(extra)
    SetCrownCrateNPCVisible(true)
end

-- Dismiss Pacrooti
function dismiss_pacrooti(extra)
    SetCrownCrateNPCVisible(false)
end

-- Convert Seconds to Hours, Min, Seconds
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

-- Check if a Variable is empty
function isempty(s)
    return s == nil or s == ''
end


--  Settings Menu Function via LibAddonMenu-2.0
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
        },

        [5] = {
            type = "header",
            name = "Debug Messages",
        },

        [6] = {
            type = "checkbox",
            name = "Enable Debug Messages",
            default = false,
            getFunc = function() return PacsAddon.savedVariables.enableDebug end,
            setFunc = function(newValue) PacsAddon.savedVariables.enableDebug = newValue end,
        }
    }

    LAM2:RegisterOptionControls("PacsAddon_settings", optionsData)
 
end

-- Register our slash commands
SLASH_COMMANDS["/pgt_raffle"] = pgt_raffle
SLASH_COMMANDS["/summon_pacrooti"] = summon_pacrooti
SLASH_COMMANDS["/dismiss_pacrooti"] = dismiss_pacrooti

EVENT_MANAGER:RegisterForEvent(PacsAddon.name, EVENT_ADD_ON_LOADED, PacsAddon.OnAddOnLoaded)