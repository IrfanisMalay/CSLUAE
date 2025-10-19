-- CSLUAE Client-side Lua Editor + Key System
-- Works on Xeno, Synapse, Fluxus, etc.
-- path: csluae/editor.lua
-- TL;DR: Fixes TextBox writability and makes Execute read from the live editor text reliably.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "CSLUAE Client-side LUA Editor",
   Icon = "square-code",
   LoadingTitle = "CSLUAE Client-side LUA Editor",
   LoadingSubtitle = "CSLUAE Client-side LUA Editor - Fixed Editor",
   ShowText = "CSLUAE client editor",
   Theme = "Ocean",
   ToggleUIKeybind = Enum.KeyCode.F4,

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "CSLUAE"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "CSLUAE VERIFICATION",
      Subtitle = "VERIFICATION Key System",
      Note = "Key: 3XPL0IT3R",
      FileName = "humankey",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {"3XPL0IT3R"}
   }
})

------------------------------------------------------------
-- Helpers: robust TextBox getter/setter (tries common Rayfield variants)
------------------------------------------------------------
local editorText = "" -- source-of-truth for editor contents

local function safeCall(fn, ...)
   local ok, res = pcall(fn, ...)
   if ok then return false, res end
   return false, res
end

local function setTextBox(text, textBox)
   text = tostring(text or "")
   -- update local copy
   editorText = text

   if not textBox then return end

   -- try common Rayfield API methods/properties
   -- order: SetValue, Set, SetText, .Input, .CurrentText, .Text
   local tried = {
      function() return textBox.SetValue and textBox:SetValue(text) end,
      function() return textBox.Set and textBox:Set(text) end,
      function() return textBox.SetText and textBox:SetText(text) end,
      function() textBox.Input = text end,
      function() textBox.CurrentText = text end,
      function() textBox.Text = text end
   }

   for _, fn in ipairs(tried) do
      local ok = pcall(fn)
      if ok then return true end
   end
   return false
end

local function getTextBox(textBox)
   -- prefer local copy
   if type(editorText) == "string" and editorText ~= "" then
      return editorText
   end

   if not textBox then return editorText end

   -- try common getters
   local getters = {
      function() if textBox.GetValue then return textBox:GetValue() end end,
      function() if textBox.Get then return textBox:Get() end end,
      function() if textBox.GetText then return textBox:GetText() end end,
      function() if textBox.Input then return textBox.Input end end,
      function() if textBox.CurrentText then return textBox.CurrentText end end,
      function() if textBox.Text then return textBox.Text end end,
   }

   for _, g in ipairs(getters) do
      local ok, res = pcall(g)
      if ok and res ~= nil then
         editorText = tostring(res)
         return editorText
      end
   end

   return editorText
end

------------------------------------------------------------
-- Detect best HTTP method for Xeno / Synapse / Fluxus etc.
------------------------------------------------------------
local function detectHttpGet()
   if typeof(xeno) == "table" and type(xeno.request) == "function" then
      return function(url)
         local res = xeno.request({Url = url, Method = "GET"})
         return res and (res.Body or res.body)
      end
   elseif type(fluxus) == "table" and type(fluxus.request) == "function" then
      return function(url)
         local res = fluxus.request({Url = url, Method = "GET"})
         return res and (res.Body or res.body)
      end
   elseif type(request) == "function" then
      return function(url)
         local res = request({Url = url, Method = "GET"})
         return res and (res.Body or res.body)
      end
   elseif typeof(game.HttpGet) == "function" then
      return function(url) return game:HttpGet(url) end
   end
   return nil
end

local httpGet = detectHttpGet()

------------------------------------------------------------
-- Editor Tab + TextBox (writable)
------------------------------------------------------------
local Tab = Window:CreateTab("Editor and Executor", "code")
Tab:CreateSection("Script Editor")

-- Create the text box and use its Callback to update editorText
local TextEditor = Tab:CreateTextBox({
   Name = "Lua Script",
   PlaceholderText = "Enter your Lua script here...",
   RemoveTextAfterFocusLost = false,
   -- every change updates the local editorText
   Callback = function(txt)
      editorText = tostring(txt or "")
   end
})

-- Ensure initial UI text is blank
setTextBox("", TextEditor)

------------------------------------------------------------
-- Buttons (Execute, Load from GitHub, Clear)
------------------------------------------------------------

-- Execute Script
Tab:CreateButton({
   Name = "Execute Script",
   Callback = function()
      -- get robustly from local or TextEditor
      local scriptText = getTextBox(TextEditor) or ""
      scriptText = tostring(scriptText)

      if scriptText == "" then
         return Rayfield:Notify({
            Title = "No Script Entered",
            Content = "Please enter a Lua script first.",
            Duration = 3
         })
      end

      -- try compile using loadstring or load
      local compile, compileErr
      if type(loadstring) == "function" then
         compile, compileErr = loadstring(scriptText)
      else
         compile, compileErr = load(scriptText)
      end

      if not compile then
         Rayfield:Notify({
            Title = "Compile Error",
            Content = tostring(compileErr),
            Duration = 6
         })
         return
      end

      local ok, runtimeErr = pcall(compile)
      if not ok then
         Rayfield:Notify({
            Title = "Runtime Error",
            Content = tostring(runtimeErr),
            Duration = 6
         })
      else
         Rayfield:Notify({
            Title = "Execution Successful",
            Content = "Script executed successfully.",
            Duration = 3
         })
      end
   end
})

-- Load Script from GitHub Raw
Tab:CreateButton({
   Name = "Load Script from GitHub Raw",
   Callback = function()
      if not httpGet then
         return Rayfield:Notify({
            Title = "Error",
            Content = "No supported HTTP method found.",
            Duration = 5
         })
      end

      local url = "https://raw.githubusercontent.com/IrfanisMalay/CSLUAE/main/script%20executor.lua"
      local success, data = pcall(function()
         return httpGet(url)
      end)

      if not success or not data or data == "" then
         Rayfield:Notify({
            Title = "Failed to Load",
            Content = "Could not fetch script from GitHub.",
            Duration = 5
         })
         return
      end

      -- set editor text using robust setter
      setTextBox(data, TextEditor)
      Rayfield:Notify({
         Title = "Loaded Successfully",
         Content = "GitHub script loaded into the editor.",
         Duration = 4
      })
   end
})

-- Clear Script
Tab:CreateButton({
   Name = "Clear Editor",
   Callback = function()
      setTextBox("", TextEditor)
      Rayfield:Notify({
         Title = "Editor Cleared",
         Content = "The editor has been cleared.",
         Duration = 2
      })
   end
})

------------------------------------------------------------
-- Optional: Save to local file button (if writefile exists)
------------------------------------------------------------
Tab:CreateButton({
   Name = "Save to File (writefile)",
   Callback = function()
      local scriptText = getTextBox(TextEditor) or ""
      if scriptText == "" then
         return Rayfield:Notify({
            Title = "Nothing to Save",
            Content = "Editor is empty.",
            Duration = 3
         })
      end
      if type(writefile) == "function" then
         pcall(function() writefile("CSLUAE_saved_script.lua", scriptText) end)
         Rayfield:Notify({
            Title = "Saved",
            Content = "Script saved to CSLUAE_saved_script.lua",
            Duration = 3
         })
      else
         Rayfield:Notify({
            Title = "Unsupported",
            Content = "writefile is not supported by this executor.",
            Duration = 4
         })
      end
   end
})

------------------------------------------------------------
-- Final ready notify
------------------------------------------------------------
Rayfield:Notify({
   Title = "CSLUAE Ready",
   Content = "Editor fixed — you can type and execute scripts. Key: 3XPL0IT3R",
   Duration = 6
})

