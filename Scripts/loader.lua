local HttpGet = game.HttpGet
local GameId: number = game.GameId

local Games: {[number]: string} = loadstring(
  HttpGet(game, "")
)() :: any

local URL: string? = Games[GameId]
if not URL then return end

loadstring(HttpGet(game, URL))()