# CSLUAE
Client-side LUA editor roblox gui
code:
-- 🧩 Safe Remote Loader (Xeno / Syn / Fluxus compatible)

local url = "https://raw.githubusercontent.com/IrfanisMalay/CSLUAE/main/script%20executor.lua"

-- detect the best HTTP GET function available in your executor
local function httpGetAuto(u)
    -- Xeno
    if typeof(xeno) == "table" and type(xeno.request) == "function" then
        local res = xeno.request({Url = u, Method = "GET"})
        return res.Body or res.body
    end
    if typeof(Xeno) == "table" and type(Xeno.request) == "function" then
        local res = Xeno.request({Url = u, Method = "GET"})
        return res.Body or res.body
    end

    -- Synapse-style
    if type(syn) == "table" and type(syn.request) == "function" then
        local res = syn.request({Url = u, Method = "GET"})
        return res.Body or res.body
    end

    -- Generic request/http_request
    if type(request) == "function" then
        local res = request({Url = u, Method = "GET"})
        return res.Body or res.body
    end
    if type(http_request) == "function" then
        local res = http_request({Url = u, Method = "GET"})
        return res.Body or res.body
    end
    if type(http) == "table" and type(http.request) == "function" then
        local res = http.request({Url = u, Method = "GET"})
        return res.Body or res.body
    end

    -- Fallback
    if typeof(game.HttpGet) == "function" then
        return game:HttpGet(u)
    end

    error("❌ No supported HTTP request method found for this executor")
end

-- Fetch the script
local success, code = pcall(httpGetAuto, url)
if not success then
    warn("⚠️ Failed to fetch remote script:", code)
    return
end

-- Compile and run
local chunk, loadErr = loadstring(code)
if not chunk then
    warn("⚠️ Load error:", loadErr)
    return
end

local ok, runErr = pcall(chunk)
if not ok then
    warn("⚠️ Script error:", runErr)
else
    print("✅ CSLUAE script loaded successfully from GitHub!")
end

# Made using rayfield by Sirius modded by Irfan and Fixed using ChatGPT.

# open source for scriptor ideas.
