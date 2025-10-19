#TO RUN IT USE THIS CODE:

    -- file: csluae/load_from_url.lua
    -- Fetch + loadstring + execute from a raw GitHub URL (robust for Xeno / Fluxus / Synapse / Roblox)

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
    
    -- Replace URL below with the exact raw URL you provided
    local RAW_URL = "https://raw.githubusercontent.com/IrfanisMalay/CSLUAE/refs/heads/main/script%20executor.lua"
    
    -- Main loader: fetch, compile, execute
    local function loadAndExecuteFromUrl(url, opts)
       opts = opts or {}
       local httpGet = detectHttpGet()
       if not httpGet then
          if Rayfield then
             Rayfield:Notify({Title = "HTTP unavailable", Content = "No supported HTTP method found.", Duration = 4})
          end
          return false, "no_http"
       end
    
       local ok, body = pcall(function() return httpGet(url) end)
       if not ok or not body or tostring(body) == "" then
          if Rayfield then
             Rayfield:Notify({Title = "Fetch failed", Content = "Could not fetch URL or response empty.", Duration = 5})
          end
          return false, "fetch_failed"
       end
    
       local chunk, compileErr
       if type(loadstring) == "function" then
          chunk, compileErr = loadstring(body)
       else
          chunk, compileErr = load(body)
       end
    
       if not chunk then
          if Rayfield then
             Rayfield:Notify({Title = "Compile Error", Content = tostring(compileErr), Duration = 7})
          end
          return false, ("compile_error: %s"):format(tostring(compileErr))
       end
    
       -- choose runner: coroutine for yielding code, or pcall for non-yielding
       if opts.allowYield then
          local runner = coroutine.wrap(function()
             local ok, err = pcall(chunk)
             if not ok then error(err) end
          end)
          local topOk, topErr = pcall(function() runner() end)
          if not topOk then
             if Rayfield then Rayfield:Notify({Title = "Runtime Error", Content = tostring(topErr), Duration = 7}) end
             return false, ("runtime_error: %s"):format(tostring(topErr))
          end
       else
          local okExec, execErr = pcall(chunk)
          if not okExec then
             if Rayfield then Rayfield:Notify({Title = "Runtime Error", Content = tostring(execErr), Duration = 7}) end
             return false, ("runtime_error: %s"):format(tostring(execErr))
          end
       end
    
       if Rayfield then
          Rayfield:Notify({Title = "Loaded & Executed", Content = "Script loaded from URL and executed.", Duration = 4})
       end
       return true
    end
    
    -- Usage example (non-yielding execution)
    local success, err = loadAndExecuteFromUrl(RAW_URL, {allowYield = false})
    -- if you expect the remote script to use yieldable functions like wait(), use allowYield = true:
    -- local success, err = loadAndExecuteFromUrl(RAW_URL, {allowYield = true})
    

# Made using rayfield by Sirius modded by Irfan and Fixed using ChatGPT.

# open source for scriptor ideas.
