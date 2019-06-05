# Pacrooti's Guild Tools
ESO Addon for Guild Roster Management by Erica Zavaleta, @LadyWinry

# How to Install
* The most recent build can be downloaded from this link,  https://github.com/EntropySynthetica/PacGuildTools/archive/master.zip
* Open the zip and copy the folder to Documents/Elder Scrolls Online/live/AddOns
* Rename the directory from PacGuildTools-Master to PacGuildTools 

# Requirements
Download the following Libraries are required for this addon to function. They can be downloaded from Minion or esoui.com 
* LibAddonMenu
* LibChatMessage

# New in this version
* Added Chat spam
* Split off Banking tools into another addon. 
* Changed app to support Libaddonmenu and libchatmessage as downloaded from Minion.
* All non debug messages are now presented thru libchatmessage.  
* Added GUild Welcome Message

# Current Features
* A realtime Clock
* Guild Roster Raffle Generator
* Chat spam messages
* Guild Welcome Message

# Todo
* Refactor the code and make sure all variables are in a proper namespace.
* After Elsweyr patch selecting a different guild is currently not working.  The app will default to whatever your first guild is.  

# How to use chat spam messages. 
Use the /pgt command to bring up Pacrooti's Guild Tools Settings. Enter your messages.  

To send a message type /pgt_spam followed by the message number and guild number.  For example, to send message 1 to your second guild
type /pgt_spam1g2

# How to enter a welcome message. 
Enter a welcome message and turn on the guilds that can trigger the welcome upon a member joining. The variable ${name} can be used to insert the joining persons @ name into the welcome message.  The varible ${guild} can be used to insert the name of the guild that was joined into the welcome message.  The welcome message will always be put into the guild channel that was joined. 

# How to run a raffle
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


# Valid Slash Commands
Opens the Pacrooti's Guild Tools Menu
* /pgt

Runs a raffle               
* /pgt_raffle
Runs a raffle for everyone online in the guild
* /pgt_raffle_online
Runs a raffle for everyone in the guild
* /pgt_raffle_guild

Summons Pacrooti to your position!       
* /summon_pacrooti  

Sends Pacrooti Away
* /dismiss_pacrooti  

