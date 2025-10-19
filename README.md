#TO RUN IT USE THIS CODE:

    local url = "https://raw.githubusercontent.com/IrfanisMalay/CSLUAE/main/script%20executor.lua"
    local function httpGetXeno(u)
        if typeof(xeno) == "table" and type(xeno.request) == "function" then
            local res = xeno.request({Url = u, Method = "GET"})
            return res.Body or res.body
        end
    
        if typeof(Xeno) == "table" and type(Xeno.request) == "function" then
            local res = Xeno.request({Url = u, Method = "GET"})
            return res.Body or res.body
        end
    
        error("Xeno HTTP not found")
    end
    
    
    print(" Xeno Remote Loader Starting...")
    print(" Fetching: " .. url)
    
    local success, code = pcall(httpGetXeno, url)
    
    if success and code then
        print(" Downloaded " .. #code .. " bytes")
    
        local chunk, loadErr = loadstring(code)
        if chunk then
            local execSuccess, runErr = pcall(chunk)
            if execSuccess then
                print(" Script executed successfully!")
            else
                warn(" Execution error: " .. tostring(runErr))
            end
        else
            warn(" Loadstring error: " .. tostring(loadErr))
        end
    else
        warn(" Download failed: " .. tostring(code))
    end
# Made using rayfield by Sirius modded by Irfan and Fixed using ChatGPT.

# open source for scriptor ideas.
