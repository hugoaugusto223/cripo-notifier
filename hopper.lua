if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game:GetService("Players").LocalPlayer

if type(setfpscap) == "function" then
	setfpscap(15)
else
	warn("setfpscap não está disponível nesse executor")
end


local CONFIG = {
	API = {
		BASE_URL = "https://airy-enthusiasm-api.up.railway.app",
		ADD_ENDPOINT = "/add",
		GET_JOB_ENDPOINT = "/get-job",
		TOKEN = "Qe4pVJZy7Wn82Xs0bL6tCFAiR3S9dUEq"
	},
	SEARCH = {
		MIN_GENERATION = 0,
		 BRAINROT_NAMES = {
    "Noobini Pizzanini", "Lirilì Larilà", "Tim Cheese", "Fluriflura",
    "Svinina Bombardino", "Talpa Di Fero", "Pipi Kiwi", "Pipi Corni",
    "Raccooni Jandelini", "Tartaragno", "Trippi Troppi", "Gangster Footera",
    "Boneca Ambalabu", "Ta Ta Ta Ta Sahur", "Tric Trac Baraboom", "Bandito Bobritto",
    "Cacto Hipopotamo", "Pipi Avocado", "Pinealotto Fruttarino", "Cupcake Koala",
    "Cappuccino Assassino", "Brr Brr Patapim", "Trulimero Trulicina", "Bananita Dolphinita",
    "Brri Brri Bicus Dicus Bombicus", "Bambini Crostini", "Perochello Lemonchello", "Avocadini Guffo",
    "Salamino Penguino", "Ti Ti Ti Sahur", "Penguino Cocosino", "Avocadini Antilopini",
    "Bandito Axolito", "Malame Amarele", "Mangolini Parrocini", "Mummio Rappitto",
    "Frogato Pirato", "Wombo Rollo", "Doi Doi Do", "Burbaloni Loliloli",
    "Chimpanzini Bananini", "Ballerina Cappuccina", "Chef Crabracadabra", "Glorbo Fruttodrillo",
    "Blueberrinni Octopusini", "Lionel Cactuseli", "Pandaccini Bananini", "Strawberrelli Flamingelli",
    "Cocosini Mama", "Pi Pi Watermelon", "Sigma Boy", "Pipi Potato",
    "Quivioli Ameleonni", "Tirilikalika Tirilikalako", "Caramello Filtrello", "Signore Carapace",
    "Sigma Girl", "Quackula", "Buho de Fuego", "Clickerino Crabo",
    "Frigo Camelo", "Orangutini Ananassini", "Bombardiro Crocodilo", "Bombombini Gusini",
    "Rhino Toasterino", "Cavallo Virtuoso", "Spioniro Golubiro", "Zibra Zubra Zibralini",
    "Tigrilini Watermelini", "Gorillo Watermelondrillo", "Avocadorilla", "Ganganzelli Trulala",
    "Tob Tobi Tobi", "Te Te Te Sahur", "Tracoducotulu Delapeladustuz", "Lerulerulerule",
    "Carloo", "Carrotini Brainini", "Brutto Gialutto", "Gorillo Subwoofero",
    "Los Noobinis", "Rhino Helicopterino", "Elefanto Frigo", "Toiletto Focaccino",
    "Cachorrito Melonito", "Bananito Bandito", "Magi Ribbitini", "Jacko Spaventosa",
    "Stoppo Luminino", "Chihuanini Taconini", "Cocofanto Elefanto", "Tralalero Tralala",
    "Odin Din Din Dun", "Girafa Celestre", "Trenostruzzo Turbo 3000", "Matteo",
    "Tigroligre Frutonni", "Orcalero Orcala", "Unclito Samito", "Gattatino Nyanino",
    "Espresso Signora", "Ballerino Lololo", "Piccione Macchina", "Los Crocodillitos",
    "Tukanno Bananno", "Trippi Troppi Troppa Trippa", "Los Tungtungtungcitos", "Agarrini la Palini",
    "Bulbito Bandito Traktorito", "Los Orcalitos", "Tipi Topi Taco", "Bombardini Tortinii",
    "Tralalita Tralala", "Urubini Flamenguini", "Alessio", "Pakrahmatmamat",
    "Los Bombinitos", "Brr es Teh Patipum", "Tartaruga Cisterna", "Cacasito Satalito",
    "Mastodontico Telepiedone", "Crabbo Limonetta", "Gattito Tacoto", "Los Tipi Tacos",
    "Antonio", "Las Capuchinas", "Orcalita Orcala", "Piccionetta Macchina",
    "Anpali Babel", "Extinct Ballerina", "Tractoro Dinosauro", "Belula Beluga",
    "Capi Taco", "Dug dug dug", "Corn Corn Corn Sahur", "Brasilini Berimbini",
    "Squalanana", "Pop Pop Sahur", "Vampira Cappucina", "Jacko Jack Jack",
    "Snailenzo", "Tentacolo Tecnico", "Pakrahmatmatina", "Bambu Bambu Sahur",
    "Krupuk Pagi Pagi", "Mummy Ambalabu", "Cappuccino Clownino", "Skull Skull Skull",
    "Aquanaut", "Frio Ninja", "Money Money Man", "Noo La Polizia",
    "La Vacca Saturno Saturnita", "Los Tralaleritos", "Graipuss Medussi", "La Grande Combinasion",
    "Sammyni Spyderini", "Garama and Madundung", "Torrtuginni Dragonfrutini", "Las Tralaleritas",
    "Pot Hotspot", "Nuclearo Dinossauro", "Las Vaquitas Saturnitas", "Chicleteira Bicicleteira",
    "Agarrini la Palini", "Los Combinasionas", "Karkerkar Kurkur", "Dragon Cannelloni",
    "Los Hotspotsitos", "Esok Sekolah", "Nooo My Hotspot", "Los Matteos",
    "Job Job Job Sahur", "Dul Dul Dul", "Blackhole Goat", "Los Spyderinis",
    "Ketupat Kepat", "La Supreme Combinasion", "Bisonte Giuppitere", "Guerriro Digitale",
    "Ketchuru and Musturu", "Spaghetti Tualetti", "Los Nooo My Hotspotsitos", "Trenostruzzo Turbo 4000",
    "Fragola La La La", "La Sahur Combinasion", "La Karkerkar Combinasion", "Tralaledon",
    "Los Bros", "Los Chicleteiras", "Chachechi", "Extinct Tralalero",
    "Extinct Matteo", "67", "Las Sis", "Celularcini Viciosini",
    "La Extinct Grande", "Quesadilla Crocodila", "Tacorita Bicicleta", "La Cucaracha",
    "To to to Sahur", "Mariachi Corazoni", "Los Tacoritas", "Tictac Sahur",
    "Yess my examine", "Karker Sahur", "Noo my examine", "Money Money Puggy",
    "Los Primos", "Tang Tang Keletang", "Perrito Burrito", "Chillin Chili",
    "Los Tortus", "Los Karkeritos", "Los Jobcitos", "Los 67",
    "La Secret Combinasion", "Burguro And Fryuro", "Zombie Tralala", "Vulturino Skeletono",
    "Frankentteo", "La Vacca Jacko Linterino", "Chicleteirina Bicicleteirina", "Eviledon",
    "La Spooky Grande", "Los Mobilis", "Spooky and Pumpky", "Boatito Auratito",
    "Horegini Boom", "Rang Ring Bus", "Mieteteira Bicicleteira", "Quesadillo Vampiro",
    "Burrito Bandito", "Chipso and Queso", "Jackorilla", "Pumpkini Spyderini",
    "Trickolino", "Telemorte", "Pot Pumpkin", "Noo my Candy",
    "Los Spooky Combinasionas", "La Casa Boo", "Headless Horseman", "La Taco Combinasion",
    "1x1x1x1", "Capitano Moby", "Guest 666", "Pirulitoita Bicicleteira",
    "Los Puggies", "Los Spaghettis", "Fragrama and Chocrama", "Strawberry Elephant",
    "Meowl", "Mythic Lucky Block", "Brainrot God Lucky Block", "Secret Lucky Block",
    "Admin Lucky Block", "Taco Lucky Block", "Los Lucky Blocks", "Spooky Lucky Block"
},

		EXCLUDED_NAMES = {"craft", "fusing", "ready"},
		SMART_FILTER_THRESHOLD = 50000000
	},
	NETWORK = {
		DEBOUNCE_TIME = 0.2,
		CACHE_DURATION = 1
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


local function log(level, msg)
	print(string.format("[%s][%s] %s", os.date("%H:%M:%S"), level:upper(), msg))
end

local function safeCall(func, msg)
	local ok, res = pcall(func)
	if not ok then log("error", msg or res) end
	return ok and res or nil
end

local function parseValue(str)
	if not str or str == "" then return 0 end
	local n, s = str:match("([%d%.]+)([KMB]?)")
	local m = {K = 1e3, M = 1e6, B = 1e9}
	return (tonumber(n) or 0) * (m[s] or 1)
end


local function getHttpRequestFunction()
	return http_request or request or (syn and syn.request)
		or (fluxus and fluxus.request) or (http and http.request)
end

local function makeRequest(cfg)
	local r = getHttpRequestFunction()
	if not r then return nil end
	local ok, res = pcall(function() return r(cfg) end)
	return ok and res or nil
end

local function optimizeGraphics()
	if not CONFIG.GRAPHICS.DISABLE_LIGHTING then return end
	settings().Rendering.QualityLevel = CONFIG.GRAPHICS.QUALITY_LEVEL
	Lighting.GlobalShadows = false
	Lighting.Brightness = 0
	Lighting.Ambient = Color3.new(0, 0, 0)
end

local function makeInvisible(obj)
	safeCall(function()
		if obj:IsA("BasePart") then
			obj.Transparency = 1
			obj.CastShadow = false
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj.Transparency = 1
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
			obj.Enabled = false
		elseif obj:IsA("Sound") and CONFIG.GRAPHICS.DISABLE_SOUNDS then
			obj.Playing = false
		end
	end)
end

local function setupGraphics()
	optimizeGraphics()
	for _, o in pairs(Workspace:GetDescendants()) do makeInvisible(o) end
	Workspace.DescendantAdded:Connect(makeInvisible)
end


local accentMap = { ["á"]="a",["ã"]="a",["â"]="a",["é"]="e",["ê"]="e",["í"]="i",["ó"]="o",["ô"]="o",["õ"]="o",["ú"]="u",["ç"]="c" }

local function normalizeText(txt)
	txt = txt:lower()
	for a, r in pairs(accentMap) do txt = txt:gsub(a, r) end
	return txt
end

local function cleanHtmlTags(t)
	return (t or ""):gsub("<[^>]*>", ""):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
end

local function isBrainrotPet(name)
	if not name then return false end
	local n = normalizeText(name)
	for _, b in ipairs(CONFIG.SEARCH.BRAINROT_NAMES) do
		if n:find(normalizeText(b), 1, true) then return true end
	end
	return false
end


local function sendPetNotification(name, generation, jobId, uniqueId)
	local now = tick()
	local key = string.format("%s_%s_%s", name, generation, uniqueId or "")
	if lastRequestTime[key] and (now - lastRequestTime[key]) < CONFIG.NETWORK.DEBOUNCE_TIME then
		return false
	end
	lastRequestTime[key] = now

	local payload = {
		name = name,
		generation = generation,
		job_id = jobId, 
		players = #Players:GetPlayers() .. "/8",
		timer = os.date("%d/%m/%Y %H:%M:%S")
	}

	local res = makeRequest({
		Url = CONFIG.API.BASE_URL .. CONFIG.API.ADD_ENDPOINT,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
			["x-token"] = CONFIG.API.TOKEN
		},
		Body = HttpService:JSONEncode(payload)
	})

	if res and (res.StatusCode or res.status or 0) < 300 then
		log("success", "✓ " .. name .. " [" .. generation .. "]")
		return true
	end
	return false
end


local function collectPet(overhead, genText, displayText)
	local value = parseValue(genText)
	if value < CONFIG.SEARCH.MIN_GENERATION then return nil end
	if not isBrainrotPet(displayText) then return nil end

	local key = string.format("%s_%s_%s", displayText, genText, overhead:GetFullName())
	local now = tick()
	if petCache[key] and (now - petCache[key]) < CONFIG.NETWORK.CACHE_DURATION then return nil end
	petCache[key] = now

	return { name = displayText, generation = genText, uniqueId = overhead:GetFullName(), value = value }
end

local function scanPlots()
    local pets = {}
    local now = tick()

    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "AnimalOverhead" and (obj:IsA("BillboardGui") or obj:IsA("SurfaceGui")) then
            local gen = obj:FindFirstChild("Generation")
            local disp = obj:FindFirstChild("DisplayName")
            if gen and disp and gen:IsA("TextLabel") and disp:IsA("TextLabel") then
                local genText, dispText = gen.Text, disp.Text
                if genText ~= "" and dispText ~= "" then
                    local val = parseValue(genText)
                    if isBrainrotPet(dispText) and val >= CONFIG.SEARCH.MIN_GENERATION then
                        local key = string.format("%s_%s_%s_%s", dispText, genText, game.JobId, obj:GetFullName())
                        if not petCache[key] or (now - petCache[key]) >= CONFIG.NETWORK.CACHE_DURATION then
                            petCache[key] = now
                            table.insert(pets, {
                                name = dispText,
                                generation = genText,
                                value = val,
                                uniqueId = obj:GetFullName()
                            })
                        end
                    end
                end
            end
        end
    end

 
    local sent = 0
    for _, pet in ipairs(pets) do
        task.spawn(function()
            local s = sendPetNotification(pet.name, pet.generation, game.JobId, pet.uniqueId)
            if s >= 200 and s < 300 then
                sent += 1
            end
        end)
    end

    return sent
end


local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function serverHop()
	local request = getHttpRequestFunction()
	if not request then
		warn("Nenhum método HTTP compatível encontrado (Synapse, KRNL, etc.)")
		return
	end

	local currentJob = game.JobId
	local maxRetries = 30
	local retrying = false

	local restrictedReasons = {
		["Game instance is closed"] = true,
		["Game instance is restricted"] = true,
		["Game instance is not found"] = true,
		["Teleport failed, server is no longer available"] = true,
	}

	local function getNewJob()
		for i = 1, maxRetries do
			local ok, res = pcall(function()
				return request({
					Url = CONFIG.API.BASE_URL .. CONFIG.API.GET_JOB_ENDPOINT,
					Method = "GET",
					Headers = { ["x-token"] = CONFIG.API.TOKEN }
				})
			end)

			if ok and res and res.StatusCode == 200 and res.Body then
				local success, data = pcall(function()
					return HttpService:JSONDecode(res.Body)
				end)

				if success and data and data.job_id and typeof(data.job_id) == "string" then
					if data.job_id ~= currentJob and (data.players or 0) <= 1 then
						return data.job_id
					end
				end
			end
			task.wait(0.001)
		end
		return nil
	end

	local function handleTeleportFail(_, _, reason)
		retrying = true
		if restrictedReasons[tostring(reason)] then
			warn("[ServerHop] ignorando servidor  " .. tostring(reason))
		else
			warn("[ServerHop] falha ao teleportar " .. tostring(reason))
		end
	end

	TeleportService.TeleportInitFailed:Connect(handleTeleportFail)

	warn("[ServerHop] iniciando hop")

	for attempt = 1, maxRetries do
		retrying = false
		local jobId = getNewJob()

		if not jobId then
			warn(string.format("[Tentativa %d/%d] nenhum servidor vazio encontrado.", attempt, maxRetries))
			task.wait(0.001)
			continue
		end

		warn(string.format("[Tentativa %d/%d] tentando teleportar para %s", attempt, maxRetries, jobId))
		local success, err = pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, Player)
		end)

		if not success then
			warn("[Tentativa " .. attempt .. "] erro no teleport " .. tostring(err))
			task.wait(0.001)
			continue
		end

		local start = tick()
		while tick() - start < 1 do
			task.wait(0.001)
			if retrying then break end
			if game.JobId ~= currentJob then
				warn("[ServerHop] teleport bem suceddisso")
				return
			end
		end

		warn(string.format("[Tentativa %d/%d] servidor falhou...", attempt, maxRetries))
		task.wait(0.001)
	end

	warn("[ServerHop] n foi encontrado um servidor valido")
end





local function main()
	log("info", "iniciando scan")
	setupGraphics()

	local found = safeCall(scanPlots, "erro no scan") or 0
	if found > 0 then
		log("info", "1s antes de hoppar")
		task.wait(1)
	end
	safeCall(serverHop, "erro no server hop")
end

main()
