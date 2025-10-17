-- Robust Rayfield Editor + GitHub loader (Xeno / Syn / Generic compatible)
-- Paste into your executor and run

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local load_fn = load or loadstring

-- HTTP detection (Xeno, syn, request, http_request, http.request, fallback game:HttpGet)
local function detect_http_get()
    if type(xeno) == "table" and type(xeno.request) == "function" then
        return function(u)
            local res = xeno.request({Url = u, Method = "GET"})
            return res and (res.Body or res.body)
        end
    end
    if type(Xeno) == "table" and type(Xeno.request) == "function" then
        return function(u)
            local res = Xeno.request({Url = u, Method = "GET"})
            return res and (res.Body or res.body)
        end
    end
    if type(syn) == "table" and type(syn.request) == "function" then
        return function(u)
            local res = syn.request({Url = u, Method = "GET"})
            return res and (res.Body or res.body)
        end
    end
    if type(request) == "function" then
        return function(u)
            local res = request({Url = u, Method = "GET"})
            return res and (res.Body or res.body)
        end
    end
    if type(http_request) == "function" then
        return function(u)
            local res = http_request({Url = u, Method = "GET"})
            return res and (res.Body or res.body)
        end
    end
    if type(http) == "table" and type(http.request) == "function" then
        return function(u)
            local res = http.request({Url = u, Method = "GET"})
            return res and (res.Body or res.body) or res
        end
    end
    if typeof(game.HttpGet) == "function" then
        return function(u)
            return game:HttpGet(u)
        end
    end
    return nil
end

local httpGet = detect_http_get()

-- Create Rayfield window
local Window = Rayfield:CreateWindow({
    Name = "CSLUAE Editor (Robust)",
    Icon = "square-code",
    LoadingTitle = "CSLUAE Editor",
    LoadingSubtitle = "Robust Rayfield UI",
    ShowText = "CSLUAE Editor",
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
    KeySystem = false
})

local Tab = Window:CreateTab("Editor and Executor", "code")
Tab:CreateSection("Script Editor")

-- Primary editor creation attempt (TextBox). Rayfield versions differ.
local editor = nil
local ok, try_box = pcall(function()
    editor = Tab:CreateTextBox({
        Name = "Lua Script",
        PlaceholderText = "Enter or load your Lua script here...",
        RemoveTextAfterFocusLost = false,
        Callback = function() end
    })
end)

-- Fallback: try CreateTextArea if CreateTextBox not available or returned nil
if (not ok) or (not editor) then
    pcall(function()
        editor = Tab:CreateTextArea({
            Name = "Lua Script",
            Placeholder = "Enter or load your Lua script here...",
            Text = ""
        })
    end)
end

-- If still nil, create a simple input box and keep string buffer fallback
local fallback_buffer = ""
if not editor then
    editor = Tab:CreateTextBox({
        Name = "Lua Script (Simple)",
        PlaceholderText = "Editor API not available; use Load/Execute or paste into URL box to load.",
        RemoveTextAfterFocusLost = false,
        Callback = function(val) fallback_buffer = val end
    })
    Rayfield:Notify({ Title = "Editor Fallback", Content = "Using simple textbox fallback. Some editors may not support multiline editing.", Duration = 5 })
end

-- Helper to get editor text (try multiple property/method names)
local function get_editor_text()
    -- common field names/methods across Rayfield versions and forks
    local tries = {
        function() if type(editor.Input) == "string" then return editor.Input end end,
        function() if type(editor.Text) == "string" then return editor.Text end end,
        function() if type(editor.Value) == "string" then return editor.Value end end,
        function() if type(editor.GetText) == "function" then return editor:GetText() end end,
        function() if type(editor.GetValue) == "function" then return editor:GetValue() end end,
        function() if type(editor.Get) == "function" then return editor:Get() end end,
        function() if type(editor.GetText) == "userdata" then return tostring(editor:GetText()) end end,
        function() return fallback_buffer end
    }
    for _, fn in ipairs(tries) do
        local ok, res = pcall(fn)
        if ok and type(res) == "string" and res ~= "" then
            return res
        end
    end
    -- last resort: try reading some raw fields
    for _, key in ipairs({"Input", "Text", "Value"}) do
        if type(editor[key]) == "string" and editor[key] ~= "" then
            return editor[key]
        end
    end
    return "" -- empty
end

-- Helper to set editor text (try multiple methods)
local function set_editor_text(s)
    local tries = {
        function() if type(editor.SetValue) == "function" then editor:SetValue(s); return true end end,
        function() if type(editor.Set) == "function" then editor:Set(s); return true end end,
        function() editor.Input = s; return true end,
        function() editor.Text = s; return true end,
        function() editor.Value = s; return true end,
        function() fallback_buffer = s; return true end
    }
    for _, fn in ipairs(tries) do
        local ok, res = pcall(fn)
        if ok and res ~= nil then
            return true
        end
    end
    return false
end

-- URL box for GitHub raw
local UrlBox = Tab:CreateTextBox({
    Name = "GitHub Raw URL",
    PlaceholderText = "https://raw.githubusercontent.com/user/repo/branch/path/file.lua",
    RemoveTextAfterFocusLost = false,
    Callback = function() end
})

-- Execute editor content
Tab:CreateButton({
    Name = "Execute Script (Editor)",
    Callback = function()
        local code = get_editor_text()
        if not code or code == "" then
            Rayfield:Notify({ Title = "No Script", Content = "Editor is empty — paste or load a script first.", Duration = 4 })
            return
        end

        -- attempt to compile and run
        local chunk, loadErr = pcall(function() return load_fn(code) end)
        if not chunk or type(loadErr) ~= "function" then
            -- loadErr holds either error message or returned chunk depending on pcall usage; handle gracefully
            -- Try without pcall to capture load error
            local ch, le = load_fn(code)
            if not ch then
                Rayfield:Notify({ Title = "Compile Error", Content = tostring(le), Duration = 6 })
                print("Compile error:", le)
                return
            else
                chunk = ch
            end
        end

        local ok, runErr = pcall(function() chunk() end)
        if ok then
            Rayfield:Notify({ Title = "Executed", Content = "Editor script executed successfully.", Duration = 3 })
            print("Editor script executed.")
        else
            Rayfield:Notify({ Title = "Runtime Error", Content = tostring(runErr), Duration = 6 })
            print("Runtime error:", runErr)
        end
    end
})

-- Clear editor
Tab:CreateButton({
    Name = "Clear Editor",
    Callback = function()
        set_editor_text("")
        Rayfield:Notify({ Title = "Cleared", Content = "Editor cleared.", Duration = 2 })
    end
})

-- Save editor to file (if writefile available)
Tab:CreateButton({
    Name = "Save Editor to file (writefile)",
    Callback = function()
        local okwf = type(writefile) == "function"
        if not okwf then
            Rayfield:Notify({ Title = "Not Supported", Content = "This executor doesn't provide writefile.", Duration = 4 })
            return
        end
        local code = get_editor_text()
        if not code or code == "" then
            Rayfield:Notify({ Title = "No Script", Content = "Editor is empty — nothing to save.", Duration = 3 })
            return
        end
        local filename = "CSLUAE_saved_script.lua"
        local success, err = pcall(function() writefile(filename, code) end)
        if success then
            Rayfield:Notify({ Title = "Saved", Content = "Saved to "..filename, Duration = 3 })
        else
            Rayfield:Notify({ Title = "Save Error", Content = tostring(err), Duration = 5 })
        end
    end
})

-- Load from GitHub raw and execute
Tab:CreateButton({
    Name = "Load & Execute from GitHub Raw",
    Callback = function()
        local url = UrlBox.Input or UrlBox.Input or ""
        if url == "" then
            Rayfield:Notify({ Title = "No URL", Content = "Paste the raw.githubusercontent.com URL in the URL box.", Duration = 4 })
            return
        end
        if not string.find(url, "raw.githubusercontent.com") then
            Rayfield:Notify({ Title = "Blocked", Content = "Only raw.githubusercontent.com URLs allowed by default.", Duration = 5 })
            return
        end
        if not httpGet then
            Rayfield:Notify({ Title = "No HTTP", Content = "No supported HTTP function detected in executor.", Duration = 5 })
            return
        end

        local ok, body = pcall(function() return httpGet(url) end)
        if not ok then
            Rayfield:Notify({ Title = "HTTP Error", Content = tostring(body), Duration = 6 })
            print("HTTP fetch error:", body)
            return
        end
        if not body or body == "" then
            Rayfield:Notify({ Title = "Empty File", Content = "Fetched file was empty.", Duration = 4 })
            return
        end

        set_editor_text(body) -- put it in editor for inspection
        Rayfield:Notify({ Title = "Loaded", Content = "Remote script loaded into the editor. Executing now...", Duration = 3 })

        local chunk, loadErr = load_fn(body)
        if not chunk then
            Rayfield:Notify({ Title = "Compile Error", Content = tostring(loadErr), Duration = 6 })
            print("Compile error:", loadErr)
            return
        end
        local ok2, runErr = pcall(function() chunk() end)
        if ok2 then
            Rayfield:Notify({ Title = "Remote Executed", Content = "Remote script ran successfully.", Duration = 4 })
            print("Remote script executed.")
        else
            Rayfield:Notify({ Title = "Runtime Error", Content = tostring(runErr), Duration = 8 })
            print("Remote runtime error:", runErr)
        end
    end
})

-- Load only (do not execute)
Tab:CreateButton({
    Name = "Load From GitHub Raw (Do Not Execute)",
    Callback = function()
        local url = UrlBox.Input or UrlBox.Input or ""
        if url == "" then
            Rayfield:Notify({ Title = "No URL", Content = "Paste the raw.githubusercontent.com URL in the URL box.", Duration = 4 })
            return
        end
        if not string.find(url, "raw.githubusercontent.com") then
            Rayfield:Notify({ Title = "Blocked", Content = "Only raw.githubusercontent.com URLs allowed by default.", Duration = 5 })
            return
        end
        if not httpGet then
            Rayfield:Notify({ Title = "No HTTP", Content = "No supported HTTP function detected in executor.", Duration = 5 })
            return
        end

        local ok, body = pcall(function() return httpGet(url) end)
        if not ok then
            Rayfield:Notify({ Title = "HTTP Error", Content = tostring(body), Duration = 6 })
            print("HTTP fetch error:", body)
            return
        end
        if not body or body == "" then
            Rayfield:Notify({ Title = "Empty File", Content = "Fetched file was empty.", Duration = 4 })
            return
        end

        set_editor_text(body)
        Rayfield:Notify({ Title = "Loaded", Content = "Remote script loaded into editor (not executed).", Duration = 3 })
    end
})

-- Quick debug notification about detection
local function show_detection()
    local info = "No HTTP detected"
    if type(xeno) == "table" and type(xeno.request) == "function" then info = "xeno.request"
    elseif type(Xeno) == "table" and type(Xeno.request) == "function" then info = "Xeno.request"
    elseif type(syn) == "table" and type(syn.request) == "function" then info = "syn.request"
    elseif type(request) == "function" then info = "request"
    elseif type(http_request) == "function" then info = "http_request"
    elseif type(http) == "table" and type(http.request) == "function" then info = "http.request"
    elseif typeof(game.HttpGet) == "function" then info = "game:HttpGet"
    end
    Rayfield:Notify({ Title = "Environment", Content = "HTTP method: "..info, Duration = 4 })
    print("CSLUAE: detected HTTP method ->", info)
end

show_detection()
