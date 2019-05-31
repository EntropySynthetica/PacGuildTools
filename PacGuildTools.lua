
-- Load Required Libraries
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
local chat = LibChatMessage.Create("PacGuildTools", "PGT")
--local LIBMW = LibStub:GetLibrary("LibMsgWin-1.0")

-- Initialize our Namespace Table
PacsAddon = {}

PacsAddon.name = "PacGuildTools"
PacsAddon.version = "1.3.0"
PacsAddon.raffledescText = [[
This addon allows you to run raffles, randomly picking a winner.  There are three raffle modes currently supported.
    
* Participants can sign up to a raffle roster via a magic word.  They simply need to type that word in chat to enter.
* A raffle can be run for all members in a guild.
* A raffle can be run for all online members in a guild. 
    
Raffle Commands:
/pgt_raffle_online   - Run a raffle with those online in the guild.
/pgt_raffle_guild    - Run a raffle with everyone in the guild.
/pgt_raffle          - Run a raffle with those on the roster.
                    
/pgt_raffle_show   Show the raffle roster.
/pgt_rafflw_clear   Clear the Raffle Roster.
    
* A blank magic word will enter everyone who types in chat.  
]]


-- Function to Restore Clock to last saved Position
function PacsAddon:ClockRestorePosition()
    local left = PacsAddon.savedVariables.clockLeft
    local top = PacsAddon.savedVariables.clockTop

    PacsAddOnGUI:ClearAnchors()
    PacsAddOnGUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end


-- Initialize our Variables
function PacsAddon:Initialize()
    PacsAddon.CreateSettingsWindow()

    time = os.date("%m/%d/%Y %H:%M:%S")

    PacsAddon.savedVariables = ZO_SavedVars:NewAccountWide("PacGuildToolsSavedVariables", 1, nil, {})

    enableDebug = PacsAddon.savedVariables.enableDebug
    activeGuild = PacsAddon.savedVariables.activeGuild
    activeGuildID = PacsAddon.savedVariables.activeGuildID

    -- Check if Clock should be enabled or not
    PacsAddon.clockEnabled()

    --Update the position of the clock
    PacsAddon:ClockRestorePosition()


    PacsAddon.raffleParticipants = {}

    -- Set default magic word for Raffles.
    if isempty(PacsAddon.savedVariables.raffleMagicWord) then
        PacsAddon.savedVariables.raffleMagicWord = "EnterRaffle"
    end

    -- If this is the first run, or the saved settings file is missing lets set the first guild as the default
    if isempty(activeGuildID) then
        activeGuildID = GetGuildId(1)
        activeGuild = GetGuildName(activeGuildID)
        PacsAddon.savedVariables.activeGuild = activeGuild
        PacsAddon.savedVariables.activeGuildID = activeGuildID
    end

    -- -- Currently the Saved Settings saves the Guilds Name.  Lets grab the active guilds index ID.  
    -- for guildIndex = 1, 5 do
    --     if activeGuild == GetGuildName(guildIndex) then
    --         PacsAddon.savedVariables.activeGuildID = guildIndex
    --     end
    -- end

    -- Grab the active guilds name and number of members from the ESO API
    guildName = GetGuildName(activeGuildID)
    guildMemberNum = GetNumGuildMembers(activeGuildID)


    --ZO_ChatSystem_AddEventHandler(EVENT_CHAT_MESSAGE_CHANNEL, ChatMessageChannel)
    ZO_PreHook(ZO_ChatSystem_GetEventHandlers(), EVENT_CHAT_MESSAGE_CHANNEL, ChatMessageChannel)

    PacsAddon.savedVariables.lastUpdate = time

    --local myMsgWindow = LIBMW:CreateMsgWindow("PacGuildTools", "Pacrooti's Guild Tools", 0, 0)
    --myMsgWindow:AddText("Heres a chat message in red", 1, 0, 0)

    chat:SetEnabled(true)

    -- Debug output if we have that enabled. 
    if enableDebug == true then
        d("Active Guild " .. activeGuild)
        d("Active Guild ID " .. activeGuildID)
        d("PacGuildTools Init Finished")
        d(time)
    end
end


-- Run when Addon Loads
function PacsAddon.OnAddOnLoaded(event, addonName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName == PacsAddon.name then
        PacsAddon:Initialize()
    end
end


-- Summon Pacrooti!!!
function PacsAddon.summon_pacrooti(extra)
    SetCrownCrateNPCVisible(true)
end


-- Dismiss Pacrooti
function PacsAddon.dismiss_pacrooti(extra)
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


-- Function to Check if a Variable is empty
function isempty(s)
    return s == nil or s == ''
end


-- Update Guild Roster in Saved Variables
function UpdateGuildRoster(extra)
    local activeGUildID = PacsAddon.savedVariables.activeGuildID
    local enableDebug = PacsAddon.savedVariables.enableDebug
    -- local guildName = GetGuildName(activeGuildID)
    local guildMemberNum = GetNumGuildMembers(activeGuildID)

    -- Grab the guild roster from the ESO API
    local masterList = {}
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
                        rankName = GetGuildRankCustomName(activeGuildID, rankIndex),
                        status = status,
                        statusString = statusString,
                        secsSinceLogoff = secsSinceLogoff,
                        logoffString = SecondsToClock(secsSinceLogoff),
                    }
        masterList[guildMemberIndex] = data
    end

    PacsAddon.savedVariables.guildRoster = masterList

    if enableDebug == true then
        d("Updated Saved Var Guild roster with " .. guildMemberNum .. " members.")
    end
end


-- Check chat for magic word and enter those folks in the raffle. 
function ChatMessageChannel(messageType, fromName, text, isCustomerService, fromDisplayName)
    local magicWord = PacsAddon.savedVariables.raffleMagicWord

    if string.match(text, magicWord) then
        if tablesearch(fromDisplayName, PacsAddon.raffleParticipants) then
            chat:SetTagColor("ffb600"):Print(fromDisplayName .. " has already entered")
        else
            table.insert(PacsAddon.raffleParticipants, fromDisplayName)
            chat:SetTagColor("ffb600"):Print(fromDisplayName .. " has been entered!")
        end

    end
end


-- Show who is on the Raffle Roster
function PacsAddon.pgt_raffle_show()
    chat:SetTagColor("ffb600"):Print("The Following Have Entered the Raffle.")
    for index,value in pairs(PacsAddon.raffleParticipants) do
        chat:SetTagColor("ffb600"):Print(value)
    end
end


-- Clear raffle roster
function PacsAddon.pgt_raffle_clear()
    PacsAddon.raffleParticipants = {}
    chat:SetTagColor("ffb600"):Print("Raffle Roster has been cleared.")
end


-- Run Raffle From Roster
function PacsAddon.pgt_raffle()
    if next(PacsAddon.raffleParticipants) == nil then
        chat:SetTagColor("ffb600"):Print("Nobody has entered the raffle.")
    else
        local winnerName = PacsAddon.raffleParticipants[math.random(#PacsAddon.raffleParticipants)]
        chat:SetTagColor("ffb600"):Print("Winner is " .. winnerName)
    end
end


-- Run Raffle from all Guild Roster
function PacsAddon.pgt_raffle_guild()
    local activeGuildID = PacsAddon.savedVariables.activeGuildID
    guildMemberNum = GetNumGuildMembers(activeGuildID)
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
    chat:SetTagColor("ffb600"):Print("Winner is " .. winnerName .. " and is " .. statusString)
end


-- Run Raffle from online guild members
function PacsAddon.pgt_raffle_online()
    activeGuildID = PacsAddon.savedVariables.activeGuildID
    guildMemberNum = GetNumGuildMembers(activeGuildID)
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

    chat:SetTagColor("ffb600"):Print("Winner is " .. winnerName)
end


-- Return Current Time
function PacsAddon.currentTimeShort()
    local time = os.date(" %I:%M:%S %p")
    PacsAddOnGUIClock:SetText(time)
    --d(time)
end


-- Save Clock Position when done moving
function PacsAddon.OnClockMoveStop()
    PacsAddon.savedVariables.clockLeft = PacsAddOnGUI:GetLeft()
    PacsAddon.savedVariables.clockTop = PacsAddOnGUI:GetTop()
end


-- Check if Clock should be enabled or not
function PacsAddon.clockEnabled()
    if (PacsAddon.savedVariables.enableClock == true) then
        PacsAddOnGUI:SetHidden(false)
    else
        PacsAddOnGUI:SetHidden(true)
    end
end


-- Search Table if string exist in it
function tablesearch(data, array)
    local valid = {}
    for i = 1, #array do
        valid[array[i]] = true
    end
    if valid[data] then
        return true
    else
        return false
    end
end


-- function PacsAddonUpdate()
--     PacAddonIndicatorCount:SetText("Test Text \n test text 2")
-- end


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
        local guildID = GetGuildId(guildIndex)
        local guildName = GetGuildName(guildID)
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
            tooltip = "The selected guild will be used for Raffle and Bank History Export features.",
            choices = guildNames,
            getFunc = function() return PacsAddon.savedVariables.activeGuild end,
            setFunc = function(newValue) PacsAddon.savedVariables.activeGuild = newValue end,
        },

        [3] = {
            type = "header",
            name = "Raffle Settings",
        },

        [4] = {
            type = "description",
            text = PacsAddon.raffledescText,
            width = "full",	--or "half" (optional),
        },

        [5] = {
            type = "editbox",
            name = "Magic Word to get on Raffle Roster",
            default = true,
            getFunc = function() return PacsAddon.savedVariables.raffleMagicWord end,
            setFunc = function(newValue) PacsAddon.savedVariables.raffleMagicWord = newValue end,
        },

        [6] = {
            type = "header",
            name = "Misc Settings",
        },

        [7] = {
            type = "checkbox",
            name = "Enable Clock",
            default = false,
            getFunc = function() return PacsAddon.savedVariables.enableClock end,
            setFunc = function(newValue) PacsAddon.savedVariables.enableClock = newValue end,
        },

        [8] = {
            type = "header",
            name = "Debug Messages",
        },

        [9] = {
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
SLASH_COMMANDS["/pgt_raffle"] = PacsAddon.pgt_raffle
SLASH_COMMANDS["/pgt_raffle_online"] = PacsAddon.pgt_raffle_online
SLASH_COMMANDS["/pgt_raffle_guild"] = PacsAddon.pgt_raffle_guild
SLASH_COMMANDS["/pgt_raffle_show"] = PacsAddon.pgt_raffle_show
SLASH_COMMANDS["/pgt_raffle_clear"] = PacsAddon.pgt_raffle_clear
SLASH_COMMANDS["/summon_pacrooti"] = PacsAddon.summon_pacrooti
SLASH_COMMANDS["/dismiss_pacrooti"] = PacsAddon.dismiss_pacrooti

EVENT_MANAGER:RegisterForEvent(PacsAddon.name, EVENT_ADD_ON_LOADED, PacsAddon.OnAddOnLoaded)