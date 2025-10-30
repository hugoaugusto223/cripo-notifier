if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game:GetService("Players").LocalPlayer

local CONFIG = {
    SEARCH = {
        MIN_GENERATION = 0,
        BRAINROT_NAMES = {
            "La Vacca Saturno Saturnita", "Los Tralaleritos", "Graipuss Medussi", "La Grande Combinasion", "Sammyni Spyderini",
            "Garama and Madundung", "Torrtuginni Dragonfrutini", "Las Tralaleritas", "Pot Hotspot", "Nuclearo Dinossauro",
            "Las Vaquitas Saturnitas", "Chicleteira Bicicleteira", "Agarrini la Palini", "Los Combinasionas", "Karkerkar Kurkur",
            "Dragon Cannelloni", "Los Hotspotsitos", "Esok Sekolah", "Nooo My Hotspot", "Los Matteos",
            "Job Job Job Sahur", "Dul Dul Dul", "Blackhole Goat", "Los Spyderinis", "Ketupat Kepat",
            "La Supreme Combinasion", "Bisonte Giuppitere", "Guerriro Digitale", "Ketchuru and Musturu", "Spaghetti Tualetti",
            "Los Nooo My Hotspotsitos", "Trenostruzzo Turbo 4000", "Fragola La La La", "La Sahur Combinasion", "La Karkerkar Combinasion",
            "Tralaledon", "Los Bros", "Los Chicleteiras", "Chachechi", "Extinct Tralalero",
            "Extinct Matteo", "67", "Las Sis", "Celularcini Viciosini", "La Extinct Grande",
            "Quesadilla Crocodila", "Tacorita Bicicleta", "La Cucaracha", "To to to Sahur", "Mariachi Corazoni",
            "Los Tacoritas", "Tictac Sahur", "Yess my examine", "Karker Sahur", "Noo my examine",
            "Money Money Puggy", "Los Primos", "Tang Tang Keletang", "Perrito Burrito", "Chillin Chili",
            "Los Tortus", "Los Karkeritos", "Los Jobcitos", "Los 67", "La Secret Combinasion",
            "Burguro And Fryuro", "Zombie Tralala", "Vulturino Skeletono", "Frankentteo", "La Vacca Jacko Linterino",
            "Chicleteirina Bicicleteirina", "Eviledon", "La Spooky Grande", "Los Mobilis", "Spooky and Pumpky",
            "Boatito Auratito", "Horegini Boom", "Rang Ring Bus", "Mieteteira Bicicleteira", "Quesadillo Vampiro",
            "Burrito Bandito", "Chipso and Queso", "Jackorilla", "Pumpkini Spyderini", "Trickolino",
            "Telemorte", "Pot Pumpkin", "Noo my Candy", "Los Spooky Combinasionas", "La Casa Boo",
            "Headless Horseman", "Strawberry Elephant", "Meowl"
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

local WEBHOOK_URLS = {
    ["10m"] = "https://discord.com/api/webhooks/1425192989155917857/KApEnVW2TNn3RCcPF-VJQNDyZTshcXWxav_mKXl3LIKleivJTVFOYx9PjVl1lUvzv2cg",
    ["50m"] = "https://discord.com/api/webhooks/1425192997527621714/AC1q5JRXZcyzLz0CPFWGl6EnYt3dwKj_cl4fCwTJRZidY6G0k1ZuvQoreofd2BP0S0fy",
    ["100m"] = "https://discord.com/api/webhooks/1425193000954236949/nZNdXypM03Oh7QOSU4nWZJmN-SA3i7jGSvpKuqVVIiEpe2iJ8FFW8FmDKFuXgpyvDdqQ",
    ["300m"] = "https://discord.com/api/webhooks/1425193003571609723/z-QsxJLU6U4FzUZ5IxK7y2h1RKsFF2ovcc2O9ew_v-WQzlZ7M9Qd8IaHAH5hts9_7Jbi"
}

local ROLE_MENTIONS = {
    ["10m"] = "<@&1425222603567530098>",
    ["50m"] = "<@&1425222834808164412>",
    ["100m"] = "<@&1425222874087686154>",
    ["300m"] = "<@&1425222652271923230>"
}

local IMAGE_MAP = {
    -- ["los 67"] = "https://cdn.discordapp.com/attachments/xxx/xxx/xxx.webp"
}

local EVERYONE = 300000000

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
    print(string.format("[%s][%s] %s", os.date("%H:%M:%S"), string.upper(level), tostring(message)))
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

local ENCODE_MAP = {
    a="G7Q", b="L2R", c="M8X", d="K5T", e="N9V", f="P3Z", g="Q6B", h="R1F",
    i="S4J", j="T0M", k="U7C", l="V2G", m="W8K", n="X5N", o="Y9P", p="Z3S",
    q="A6U", r="B1X", s="C4A", t="D0D", u="E7F", v="F2H", w="H8J", x="I5L",
    y="J9O", z="K3Q",
    A="m6Z", B="n1B", C="o4D", D="p0F", E="q7H", F="r2J", G="s8L", H="t5N",
    I="u9P", J="v3R", K="w6T", L="x1V", M="y4X", N="z0A", O="A7C", P="B2E",
    Q="C8G", R="D5I", S="E9K", T="F3M", U="G6O", V="H1Q", W="I4S", X="J0U",
    Y="K7W", Z="L2Y",
    ["0"]="p7Q", ["1"]="q2R", ["2"]="r8T", ["3"]="s5V", ["4"]="t9X", ["5"]="u3Z",
    ["6"]="v6B", ["7"]="w1D", ["8"]="x4F", ["9"]="y0H", ["-"]="z7J"
}

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
    text = string.gsub(text, "<[^>]*>", "")
    text = string.gsub(text, "%s+", " ")
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

local function parseGeneration(genStr)
    genStr = string.gsub(genStr, "%$", "")
    genStr = string.gsub(genStr, "/s", "")
    genStr = string.upper(genStr)
    local number, suffix = string.match(genStr, "([%d%.]+)([KMB]?)")
    number = tonumber(number) or 0
    if suffix == "K" then
        number = number * 1e3
    elseif suffix == "M" then
        number = number * 1e6
    elseif suffix == "B" then
        number = number * 1e9
    end
    return number
end

local function determineTier(value)
    if value >= 10000000 and value < 50000000 then
        return "10m"
    elseif value >= 50000000 and value < 100000000 then
        return "50m"
    elseif value >= 100000000 and value < 300000000 then
        return "100m"
    elseif value >= 300000000 then
        return "300m"
    else
        return nil
    end
end

local function getMention(value)
    local tier = determineTier(value)
    return ROLE_MENTIONS[tier] or ""
end

local function getThumbnailUrl(petName)
    local lowerName = string.lower(petName or "")
    for imageKey, imageUrl in pairs(IMAGE_MAP) do
        if string.find(lowerName, string.lower(imageKey), 1, true) then
            return imageUrl
        end
    end
    return "https://cdn.discordapp.com/attachments/1416974801255399525/1416983746137034793/Unknown.webp?ex=68c8d473&is=68c782f3&hm=7dd12288ae192a42b0e0dd8219eac9e7ee8fc86e44cc12c16d0d6dacdfb87749&"
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

local function collectPetFromOverhead(overhead, genText, displayText)
    local generationValue = parseGeneration(genText)
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

local function sendToWebhook(petData)
    local value = parseGeneration(petData.generation)
    local tier = determineTier(value)
    if not tier then return end

    local webhookUrl = WEBHOOK_URLS[tier]
    if not webhookUrl or webhookUrl == "" then
        return
    end

    local content = getMention(value)
    local thumbnailUrl = getThumbnailUrl(petData.name)
    local jobId = game.JobId

    local embed = {
        ["title"] = "CripoToMan - Notifier",
        ["type"] = "rich",
        ["color"] = 62973,
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        ["fields"] = {
            {["name"] = "\240\159\143\183 Name", ["value"] = "**```"..petData.name.."```**", ["inline"] = true},
            {["name"] = "\240\159\148\176 Money per second", ["value"] = "**```"..petData.generation.."```**", ["inline"] = true},
            {["name"] = "\240\159\145\165 Players", ["value"] = "**```"..petData.players.."```**", ["inline"] = true},
            {["name"] = "Job-ID", ["value"] = "```"..jobId.."```", ["inline"] = false},
        },
        ["thumbnail"] = {
            ["url"] = thumbnailUrl
        },
        ["footer"] = {
            ["text"] = "\194\169 All rights reserved - Cripo."
        }
    }

    local payload = {
        ["content"] = content,
        ["embeds"] = {embed}
    }

    local requestFunc = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
    if requestFunc then
        requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end
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
                local generationValue = parseGeneration(genText)

                if genText ~= "" and displayText ~= "" and mutText.Text ~= "" and mut.Visible == true then
                    local cleanMutText = cleanHtmlTags(mutText)
                    local brainrotName = cleanMutText ~= "Normal" and cleanMutText.." "..displayText or displayText
                    local pet = collectPetFromOverhead(obj, genText, brainrotName)
                    if pet then
                        pet.players = playersCount.."/8"
                        table.insert(collectedPets, pet)
                    end
                elseif genText ~= "" and displayText ~= "" and mut.Visible == false then
                    local pet = collectPetFromOverhead(obj, genText, displayText)
                    if pet then
                        pet.players = playersCount.."/8"
                        table.insert(collectedPets, pet)
                    end
                end
            end
        end
    end

    for _, pet in ipairs(collectedPets) do
        local value = parseGeneration(pet.generation)
        local tier = determineTier(value)
        if tier == "10m" or tier == "50m" or tier == "100m" or tier == "300m" then
            sendToWebhook(pet)
            task.wait(0.05)
        end
    end
    return #collectedPets
end

-- SERVER HOP CON RETRIES Y LOGICA DE TU EJEMPLO
local API_URL = "https://api-skidded-skidded.up.railway.app/get-server"
local PLACE_ID = 109983668079237
local LocalPlayer = Players.LocalPlayer
local attempt = 0

local function Parse_JSON(url, method)
    local requestFunc = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
    if not requestFunc then return false, nil end
    local resp = requestFunc({
        Url = url,
        Method = method or "GET"
    })
    return true, resp
end

Get_JobID = function()
    while true do
        attempt += 1
        local ok, resp = Parse_JSON(API_URL, "GET")
        local jobId
        if ok and resp and resp.Body then
            local success, data = pcall(function()
                return HttpService:JSONDecode(resp.Body)
            end)
            if success and data and data.job_id and data.job_id ~= "" then
                jobId = data.job_id
            end
        end
        if jobId then
            print(string.format("[Relay] Got JobID %s on attempt %d", jobId, attempt))
            return jobId
        else
            local waitTime = 0.25 + math.random() * 0.5
            warn(string.format("[Relay] Failed to get JobID on attempt %d, retrying in %.2fs...", attempt, waitTime))
            task.wait(waitTime)
        end
    end
end

Teleport_To_Server = function()
    local JobID = Get_JobID() or ""
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, JobID, LocalPlayer)
    end)
    if success then
        print(string.format("[Relay] Attempting to teleport to %s (attempt %d)", JobID, attempt))
        return
    end
end

TeleportService.TeleportInitFailed:Connect(function(player, reason)
    attempt += 1
    warn(string.format("[Relay] Teleport failed (attempt %d), retrying...", attempt))
    task.wait(0.3 + math.random() * 0.2)
    Teleport_To_Server()
end)

local function mainLoop()
    log("info", "Notificador iniciado")
    setupGraphicsOptimization()
    safeCall(scanPlots, "Erro na varredura")
    task.wait(2)
    Teleport_To_Server()
end

_G.stopNotifier = function()
    log("info", "Notificador parado")
end

mainLoop()
