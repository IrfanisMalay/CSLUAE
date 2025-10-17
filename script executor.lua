-- Rayfield + Github-raw loader with multi-executor HTTP detection (works with Xeno)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- choose load function compatible across environments
local load_fn = loadstring or load

-- HTTP helper: detect available http function (syn.request, request, http_request, http.request, game:HttpGet, etc.)
local function detect_http_get()
    -- syn
    if type(syn) == "table" and type(syn.request) == "function" then
        return function(url)
            local ok, res = pcall(syn.request, {Url = url, Method = "GET"})
            if not ok then error("syn.request failed: "..tostring(res)) end
            return res.Body or res.body
        end
    end

    -- request (many executors)
    if type(request) == "function" then
        return function(url)
            local ok, res = pcall(request, {Url = url, Method = "GET"})
            if not ok then error("request failed: "..tostring(res)) end
            return (res and (res.Body or res.body)) or error("empty response")
        end
    end

    -- http_request (some executors)
    if type(http_request) == "function" then
        return function(url)
            local ok, res = pcall(http_request, {Url = url, Method = "GET"})
            if not ok then error("http_request failed: "..tostring(res)) end
            return res.Body or res.body
        end
    end

    -- http table with request method
    if type(http) == "table" and type(http.request) == "function" then
        return function(url)
            local ok, res = pcall(http.request, {Url = url, Method = "GET"})
            if not ok then error("http.request failed: "..tostring(res)) end
            -- some implementations return table or string
            if type(res) == "table" then return res.Body or res.body end
            return res
        end
    end

    -- xeno-specific guess: some executors expose a global or table called 'xeno' or 'Xeno'
    if type(xeno) == "table" and type(xeno.request) == "function" then
        return function(url)
            local ok, res = pcall(xeno.request, {Url = url, Method = "GET"})
            if not ok then error("xeno.request failed: "..tostring(res)) end
            return res.Body or res.body
        end
    end
    if type(Xeno) == "table" and type(Xeno.request) == "function" then
        return function(url)
            local ok, res = pcall(Xeno.request, {Url = url, Method = "GET"})
            if not ok then error("Xeno.request failed: "..tostring(res)) end
            return res.Body or res.body
        end
    end

    -- final fallback: game:HttpGet (works in many exploit environments)
    if typeof(game.HttpGet) == "function" then
        return function(url)
            local ok, res = pcall(function() return game:HttpGet(url) end)
            if not ok then error("game:HttpGet failed: "..tostring(res)) end
            return res
        end
    end

    -- if none found, return nil so caller can error gracefully
    return nil
end

local httpGet = detect_http_get()

-- Create Main Window
local Window = Rayfield:CreateWindow({
    Name = "CSLUAE Client-side LUA Editor",
    Icon = "square-code",
    LoadingTitle = "CSLUAE Client-side LUA Editor",
    LoadingSubtitle = "Rayfield-Sirius CSLUAE-Irfan",
    ShowText = "CSLUAE Client-side LUA Editor",
    Theme = "Ocean",
    ToggleUIKeybind = Enum.KeyCode.F4,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CSLUAE",
        FileName = "CSLUAE_Config"
    },
    Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
    KeySystem = true,
    KeySettings = {
        Title = "CSLUAE VERIFICATION",
        Subtitle = "Human Face Key System",
        Note = "X3NO1SB37TER",
        FileName = "humankey",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {"X3NO1SB37TER"}
    }
})

local Tab = Window:CreateTab("Editor and Executor", "code")
Tab:CreateSection("Script Editor")

-- Editor textbox (multi-line)
local TextEditor = Tab:CreateTextBox({
    Name = "Lua Script",
    PlaceholderText = "Enter your Lua script here...",
    RemoveTextAfterFocusLost = false,
    Callback = function() end
})

-- URL textbox for GitHub raw
local UrlBox = Tab:CreateTextBox({
    Name = "GitHub Raw URL",
    PlaceholderText = "https://raw.githubusercontent.com/username/repo/branch/path/to/script.lua",
    RemoveTextAfterFocusLost = false,
    Callback = function() end
})

-- Execute editor content
Tab:CreateButton({
    Name = "Execute Script (Editor)",
    Callback = function()
        local scriptText = TextEditor.Input
        if not scriptText or scriptText == "" then
            Rayfield:Notify({ Title = "No Script Entered", Content = "Enter a script in the editor first.", Duration = 3 })
            return
        end

        local ok, err = pcall(function()
            local fn = load_fn(scriptText)
            if type(fn) ~= "function" then error("Loaded chunk is not a function") end
            fn()
        end)

        if ok then
            Rayfield:Notify({ Title = "Execution Successful", Content = "Editor script ran.", Duration = 3 })
        else
            Rayfield:Notify({ Title = "Execution Error", Content = tostring(err), Duration = 6 })
        end
    end
})

-- Load & optionally execute remote GitHub raw script
Tab:CreateButton({
    Name = "Load & Execute from GitHub Raw",
    Callback = function()
        local url = UrlBox.Input
        if not url or url == "" then
            Rayfield:Notify({ Title = "No URL", Content = "Paste the raw.githubusercontent.com URL in the URL box.", Duration = 4 })
            return
        end

        if not string.find(url, "raw.githubusercontent.com") then
            Rayfield:Notify({ Title = "Blocked URL", Content = "For safety, only raw.githubusercontent.com URLs are allowed.", Duration = 5 })
            return
        end

        if not httpGet then
            Rayfield:Notify({ Title = "No HTTP Function", Content = "No supported HTTP function found in this executor (tested syn.request, request, http_request, http.request, game:HttpGet).", Duration = 6 })
            return
        end

        -- fetch remote script
        local ok, body_or_err = pcall(function() return httpGet(url) end)
        if not ok then
            Rayfield:Notify({ Title = "HTTP Error", Content = "Failed to fetch URL: "..tostring(body_or_err), Duration = 6 })
            return
        end

        local remoteCode = body_or_err
        if not remoteCode or remoteCode == "" then
            Rayfield:Notify({ Title = "Empty File", Content = "The fetched file was empty.", Duration = 4 })
            return
        end

        -- put code into editor so user can inspect
        if TextEditor.SetValue then
            pcall(function() TextEditor:SetValue(remoteCode) end)
        end
        -- some Rayfield versions accept direct assignment
        pcall(function() TextEditor.Input = remoteCode end)

        -- try to load & execute
        local success, err = pcall(function()
            local fn = load_fn(remoteCode)
            if type(fn) ~= "function" then error("Downloaded chunk is not a function") end
            fn()
        end)

        if success then
            Rayfield:Notify({ Title = "Remote Execution OK", Content = "Remote script executed successfully.", Duration = 4 })
        else
            Rayfield:Notify({ Title = "Execution Error", Content = tostring(err), Duration = 8 })
        end
    end
})

-- Load only (do not execute)
Tab:CreateButton({
    Name = "Load From GitHub Raw (Do Not Execute)",
    Callback = function()
        local url = UrlBox.Input
        if not url or url == "" then
            Rayfield:Notify({ Title = "No URL", Content = "Paste the raw.githubusercontent.com URL in the URL box.", Duration = 4 })
            return
        end

        if not string.find(url, "raw.githubusercontent.com") then
            Rayfield:Notify({ Title = "Blocked URL", Content = "Only raw.githubusercontent.com allowed.", Duration = 5 })
            return
        end

        if not httpGet then
            Rayfield:Notify({ Title = "No HTTP Function", Content = "No supported HTTP function found in this executor.", Duration = 6 })
            return
        end

        local ok, body_or_err = pcall(function() return httpGet(url) end)
        if not ok then
            Rayfield:Notify({ Title = "HTTP Error", Content = tostring(body_or_err), Duration = 6 })
            return
        end

        if TextEditor.SetValue then
            pcall(function() TextEditor:SetValue(body_or_err) end)
        end
        pcall(function() TextEditor.Input = body_or_err end)

        Rayfield:Notify({ Title = "Loaded", Content = "Remote script loaded into editor.", Duration = 3 })
    end
})

-- Optional: quick detection notification so user knows which HTTP method was chosen (nice for debugging)
local function which_http()
    local info = "No HTTP detected"
    if type(syn) == "table" and type(syn.request) == "function" then info = "syn.request"
    elseif type(request) == "function" then info = "request"
    elseif type(http_request) == "function" then info = "http_request"
    elseif type(http) == "table" and type(http.request) == "function" then info = "http.request"
    elseif type(xeno) == "table" and type(xeno.request) == "function" then info = "xeno.request"
    elseif typeof(game.HttpGet) == "function" then info = "game:HttpGet"
    end
    Rayfield:Notify({ Title = "HTTP Detection", Content = "Chosen method: "..info, Duration = 3 })
end

-- show detected http when UI loads
which_http()
