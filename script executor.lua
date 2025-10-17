-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create Main Window
local Window = Rayfield:CreateWindow({
    Name = "CSLUAE Client-side LUA Editor",
    Icon = "square-code", -- Lucide icon or Roblox image ID
    LoadingTitle = "CSLUAE Client-side LUA Editor",
    LoadingSubtitle = "Rayfield-Sirius CSLUAE-Irfan",
    ShowText = "CSLUAE Client-side LUA Editor", -- Text for mobile toggle
    Theme = "Ocean", -- Themes: Ocean, Amethyst, etc.

    ToggleUIKeybind = Enum.KeyCode.RightControl, -- FIXED: Must be Enum.KeyCode, not (Enum.KeyCode.64)

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CSLUAE", -- Saves to this folder
        FileName = "CSLUAE_Config"
    },

    Discord = {
        Enabled = false,
        Invite = "no",
        RememberJoins = true
    },

    KeySystem = true,
    KeySettings = {
        Title = "CSLUAE VERIFICATION",
        Subtitle = "Human Face Key System",
        Note = "https://scratch.mit.edu/projects/1230152956/",
        FileName = "humankey",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {"X3NO1SB37TER"}
    }
})

-- Create Tab & Section
local Tab = Window:CreateTab("Editor and Executor", "code")
local Section = Tab:CreateSection("Script Editor")

-- Create TextArea
local TextEditor = Tab:CreateTextBox({
    Name = "Lua Script",
    PlaceholderText = "Enter your Lua script here...",
    RemoveTextAfterFocusLost = false,
    Callback = function() end
})

-- Create Execute Button
local ExecuteButton = Tab:CreateButton({
    Name = "Execute Script",
    Callback = function()
        local scriptToExecute = TextEditor.Input -- FIXED: Correct way to get textbox input

        if scriptToExecute and scriptToExecute ~= "" then
            local success, err = pcall(function()
                local func = loadstring(scriptToExecute)
                func()
            end)

            if success then
                Rayfield:Notify({
                    Title = "Execution Successful",
                    Content = "Your script was executed successfully!",
                    Duration = 4
                })
            else
                Rayfield:Notify({
                    Title = "Execution Error",
                    Content = "Error while running script:\n" .. tostring(err),
                    Duration = 6
                })
            end
        else
            Rayfield:Notify({
                Title = "No Script Entered",
                Content = "Please enter a Lua script to execute!",
                Duration = 3
            })
        end
    end
})
