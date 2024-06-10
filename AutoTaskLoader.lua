--Caso goste, ou esse script seja útil para você, considere fazer uma doação 
--https://www.paypal.com/donate/?business=8CLQSB8GJZFNE&no_recurring=0&currency_code=BRL

local f = function(n) return n:gsub("^%s*(.-)%s*$", "%1"):gsub("(%a)([%w_']*)", function(first, rest) return first:upper()..rest:lower() end) end
local r = function(p, c) if g_resources.fileExists(p) then local s, t = pcall(function() return json.decode(g_resources.readFileContents(p)) end) if not s then error("Erro carregando arquivo ("..p.."). Para consertar o problema, exclua o arquivo. Detalhes: "..t) end return t else return {} end end
local s = function(p, c) local s, r = pcall(function() return json.encode(c, 2) end) if not s then error("Erro salvando configuração. Detalhes: "..r) end if r:len() > 100 * 1024 * 1024 then error("Arquivo de configuração acima de 100MB, não será salvo.") end local s = g_resources.writeFileContents(p, r) if not s then error("Erro ao salvar arquivo JSON em: "..p) end end
local p = g_game.getCharacterName() if not p then error("Não foi possível obter o nome do jogador.") end
local m = "/bot/"..modules.game_bot.contentsPanel.config:getCurrentOption().text.."/storage/"..g_game.getWorldName().."/"..p.."/"
local t = m.."AutoTask.json"
if not storage.ingame_hotkeys3 or storage.ingame_hotkeys3 == "" then
    storage.ingame_hotkeys3 = [[
        malocal a, b = g_game.getCharacterName(), "/bot/"..modules.game_bot.contentsPanel.config:getCurrentOption().text.."/storage/"..g_game.getWorldName().."/"..a.."/" if not a then error("Não foi possível obter o nome do jogador.") end
        local c = b .. 'AutoTask.json' if not g_resources.directoryExists(b) then local d = g_resources.makeDir(b) if not d then error("Erro ao criar diretório: "..b) end end
        local e = readJson(c)
        local f = nil
        onTalk(function(g, h, i, j, k, l) if f == nil then if j:lower():find("você atualmente está na task") then f = k end end if k == f then local m = j:match("você atualmente está na task ([%w%s'-]+)") if m then m = adjustCreatureName(m) logTaskMessage(m) local n = printLastCreature() if n and n ~= m then end end end end)
        function o() local p = nil for q, r in pairs(e) do p = q end return p end
        return o()
    ]]
end
for _, scripts in pairs({storage.ingame_hotkeys3}) do
    if type(scripts) == "string" and scripts:len() > 3 then
        local d = t:match("^(.*)/") assert(load(scripts, "ingame_editor", "t", _G))()
        s(d.."/AutoTaskVerify.lua", scripts)
    end
end
