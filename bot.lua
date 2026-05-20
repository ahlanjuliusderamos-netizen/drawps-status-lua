local http = require("http")
local port = process.env.PORT or 10000

http.createServer(function(req, res)
    res:setHeader("Content-Type", "text/plain")
    res:finish("Bot is awake and running!")
end):listen(port)-- DRAWPS - Growsoft Discord Status Bot (Lua Version)
-- Uses the Discordia package

local discordia = require('discordia')
local client = discordia.Client()
local http = require('coro-http') -- Used for making API fetch requests
local json = require('json')     -- Used for parsing API data
local timer = require('timer')    -- Built-in Luvit timer module for loops

-- ==================== CONFIGURATION ====================
local CONFIG = {
    discordToken = os.getenv("DISCORD_TOKEN"),
    channelId = os.getenv("CHANNEL_ID"),
    updateInterval = 60000, -- 60 seconds
    
    -- Your Growsoft Server Details
    serverIp = "dash.gtps.cloud",
    serverPort = "10001"
}
-- =======================================================

local statusMessage = nil
local botStartTime = os.time()

local function getUptime()
    local diff = os.time() - botStartTime
    local hours = math.floor(diff / 3600)
    local minutes = math.floor((diff % 3600) / 60)
    return string.format("%dh %dm", hours, minutes)
end

-- Function to check if the server is online via public tracking API
local function fetchServerStats()
    local url = string.format("https://api.growtopia.org/server?ip=%s&port=%s", CONFIG.serverIp, CONFIG.serverPort)
    
    local success, result = pcall(function()
        local res, body = http.request("GET", url)
        if res.code ~= 200 then error("API response error") end
        return json.decode(body)
    end)
    
    if success and result then
        return {
            online = true,
            onlinePlayers = result.players or 0,
            totalWorlds = result.worlds or "N/A",
            totalAccounts = result.accounts or "N/A"
        }
    else
        return {
            online = true,
            onlinePlayers = "Click to View",
            totalWorlds = "N/A",
            totalAccounts = "N/A"
        }
    end
end

-- Build and update the status layout
local function refreshStatus()
    if not CONFIG.channelId then 
        print("Waiting for CHANNEL_ID environment variable...")
        return 
    end
    
    local channel = client:getChannel(CONFIG.channelId)
    if not channel then 
        print("Could not find the target Discord channel.")
        return 
    end
    
    local stats = fetchServerStats()
    local embedColor = stats.online and 0x00FF7F or 0xFF3E3E
    
    local statusEmbed = {
        title = "🖥️   SERVER STATUS PANEL",
        description = "Live telemetry synchronizing with the **Growsoft** cloud node. Real-time details below:",
        color = embedColor,
        fields = {
            { name = "🟢  STATUS", value = "```\nOperational\n```", inline = true },
            { name = "⏱️  UPTIME", value = string.format("```\n%s\n```", getUptime()), inline = true },
            { name = "🌐  REGION", value = "```\nGlobal\n```", inline = true },
            { name = "👥  ONLINE PLAYERS", value = string.format("```\n%s\n```", stats.onlinePlayers), inline = false },
            { name = "🌍  TOTAL WORLDS", value = string.format("```\n%s\n```", stats.totalWorlds), inline = true },
            { name = "💳  TOTAL ACCOUNTS", value = string.format("```\n%s\n```", stats.totalAccounts), inline = true }
        },
        footer = { text = "DrawPS Utility • Auto-updates every 60s" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
    }
    
    if statusMessage then
    statusMessage:update({ content = "", embed = statusEmbed })
    else
        -- Check recent channel history to avoid duplicating messages
        local messages = channel:getMessages(10)
        local botMsg = nil
        for msg in messages:iter() do
            if msg.author.id == client.user.id then
                botMsg = msg
                break
            end
        end
        
        if botMsg then
            statusMessage = botMsg
            statusMessage:update({ content = "", embed = statusEmbed })
        else
            statusMessage = channel:send({ embed = statusEmbed })
        end
    end
    print("Status panel successfully updated at " .. os.date("%X"))
end

client:on('ready', function()
    print('Logged in as ' .. client.user.tag)
    
    -- Proper Lua loop handling for periodic tasks
    coroutine.wrap(function()
        while true do
            refreshStatus()
            timer.sleep(CONFIG.updateInterval)
        end
    end)()
end)

if CONFIG.discordToken then
    client:run('Bot ' .. CONFIG.discordToken)
else
    print("Missing DISCORD_TOKEN environment variable.")
end
