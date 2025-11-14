if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game:GetService("Players").LocalPlayer

setfpscap(15)


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
"Lucky Block", "La Vacca Saturno Saturnita", "Karkerkar Kurkur", "Los Matteos", "Bisonte Giuppitere", "Trenostruzzo Turbo 4000", "Jackorilla", "Sammyni Spyderini", "Torrtuginni Dragonfrutini", "Dul Dul Dul", "Blackhole Goat", "Chachechi", "Agarrini la Palini", "Los Spyderinis", "Fragola La La La", "Extinct Tralalero", "La Cucaracha", "Los Tralaleritos", "Los Tortus", "Zombie Tralala", "Vulturino Skeletono", "Boatito Auratito", "Guerriro Digitale", "Yess my examine", "La Karkerkar Combinasion", "Extinct Matteo", "Las Tralaleritas", "Pumpkini Spyderini", "Job Job Job Sahur", "Frankentteo", "Karker Sahur", "Las Vaquitas Saturnitas", "Los Karkeritos", "La Vacca Jacko Linterino", "Trickolino", "Graipuss Medussi", "Perrito Burrito", "1x1x1x1", "Nooo My Hotspot", "Los Jobcitos", "Noo my examine", "La Sahur Combinasion", "Telemorte", "To to to Sahur", "Pot Hotspot", "Pirulitoita Bicicleteira", "Horegini Boom", "Quesadilla Crocodila", "Pot Pumpkin", "Chicleteira Bicicleteira", "Quesadillo Vampiro", "Chicleteirina Bicicleteirina", "Burrito Bandito", "Noo my Candy", "Los Nooo My Hotspotsitos", "Rang Ring Bus", "Guest 666", "Los Chicleteiras", "67", "La Grande Combinasion", "Mariachi Corazoni", "Nuclearo Dinossauro", "Los Combinasionas", "Tacorita Bicicleta", "Las Sis", "Los Hotspotsitos", "Los Spooky Combinasionas", "Money Money Puggy", "Los Mobilis", "Celularcini Viciosini", "Los 67", "La Extinct Grande", "Los Bros", "La Spooky Grande", "Chillin Chili", "Chipso and Queso", "Mieteteira Bicicleteira", "Tralaledon", "Esok Sekolah", "Los Puggies", "Los Primos", "Eviledon", "Los Tacoritas", "Tang Tang Keletang", "Ketupat Kepat", "La Taco Combinasion", "Tictac Sahur", "La Supreme Combinasion", "Ketchuru and Musturu", "Garama and Madundung", "Spaghetti Tualetti", "Los Spaghettis", "Spooky and Pumpky", "La Casa Boo", "Fragrama and Chocrama", "La Secret Combinasion", "Burguro And Fryuro", "Capitano Moby", "Headless Horseman", "Dragon Cannelloni", "Meowl", "Strawberry Elephant"
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
	return http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
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

	if res and res.StatusCode and res.StatusCode >= 200 and res.StatusCode < 300 then
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

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == "AnimalOverhead" and (obj:IsA("BillboardGui") or obj:IsA("SurfaceGui")) then
			local gen = obj:FindFirstChild("Generation")
			local disp = obj:FindFirstChild("DisplayName")

			if gen and disp then
				local genText = gen.Text
				local dispText = disp.Text
				local val = parseValue(genText)

				if genText ~= "" and dispText ~= ""
					and isBrainrotPet(dispText)
					and val >= CONFIG.SEARCH.MIN_GENERATION
				then
					local key = dispText .. "_" .. genText .. "_" .. obj:GetFullName()
					if not petCache[key] or (now - petCache[key]) >= CONFIG.NETWORK.CACHE_DURATION then
						petCache[key] = now
						table.insert(pets, {
							name = dispText,
							generation = genText,
							uniqueId = obj:GetFullName()
						})
					end
				end
			end
		end
	end

	return pets
end

local function sendAllWithRetry(pets)
	if #pets == 0 then return true end

	local failed = {}

	for _, pet in ipairs(pets) do
		local ok = sendPetNotification(pet.name, pet.generation, game.JobId, pet.uniqueId)
		if not ok then
			table.insert(failed, pet)
		end
	end

	if #failed == 0 then return true end

	task.wait(5)

	local failedAgain = {}

	for _, pet in ipairs(failed) do
		local ok = sendPetNotification(pet.name, pet.generation, game.JobId, pet.uniqueId)
		if not ok then
			table.insert(failedAgain, pet)
		end
	end

	return #failedAgain == 0
end

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- 🔄 SERVER HOP (versão otimizada)
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function serverHop()
	local request = http_request or request or (syn and syn.request)
	if not request then
		warn("[ServerHop] Nenhum método HTTP suportado encontrado")
		return
	end

	local currentJob = game.JobId
	local maxRetries = 10
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

				-- 🔍 apenas servidor diferente, vazio e válido
				if success and data and typeof(data.job_id) == "string" then
					local playersCount = tonumber(data.players or 0)
					if data.job_id ~= currentJob and playersCount <= 1 then
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
			warn("[ServerHop] servidor inválido (" .. tostring(reason) .. "), ignorando...")
		else
			warn("[ServerHop] falha ao teleportar: " .. tostring(reason))
		end
	end

	TeleportService.TeleportInitFailed:Connect(handleTeleportFail)

	warn("[ServerHop] iniciando varredura de servidores...")

	for attempt = 1, maxRetries do
		retrying = false
		local jobId = getNewJob()

		if not jobId then
			warn(string.format("[Tentativa %d/%d] nenhum servidor vazio encontrado.", attempt, maxRetries))
			task.wait(0.001)
			continue
		end

		warn(string.format("[Tentativa %d/%d] tentando entrar no servidor %s", attempt, maxRetries, jobId))
		local success, err = pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, Player)
		end)

		if not success then
			warn("[ServerHop] erro ao teleportar: " .. tostring(err))
			task.wait(0.001)
			continue
		end

		local start = tick()
		while tick() - start < 1 do
			task.wait(0.001)
			if retrying then break end
			if game.JobId ~= currentJob then
				warn("[ServerHop] teleporte concluido")
				return
			end
		end

		warn(string.format("[ServerHop] servidor falhou (%d/%d)", attempt, maxRetries))
		task.wait(0.001)
	end

	warn("[ServerHop] nenhum servidor valido encontrado " .. maxRetries .. " tentativas.")
end


local function main()
	log("info", "iniciando scan")
	setupGraphics()

	local pets = safeCall(scanPlots, "erro no scan") or {}

	if #pets == 0 then
		log("info", "nenhum pet encontrado")
		safeCall(serverHop, "erro no server hop")
		return
	end

	local allOk = safeCall(function()
		return sendAllWithRetry(pets)
	end, "erro ao enviar requests")

	if allOk then
		log("success", "todos funcionou")
		task.wait(1)
		safeCall(serverHop, "erro no server hop")
	else
		log("warn", "alguns falhou mesmo após retry")
	end
end

main()
