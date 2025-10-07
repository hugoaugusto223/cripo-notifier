if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game:GetService("Players").LocalPlayer
local CONFIG = {
    API = {
        BASE_URL = "https://notifier-production-081a.up.railway.app",
        ADD_ENDPOINT = "/add",
        GET_JOB_ENDPOINT = "/get-job",
        TOKEN = "Qe4pVJZy7Wn82Xs0bL6tCFAiR3S9dUEq"
    },
    SEARCH = {
        MIN_GENERATION = 0,
        BRAINROT_NAMES = {
            "Bisonte Giuppitere", "Los Matteos", "La Vacca Saturno Saturnita", "Trenostruzzo Turbo 4000", "Torrtuginni Dragonfrutini",
            "Los Tralaleritos", "Las Tralaleritas", "Job Job Job Sahur", "Las Vaquitas Saturnitas", "Graipuss Medussi",
            "To to to Sahur", "Pot Hotspot", "Chicleteira Bicicleteira", "Los Chicleteiras", "La Grande Combinasion",
            "Nuclearo Dinossauro", "Esok Sekolah",
            "Ketupat Kepat", "Tictac Sahur", "Ketchuru and Musturu", "Garama and Madundung", "67",
            "Spaghetti Tualetti", "Dragon Cannelloni", "Secret Lucky Block", "Strawberry Elephant",
            "Guerriro Digitale", "Los Spyderinis", "Blackhole Goat", "Karkerkar Kurkur", "Sammyini Spyderini", "Sammyni Spyderini",
            "Dul Dul Dul", "Chachechi", "Extinct Tralalero", "La Cucaracha", "Extinct Matteo",
            "Mariachi Corazoni", "Tacorita Bicicleta", "La Extinct Grande",
            "Fragola La La La", "La Karkerkar Combinasion", "La Sahur Combinasion", "Las Sis",
            "Celularcini Viciosini", "Los Bros", "Tralaledon", "Los Tacoritas", "Los Primos",
            "Agarrini La Palini", "Los Combinasionas", "Los Hotspotsitos", "La Supreme Combinasion",
            "Nooo My Hotspot", "Quesadilla Crocodila", "Los Nooo My Hotspotsitos",
            "Yess my Examen", "Noo My Examen", "Money Money Puggy", "Burguro And Fryuro", "Tang Tang Keletang", "Los 67", "Chillin Chili", "La Secret Combinasion", "Los Jobcitos", "Los Tortus",
            "Los Karkeritos", "Burguro And Fryuro",
        },
        EXCLUDED_NAMES = {"craft", "fusing", "ready"},
        SMART_FILTER_THRESHOLD = 50000000
    },
    NETWORK = {
        DEBOUNCE_TIME = 0.5,
        CACHE_DURATION = 5
    },
    GRAPHICS = {
        QUALITY_LEVEL = Enum.QualityLevel.Level01,
        DISABLE_LIGHTING = true,
        DISABLE_SOUNDS = true
    }
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local _plots = Workspace:WaitForChild("Plots")
local petCache = {}
local lastRequestTime = {}

local function log(level, message)
    print(string.format("[%s][%s] %s", os.date("%H:%M:%S"), level:upper(), message))
end

local function safeCall(func, errorMessage)
    local success, result1, result2 = pcall(func)
    if not success then
        log("error", errorMessage or "Erro")
        return nil
    end
    if result2 ~= nil then
        return {result1, result2}
    end
    return result1
end

local function parseValue(valueStr)
    if not valueStr or valueStr == "" then return 0 end
    local number, suffix = valueStr:match("([%d%.]+)([KMB]?)")
    if not number then return 0 end
    local multipliers = {K = 1e3, M = 1e6, B = 1e9}
    return (tonumber(number) or 0) * (multipliers[suffix] or 1)
end

local function optimizeGraphics()
    if not CONFIG.GRAPHICS.DISABLE_LIGHTING then return end
    settings().Rendering.QualityLevel = CONFIG.GRAPHICS.QUALITY_LEVEL
    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(0, 0, 0)
    Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    Lighting.FogEnd = 1
    Lighting.FogStart = 0
end

local function makeObjectInvisible(object)
    safeCall(function()
        if object:IsA("BasePart") then
            object.Transparency = 1
            object.CastShadow = false
        elseif object:IsA("Decal") or object:IsA("Texture") then
            object.Transparency = 1
        elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") then
            object.Enabled = false
        elseif object:IsA("Sound") and CONFIG.GRAPHICS.DISABLE_SOUNDS then
            object.Playing = false
        end
    end)
end

local function setupGraphicsOptimization()
    optimizeGraphics()
    for _, obj in pairs(Workspace:GetDescendants()) do
        makeObjectInvisible(obj)
    end
    Workspace.DescendantAdded:Connect(makeObjectInvisible)
end

local function getHttpRequestFunction()
    return http_request or request or 
           (syn and syn.request) or 
           (fluxus and fluxus.request) or 
           (http and http.request)
end

local function makeRequest(config)
    local requestFunc = getHttpRequestFunction()
    if not requestFunc then return nil end
    local success, response = pcall(function()
        return requestFunc(config)
    end)
    return success and response or nil
end

local function sendPetNotification(name, generation, jobId, uniqueId)
    local currentTime = tick()
    local petKey = string.format("%s_%s_%s", name, generation, uniqueId or "")
    
    if lastRequestTime[petKey] and (currentTime - lastRequestTime[petKey]) < CONFIG.NETWORK.DEBOUNCE_TIME then
        return false
    end
    lastRequestTime[petKey] = currentTime
    
    local finalJobId = game.JobId
    local playersCount = #Players:GetPlayers()
    
    local payload = {
        name = name,
        generation = generation,
        job_id = finalJobId,
        players = playersCount .. "/8",
        timer = os.date("%d/%m/%Y %H:%M:%S")
    }
    
    local requestConfig = {
        Url = CONFIG.API.BASE_URL .. CONFIG.API.ADD_ENDPOINT,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["x-token"] = CONFIG.API.TOKEN
        },
        Body = HttpService:JSONEncode(payload)
    }
    
    local response = makeRequest(requestConfig)
    if response then
        local statusCode = response.StatusCode or response.status or 200
        if statusCode >= 200 and statusCode < 300 then
            log("success", string.format("✓ %s [%s]", name, generation))
            return statusCode
        end
        return statusCode
    end
    return 0
end

local function serverHop()
    local attemptCount = 0
    local MAX_ATTEMPTS = 30
    
    while true do
        attemptCount = attemptCount + 1
        
        if attemptCount >= MAX_ATTEMPTS then
            game:Shutdown()
            return
        end
        
        local requestFunc = getHttpRequestFunction()
        if requestFunc then
            local requestConfig = {
                Url = CONFIG.API.BASE_URL .. CONFIG.API.GET_JOB_ENDPOINT,
                Method = "GET",
                Headers = {["x-token"] = CONFIG.API.TOKEN}
            }
            
            local response = requestFunc(requestConfig)
            
            if response and response.Body then
                local data = HttpService:JSONDecode(response.Body)
                if data and data.job_id then
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, data.job_id, Player)
                    end)
                end
            end
        end
        task.wait(0.5)
    end
end

local function isValidPetName(name)
    if not name or name == "" then return false end
    local lowerName = name:lower()
    for _, excluded in ipairs(CONFIG.SEARCH.EXCLUDED_NAMES) do
        if lowerName:find(excluded) then
            return false
        end
    end
    return true
end

local function isValidGeneration(generation)
    if not generation or generation == "" then return false end
    local lowerGen = generation:lower()
    if lowerGen:find("craft") or lowerGen:find("fus") then return false end
    if lowerGen:match("%d+m%s+%d+s") or lowerGen:match("%d+s") then return false end
    return true
end

local accentMap = {
    ["á"] = "a", ["à"] = "a", ["ã"] = "a", ["â"] = "a", ["ä"] = "a",
    ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["ë"] = "e",
    ["í"] = "i", ["ì"] = "i", ["î"] = "i", ["ï"] = "i",
    ["ó"] = "o", ["ò"] = "o", ["õ"] = "o", ["ô"] = "o", ["ö"] = "o",
    ["ú"] = "u", ["ù"] = "u", ["û"] = "u", ["ü"] = "u",
    ["ç"] = "c", ["ñ"] = "n", ["ý"] = "y", ["ÿ"] = "y"
}

local function normalizeText(text)
    if not text then return "" end
    local normalized = text:lower()
    for accent, replacement in pairs(accentMap) do
        normalized = normalized:gsub(accent, replacement)
    end
    return normalized:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function cleanHtmlTags(text)
    if not text then return "" end
    -- Remove todas as tags HTML
    text = string.gsub(text, "<[^>]*>", "")
    -- Remove espaços extras
    text = string.gsub(text, "%s+", " ")
    -- Remove espaços no início e fim
    text = string.gsub(text, "^%s*(.-)%s*$", "%1")
    return text
end

local function isBrainrotPet(name)
    if not name then return false end

    local normalizedName = normalizeText(name)

    for _, brainrotName in ipairs(CONFIG.SEARCH.BRAINROT_NAMES) do
        if normalizedName:find(normalizeText(brainrotName), 1, true) then
            return true
        end
    end

    return false
end

local function collectPetFromOverhead(overhead, genText, displayText)
    local generationValue = parseValue(genText)
    local brainrotName = displayText
    
    if not isValidPetName(brainrotName) then 
        return nil 
    end
    if not isValidGeneration(genText) then 
        return nil 
    end
    if not isBrainrotPet(brainrotName) then 
        return nil 
    end
    if generationValue < CONFIG.SEARCH.MIN_GENERATION then 
        return nil 
    end
    
    local petKey = string.format("%s_%s_%s_%s", brainrotName, genText, game.JobId, overhead:GetFullName())
    local currentTime = tick()
    
    if petCache[petKey] and (currentTime - petCache[petKey]) < CONFIG.NETWORK.CACHE_DURATION then
        return nil
    end
    petCache[petKey] = currentTime
    return {
        name = brainrotName,
        generation = genText,
        value = generationValue,
        uniqueId = overhead:GetFullName()
    }
end

local function scanPlots()
    local playersCount = #Players:GetPlayers()
    if playersCount >= 8 then return 0 end
    
    local collectedPets = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("SurfaceGui") or obj:IsA("BillboardGui")) and obj.Name == "AnimalOverhead" then
            local gen = obj:FindFirstChild("Generation")
            local display = obj:FindFirstChild("DisplayName")
            local mut = obj:FindFirstChild("Mutation")
            
            if gen and gen:IsA("TextLabel") and display and display:IsA("TextLabel") and mut and mut:IsA("TextLabel") then
                local genText = gen.Text
                local displayText = display.Text
                local mutText = mut.Text
                
                if genText ~= "" and displayText ~= "" and mutText ~= "" and mut.Visible == true then
                    local cleanMutText = cleanHtmlTags(mutText)
                    
                    if cleanMutText ~= "Normal" and cleanMutText ~= "" then
                        local brainrotName = cleanMutText .. " " .. displayText
                        local pet = collectPetFromOverhead(obj, genText, brainrotName)
                        if pet then
                            table.insert(collectedPets, pet)
                        end
                    else
                        local pet = collectPetFromOverhead(obj, genText, displayText)
                        if pet then
                            table.insert(collectedPets, pet)
                        end
                    end
                elseif genText ~= "" and displayText ~= "" and mut.Visible == false then
                    local pet = collectPetFromOverhead(obj, genText, displayText)
                    if pet then
                        table.insert(collectedPets, pet)
                    end
                end
            end
        end
    end
    
    if #collectedPets == 0 then return 0 end
    
    local hasHighValuePets = false
    local threshold = CONFIG.SEARCH.SMART_FILTER_THRESHOLD
    
    for _, pet in ipairs(collectedPets) do
        if pet.value >= threshold then
            hasHighValuePets = true
            break
        end
    end
    
    local petsToSend = {}
    if hasHighValuePets then
        for _, pet in ipairs(collectedPets) do
            if pet.value >= threshold then
                table.insert(petsToSend, pet)
            end
        end
    else
        petsToSend = collectedPets
    end
    
    local sentCount = 0
    local allStatusCodes = {}
    
    for i, pet in ipairs(petsToSend) do
        local statusCode = sendPetNotification(pet.name, pet.generation, game.JobId, pet.uniqueId)
        table.insert(allStatusCodes, statusCode)
        if statusCode >= 200 and statusCode < 300 then
            sentCount = sentCount + 1
        end
        if i < #petsToSend then
            task.wait(0.01)
        end
    end
    
    return sentCount, allStatusCodes
end

local function mainLoop()
    log("info", "Notificador iniciado")
    setupGraphicsOptimization()
    
    local result = safeCall(function()
        return scanPlots()
    end, "Erro na varredura")
    
    local found, statusCodes
    if result then
        if type(result) == "table" and result[1] and result[2] then
            found = result[1]
            statusCodes = result[2]
        else
            found = result
            statusCodes = {}
        end
    else
        found = 0
        statusCodes = {}
    end
    
    if found and found > 0 then
        local allRequestsSuccessful = true
        if statusCodes and #statusCodes > 0 then
            for _, statusCode in ipairs(statusCodes) do
                if statusCode < 200 or statusCode >= 300 then
                    allRequestsSuccessful = false
                    break
                end
            end
        else
            allRequestsSuccessful = false
        end
        if allRequestsSuccessful then
            log("info", string.format("%d pets notificados - aguardando 2s...", found))
            task.wait(2)
            safeCall(serverHop, "Erro no server hop")
        else
            safeCall(serverHop, "Erro no server hop")
        end
    else
        safeCall(serverHop, "Erro no server hop")
    end

end

_G.stopNotifier = function()
    log("info", "Notificador parado")
end

mainLoop()
