-- CSLUAE Client-side Lua Editor + Key System
-- Works on Xeno, Synapse, Fluxus, etc.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
      FolderName = nil,
      FileName = "CSLUAE"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   -- ✅ Key System (your original setup)
   KeySystem = true,
   KeySettings = {
      Title = "CSLUAE VERIFICATION",
      Subtitle = "Human Face Key System",
      Note = "Key: X3NO1SB37TER",
      FileName = "humankey",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {"X3NO1SB37TER"}
   }
})

------------------------------------------------------------
-- Editor Tab
------------------------------------------------------------
local Tab = Window:CreateTab("Editor and Executor", "code")
Tab:CreateSection("Script Editor")

-- Text editor box
local TextEditor = Tab:CreateTextBox({
   Name = "Lua Script",
   PlaceholderText = "Enter your Lua script here...",
   RemoveTextAfterFocusLost = false,
   Callback = function() end
})

-- Detect best HTTP method for Xeno etc.
local function detectHttpGet()
   if typeof(xeno) == "table" and type(xeno.request) == "function" then
      return function(url)
         local res = xeno.request({Url = url, Method = "GET"})
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
end

local httpGet = detectHttpGet()

------------------------------------------------------------
-- Buttons
------------------------------------------------------------

-- Execute Script
Tab:CreateButton({
   Name = "Execute Script",
   Callback = function()
      local scriptText = TextEditor.Input or TextEditor.Text or ""
      if scriptText == "" then
         return Rayfield:Notify({
            Title = "No Script Entered",
            Content = "Please enter a Lua script first.",
            Duration = 3
         })
      end

      local func, err = loadstring(scriptText)
      if not func then
         Rayfield:Notify({
            Title = "Compile Error",
            Content = tostring(err),
            Duration = 5
         })
         return
      end

      local success, runtimeError = pcall(func)
      if not success then
         Rayfield:Notify({
            Title = "Runtime Error",
            Content = tostring(runtimeError),
            Duration = 5
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

      TextEditor.Input = data
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
      TextEditor.Input = ""
      Rayfield:Notify({
         Title = "Editor Cleared",
         Content = "The editor has been cleared.",
         Duration = 2
      })
   end
})

------------------------------------------------------------
-- End of script
------------------------------------------------------------

Rayfield:Notify({
   Title = "CSLUAE Ready",
   Content = "Enter your key (X3NO1SB37TER) to unlock the editor.",
   Duration = 6
})
