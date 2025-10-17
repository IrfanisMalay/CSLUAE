local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "CSLUAE Client-side LUA Editor",
   Icon = "square-code", -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "CSLUAE Client-side LUA Editor",
   LoadingSubtitle = "Rayfield-Sirius CSLUAE-Irfan",
   ShowText = "CSLUAE Client-side LUA Editor", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Ocean", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = Enum.KeyCode.64 , -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "CSLUAE"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "CSLUAE VERIFICATION",
      Subtitle = "Human Face Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "humankey", -- something here
      SaveKey = false, -- something here
      GrabKeyFromSite = false, -- something here
      Key = {"X3NO1SB37TER"}
   }
})

local Tab = Window:CreateTab("Editor and executor", "chevrons-left-right-ellipsis")
local Section = Tab:CreateSection("Editor")
-- Create a TextEditor to hold the script
local TextEditor = Tab:CreateTextArea({
   Name = "Lua Script",
   Placeholder = "Enter your Lua script here...",
   Text = ""
})

-- Create a button to execute the script in the TextEditor
local Button = Tab:CreateButton({
   Name = "Execute Script",
   Callback = function()
       local scriptToExecute = TextEditor:GetText() -- Retrieve the text from the TextEditor
       
       if scriptToExecute and scriptToExecute ~= "" then -- Check that the text box isn't empty
           local success, errorMessage = pcall(function()
               local func = loadstring(scriptToExecute)
               func()
           end)

           if not success then
               -- Show an error notification if the script fails
               Rayfield:Notify({
                   Title = "Execution Error",
                   Content = "An error occurred during script execution: " .. errorMessage,
                   Duration = 5 -- How long the notification will be visible
               })
           else
               -- Show a success notification
               Rayfield:Notify({
                   Title = "Execution Successful",
                   Content = "Your script has been executed.",
                   Duration = 3
               })
           end
       else
           -- Show a warning if the text box is empty
           Rayfield:Notify({
               Title = "No Script Entered",
               Content = "Please enter a script to execute.",
               Duration = 3
           })
       end
   end,
})