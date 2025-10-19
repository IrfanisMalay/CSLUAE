#TO RUN IT USE THIS CODE:

    -- Example: compile & run whatever is in your editor safely and capture returns.
    -- Place this inside your UI button Callback (uses getTextBox & Rayfield from previous script).
    
    local function executeEditorScript(TextEditor)
       -- 1. get text
       local scriptText = (getTextBox and getTextBox(TextEditor)) or tostring(TextEditor and TextEditor.Text or "") or ""
       scriptText = tostring(scriptText)
    
       if scriptText == "" then
          return Rayfield:Notify({Title = "No Script", Content = "Editor is empty.", Duration = 3})
       end
    
       -- 2. compile (loadstring for older envs, load as fallback)
       local chunk, compileErr
       if type(loadstring) == "function" then
          chunk, compileErr = loadstring(scriptText)
       else
          chunk, compileErr = load(scriptText)
       end
    
       if not chunk then
          -- compile error (syntax)
          return Rayfield:Notify({Title = "Compile Error", Content = tostring(compileErr), Duration = 6})
       end
    
       -- 3a. preferred: run in coroutine to allow yields (safe for Roblox code that may wait)
       local ok, results
       local runner = coroutine.wrap(function()
          -- run chunk inside pcall so runtime errors are caught
          local success, ...
          success, ... = pcall(chunk)
          if not success then
             error((...)) -- rethrow to be caught by outer pcall below
          end
          results = {...} -- capture return values
       end)
    
       -- 3b. top-level pcall to catch coroutine errors
       local topOk, topErr = pcall(function() runner() end)
       if not topOk then
          return Rayfield:Notify({Title = "Runtime Error", Content = tostring(topErr), Duration = 6})
       end
    
       -- 4. report return values (if any)
       if results and #results > 0 then
          -- join first few values into a string for display
          local out = {}
          for i = 1, math.min(#results, 5) do
             table.insert(out, tostring(results[i]))
          end
          Rayfield:Notify({
             Title = "Executed — Return Values",
             Content = table.concat(out, ", "),
             Duration = 5
          })
       else
          Rayfield:Notify({Title = "Executed", Content = "Script ran successfully (no return values).", Duration = 4})
       end
    end
    
    -- Example usage in a button callback:
    Tab:CreateButton({
       Name = "Execute Script (safe)",
       Callback = function()
          executeEditorScript(TextEditor)
       end
    })

# Made using rayfield by Sirius modded by Irfan and Fixed using ChatGPT.

# open source for scriptor ideas.
