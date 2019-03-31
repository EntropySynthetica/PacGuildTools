SavedVar = require("PacGuildTools")
json = require("json")

output = json.encode(PacGuildToolsSavedVariables)

file = io.open("SavedVarOutput.json", "w")
file:write(output)
file:close(file)