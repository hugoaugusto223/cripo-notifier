if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer


local PLACE_ID = 109983668079237
local CONSUME_URL = "https://tranquil-miracle-js.up.railway.app/consume"
local CLIENT_ID = "cuzinhoHopper"


local THRESHOLD = 1_000_000
local REPORT_URL = "https://airy-enthusiasm-api.up.railway.app/add"
local SCAN_INTERVAL = 0.3         
local SCAN_WARMUP_TIME = 3.0       


local BURST_COUNT = 999      
local BURST_DELAY = 2      


local POLL_DELAY_EMPTY = 2
local TELEPORT_RETRY_DELAY = 0.5
local TELEPORT_MAX_RETRIES_SAME = 2
local AUTH_HEADER = nil



local function getRequest()
    return (syn and syn.request)
        or (http and (http.request or http.request_async))
        or http_request
        or request
        or (fluxus and fluxus.request)
        or (krnl and krnl.request)
        or nil
end
local request = getRequest()
if not request then
    warn("[ServerHop] Nenhuma função HTTP do executor encontrada (syn.request/http_request/request/...).")
    return
end


local function postJson(url, bodyTable)
    local body = HttpService:JSONEncode(bodyTable or {})
    local headers = { ["Content-Type"] = "application/json", ["Accept"] = "application/json" }
    if AUTH_HEADER then headers["Authorization"] = AUTH_HEADER end

    local res
    local ok, err = pcall(function()
        res = request({ Url = url, Method = "POST", Headers = headers, Body = body })
    end)
    if not ok then return nil, "request error: " .. tostring(err) end

    local status = res.StatusCode or res.Status or res.status or 0
    local text = res.Body or res.body or ""
    if status == 204 then return "NO_CONTENT", nil end
    if status >= 200 and status < 300 then
        if not text or #text == 0 then return nil, "empty body" end
        local ok2, decoded = pcall(function() return HttpService:JSONDecode(text) end)
        if ok2 then return decoded, nil else return nil, "json decode error: " .. tostring(decoded) end
    end
    return nil, ("HTTP %s: %s"):format(tostring(status), tostring(text))
end

local function postWebhook(url, payload)
    local body = HttpService:JSONEncode(payload or {})
    local headers = { 
        ["Content-Type"] = "application/json",
        ["x-token"] = X_TOKEN
    }
    local ok, resOrErr = pcall(function()
        return request({ Url = url, Method = "POST", Headers = headers, Body = body })
    end)
    if not ok then
        warn("[Webhook] Falha de request: ", resOrErr)
        return false
    end
    local status = resOrErr.StatusCode or resOrErr.Status or resOrErr.status or 0
    local respBody = resOrErr.Body or resOrErr.body or ""
    if status < 200 or status >= 300 then
        warn(string.format("[Webhook] HTTP %d: %s", status, respBody))
        return false
    end
    print("[Webhook] Sucesso: ", respBody)
    return true
end



local function consumeJob()
    local decoded, err = postJson(CONSUME_URL, { client = CLIENT_ID })
    if not decoded and err then
        warn("[ConsumeJob] Falha HTTP ou JSON: ", err)
        return nil, err
    end
    if decoded == "NO_CONTENT" then return nil, nil end
    if type(decoded) == "table" and decoded.job then
        return tostring(decoded.job), nil
    end
    warn("[ConsumeJob] Resposta inesperada: ", HttpService:JSONEncode(decoded or {}))
    return nil, "resposta sem campo 'job'"
end



local function parseGen(text)
    text = tostring(text or ""):gsub("[%$,%s]", "")
    local n, s = text:match("([%d%.]+)%s*([KMBkmb]?)"); n = tonumber(n) or 0; s = (s or ""):upper()
    if s == "K" then n = n * 1e3 elseif s == "M" then n = n * 1e6 elseif s == "B" then n = n * 1e9 end
    return n
end

local function getTextLabelText(parent, name)
    local obj = parent:FindFirstChild(name, true)
    if obj and obj:IsA("TextLabel") then
        local t = tostring(obj.Text or ""); if #t > 0 then return t end
    end
end

local function getParentStructure(obj)
    local plots = Workspace:FindFirstChild("Plots")
    local podiums = Workspace:FindFirstChild("AnimalPodiums")
    local p = obj
    while p and p ~= Workspace do
        if (plots and p.Parent == plots) or (podiums and p.Parent == podiums) then return p end
        p = p.Parent
    end
end

local function normalizeOwnerTextFromSign(t)
    t = tostring(t or ""):gsub("’", "'")
    t = t:gsub("^%s+", ""):gsub("%s+$", "")
    t = t:gsub("^Owner[:%s]+", ""):gsub("^Dono[:%s]+", ""):gsub("^Base[:%s]+", "")
    t = t:gsub("^Owned by[:%s]+", ""):gsub("^By[:%s]+", "")
    local before, after = t:match("^(.-)'s%s*(.+)$")
    if before and after and after:lower():find("^base$") then t = before end
    return (t:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function displayToUsername(display, base)
    if not display or display == "" then return nil end
    display = normalizeOwnerTextFromSign(display)
    local at = display:match("@([%w_%.]+)"); if at and #at > 0 then return at end
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if (plr.DisplayName or ""):lower() == display:lower() then
            local dist = math.huge
            local basePart = (base and base:IsA("Model")) and (base.PrimaryPart or base:FindFirstChild("HumanoidRootPart") or base:FindFirstChildWhichIsA("BasePart", true)) or nil
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if basePart and hrp then dist = (hrp.Position - basePart.Position).Magnitude end
            if dist < bestDist then best, bestDist = plr, dist end
        end
    end
    return best and best.Name or nil
end

local function getOwnerFromPlotSign(base)
    if not base then return nil end
    local plotSign = base:FindFirstChild("PlotSign", true)
    if not plotSign then return nil end
    local direct = {
        plotSign:FindFirstChild("OwnerName", true),
        plotSign:FindFirstChild("UserName", true),
        plotSign:FindFirstChild("PlayerName", true),
        plotSign:FindFirstChild("Owner", true),
    }
    for _, v in ipairs(direct) do
        if v and v:IsA("StringValue") and v.Value and #v.Value > 0 then
            local uname = displayToUsername(v.Value, base); if uname then return uname end
        end
        if v and v:IsA("ObjectValue") and v.Value and v.Value:IsA("Player") then
            return v.Value.Name
        end
        if v and v:IsA("NumberValue") and tonumber(v.Value) then
            local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, tonumber(v.Value))
            if ok and name then return name end
        end
    end
    for _, d in ipairs(plotSign:GetDescendants()) do
        if d:IsA("TextLabel") then
            local raw = tostring(d.Text or "")
            if #raw > 0 and not raw:lower():find("collect") then
                local uname = displayToUsername(raw, base)
                if uname then return uname end
            end
        end
    end
    return nil
end

local function getBaseOwnerName(base)
    local fromSign = getOwnerFromPlotSign(base)
    if fromSign and #fromSign > 0 then return fromSign end
    local cand = { base:FindFirstChild("Owner"), base:FindFirstChild("OwnerName"), base:FindFirstChild("PlotOwner"), base:FindFirstChild("UserName") }
    for _, v in ipairs(cand) do
        if v and v:IsA("StringValue") and v.Value and #v.Value > 0 then
            local uname = displayToUsername(v.Value, base); if uname then return uname end
            return v.Value
        end
        if v and v:IsA("ObjectValue") and v.Value and v.Value:IsA("Player") then return v.Value.Name end
        if v and v:IsA("NumberValue") and tonumber(v.Value) then
            local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, tonumber(v.Value))
            if ok and name then return name end
            return ("UserId %d"):format(tonumber(v.Value))
        end
    end
    for _, d in ipairs(base:GetDescendants()) do
        if d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
            local label = d:FindFirstChildWhichIsA("TextLabel", true)
            if label and label.Text and #label.Text > 0 and not label.Text:lower():find("collect") then
                local uname = displayToUsername(label.Text, base)
                if uname then return uname end
            end
        end
    end
    return nil
end

local function collectAllEntries()
    local roots, list = {}, {}
    local plots, podiums = Workspace:FindFirstChild("Plots"), Workspace:FindFirstChild("AnimalPodiums")
    if plots then roots[#roots+1] = plots end
    if podiums then roots[#roots+1] = podiums end
    for _, root in ipairs(roots) do
        for _, gui in ipairs(root:GetDescendants()) do
            if gui:IsA("BillboardGui") and gui.Name == "AnimalOverhead" then
                local dn = getTextLabelText(gui, "DisplayName")
                local gn = getTextLabelText(gui, "Generation")
                local rr = getTextLabelText(gui, "Rarity")
                if dn and gn and rr then
                    local low = gn:lower()
                    if (not low:find("fusing")) and (not gn:find("%s")) then
                        local lr = rr:lower()
                        if lr == "secret" or lr == "og" then
                            local base = getParentStructure(gui)
                            list[#list+1] = { gui = gui, name = dn, genText = gn, rarity = rr, value = parseGen(gn), base = base }
                        end
                    end
                end
            end
        end
    end
    return list
end

local function pickBest(entries)
    local best, val = nil, -math.huge
    for _, it in ipairs(entries) do
        if it.value > val then best, val = it, it.value end
    end
    return best
end

local function makeSignature(baseName, items)
    table.sort(items, function(a, b)
        if a.value ~= b.value then return a.value > b.value end
        if a.name == b.name then return a.genText < b.genText end
        return a.name < b.name
    end)
    local parts = { tostring(baseName or "nil") }
    for _, it in ipairs(items) do parts[#parts+1] = it.name .. "|" .. it.genText end
    return table.concat(parts, "||")
end

local function formatNum(n)
    if n >= 1e9 then return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.2fK", n / 1e3)
    else return tostring(math.floor(n)) end
end

local function sendReport(bestItem, base, items)
    if not REPORT_URL or REPORT_URL == "" then return end

    local grouped = {}
    for _, it in ipairs(items) do
        local key = it.name .. "||" .. it.genText
        local g = grouped[key]
        if g then g.count = g.count + 1 else grouped[key] = { name = it.name, genText = it.genText, value = it.value, count = 1 } end
    end
    local groups = {}
    for _, g in pairs(grouped) do groups[#groups+1] = g end
    table.sort(groups, function(a, b)
        if a.value ~= b.value then return a.value > b.value end
        if a.name ~= b.name then return a.name < b.name end
        return a.genText < b.genText
    end)

    local title = string.format("%s (%s)", tostring(bestItem.name), tostring(bestItem.genText))
    local lines = {}
    for _, g in ipairs(groups) do
        lines[#lines+1] = string.format("%dx %s (%s)", g.count, tostring(g.name), tostring(g.genText))
    end
    local descBlock = "```" .. table.concat(lines, "\n") .. "```"

    local jobId = tostring(game.JobId)
    local ownerName = getBaseOwnerName(base) or "Unknown"
    local players = #Players:GetPlayers()

    local payload = {
        client = CLIENT_ID,
        jobId = jobId,
        baseOwner = ownerName,
        playersOnline = players,
        category = "DEFAULT",
        bestItem = { name = bestItem.name, genText = bestItem.genText, value = bestItem.value },
        
        items = groups
    }

    print(string.format("[Scan] enviando report p/ API: melhor %s (%s), itens: %d", tostring(bestItem.name), tostring(bestItem.genText), #items))
    postWebhook(REPORT_URL, payload)
end

_G.__BrainrotBaseBatches = _G.__BrainrotBaseBatches or {}
local sentBatches = _G.__BrainrotBaseBatches


local function scanSnapshot()
    local entries = collectAllEntries()
    local best = pickBest(entries)
    if not best or not best.base then
        return nil
    end
    local bucket = {}
    for _, it in ipairs(entries) do
        if it.base == best.base and it.value >= THRESHOLD then
            bucket[#bucket+1] = it
        end
    end
    if #bucket == 0 then
        return { bestItem = best, base = best.base, bucket = bucket, topValue = best.value, found = false }
    end
    return { bestItem = best, base = best.base, bucket = bucket, topValue = bucket[1].value or best.value, found = true }
end


local function warmupScanAndMaybeNotify()
    print(string.format("[Scan] warmup iniciado por %.1fs (intervalo %.1fs, threshold >= %s)", SCAN_WARMUP_TIME, SCAN_INTERVAL, formatNum(THRESHOLD)))
    local tEnd = tick() + SCAN_WARMUP_TIME
    local bestSeen
    local iter = 0

    while tick() < tEnd do
        iter += 1
        local t0 = os.clock()
        local snap = scanSnapshot()
        if snap then
            if snap.found then
                print(string.format("[Scan] #%d: base '%s' com %d itens >= threshold (topo: %s %s)",
                    iter, tostring(snap.base.Name), #snap.bucket, tostring(snap.bestItem.name), tostring(snap.bestItem.genText)))
            else
                print(string.format("[Scan] #%d: melhor '%s %s' ~ %s (abaixo do threshold)",
                    iter, tostring(snap.bestItem.name), tostring(snap.bestItem.genText), formatNum(snap.topValue)))
            end
            if not bestSeen or (snap.found and (not bestSeen.found or snap.topValue > bestSeen.topValue)) then
                bestSeen = snap
            end
        else
            print(string.format("[Scan] #%d: nenhum candidato", iter))
        end

        local dt = os.clock() - t0
        local waitFor = math.max(0, SCAN_INTERVAL - dt)
        task.wait(waitFor)
    end

    print("[Scan] Warmup concluído.")
    if bestSeen and bestSeen.found and bestSeen.base and #bestSeen.bucket > 0 then
        local sig = ("%s|%s"):format(tostring(game.JobId), makeSignature(bestSeen.base.Name, bestSeen.bucket))
        if not sentBatches[sig] then
            sentBatches[sig] = true
            print(string.format("[Scan] Resultado final: enviando embed (itens: %d).", #bestSeen.bucket))
            sendReport(bestSeen.bestItem, bestSeen.base, bestSeen.bucket)
        else
            print("[Scan] resultado final: embed já havia sido enviado para esta assinatura, ignorando.")
        end
    else
        print("[Scan] resultado final: nada >= threshold encontrado no período.")
    end
end



local function tryTeleportOnce(jobId)
    local lastFail
    local conn = TeleportService.TeleportInitFailed:Connect(function(player, result, message)
        if player == LocalPlayer then
            lastFail = { result = result, message = tostring(message or "") }
        end
    end)

    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, LocalPlayer)
    end)

    task.wait(0.15)
    conn:Disconnect()

    if not ok then
        return false, "retry"
    end

    if lastFail then
        return false, "retry"
    end

    return true, "started"
end

local function attemptTeleport(jobId)
    local tries = 0
    while TELEPORT_MAX_RETRIES_SAME == 0 or tries < TELEPORT_MAX_RETRIES_SAME do
        tries += 1
        local ok, reason = tryTeleportOnce(jobId)
        if ok then
            print(("[ServerHop] Teleport iniciado para %s"):format(jobId))
            return true
        end
        if reason == "switch" then
            warn(("[ServerHop] servidor cheio/773 em %s -> trocando de job AGORA"):format(jobId))
            return false, "switch"
        end
        warn(("[ServerHop] falha transitória em %s (tentativa %d) -> retry"):format(jobId, tries))
        task.wait(TELEPORT_RETRY_DELAY)
    end
    return false, "retry-limit"
end

warmupScanAndMaybeNotify()


do
    print(("[Burst] consumindo %d job IDs com intervalo de %ds..."):format(BURST_COUNT, BURST_DELAY))
    for i = 1, BURST_COUNT do
        local jobId, err = consumeJob()
        if err then
            warn("[Burst] erro ao consumir job: " .. tostring(err))
        elseif not jobId then
            print("[Burst] fila vazia (204).")
        else
            print(("[Burst] (%d/%d) consumido job: %s -> tentando teleport"):format(i, BURST_COUNT, jobId))
            local ok, why = attemptTeleport(jobId)
            if ok then
                print("[Burst] Teleport iniciado, continuando consumo")
            else
                warn(("[Burst] (%d/%d) falha em %s -> próximo após delay"):format(i, BURST_COUNT, jobId))
            end
        end
        task.wait(BURST_DELAY)
    end
    print("[Burst] Lote concluído. Indo para o loop contínuo.")
end


while true do
    local jobId, err = consumeJob()
    if err then
        warn("[ServerHop] erro " .. tostring(err))
        task.wait(POLL_DELAY_EMPTY)
    elseif not jobId then
        task.wait(POLL_DELAY_EMPTY)
    else
        print("[ServerHop] job consume:", jobId, " -> tentando teleport")
        local ok, why = attemptTeleport(jobId)
        if ok then
            task.wait(BURST_DELAY)
        else
            task.wait(BURST_DELAY)
        end
    end
end
