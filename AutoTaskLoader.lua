--Caso goste, ou esse script seja útil para você, considere fazer uma doação 
--https://www.paypal.com/donate/?business=8CLQSB8GJZFNE&no_recurring=0&currency_code=BRL

macro(1000, function()
    -- Função para ajustar o nome da criatura
    local function adjustCreatureName(name)
        return name:gsub("^%s*(.-)%s*$", "%1"):gsub("(%a)([%w_']*)", function(first, rest) return first:upper()..rest:lower() end)
    end
    
    -- Função para ler o arquivo JSON
    local function readJson(filePath)
        if g_resources.fileExists(filePath) then
            local status, result = pcall(function()
                return json.decode(g_resources.readFileContents(filePath))
            end)
            if not status then
                error("Erro carregando arquivo (" .. filePath .. "). Para consertar o problema, exclua o arquivo. Detalhes: " .. result)
            end
            return result
        else
            return {}
        end
    end
    
    -- Função para salvar o arquivo JSON
    local function saveJson(filePath, content)
        local status, result = pcall(function()
            return json.encode(content, 2)
        end)
        if not status then
            error("Erro salvando configuração. Detalhes: " .. result)
        end
        if result:len() > 100 * 1024 * 1024 then
            error("Arquivo de configuração acima de 100MB, não será salvo.")
        end
        local success = g_resources.writeFileContents(filePath, result)
        if not success then
            error("Erro ao salvar arquivo JSON em: " .. filePath)
        end
    end
    
    -- Função para registrar a mensagem no log
    local function logTaskMessage(creature)
        if not tasks[creature] then
            tasks[creature] = true
            saveJson(TASK_STORAGE_FILE, tasks)
        end
    end
    
    -- Função para imprimir a última criatura adicionada ao armazenamento (storage)
    local function printLastCreature()
        local lastCreature = nil
        for creature, _ in pairs(tasks) do
            lastCreature = creature
        end
        return lastCreature
    end
    
    -- Diretórios para salvar os dados
    local playerName = g_game.getCharacterName()
    if not playerName then
        error("Não foi possível obter o nome do jogador.")
    end
    
    MAIN_DIRECTORY = "/bot/" .. modules.game_bot.contentsPanel.config:getCurrentOption().text .. "/storage/" .. g_game.getWorldName() .. '/' .. playerName .. "/"
    TASK_STORAGE_FILE = MAIN_DIRECTORY .. 'AutoTask.json'
    
    -- Garantir que o diretório existe
    if not g_resources.directoryExists(MAIN_DIRECTORY) then
        local success = g_resources.makeDir(MAIN_DIRECTORY)
        if not success then
            error("Erro ao criar diretório: " .. MAIN_DIRECTORY)
        end
    end
    
    -- Carregar as tasks salvas
    tasks = readJson(TASK_STORAGE_FILE)
    
    local taskChannelId = nil
    
    onTalk(function(name, level, mode, text, channelId, pos)
        if taskChannelId == nil then
            -- Tentativa de identificação automática do channelId baseado na mensagem de task
            if text:lower():find("você atualmente está na task") then
                taskChannelId = channelId
            end
        end
        if channelId == taskChannelId then
            -- Extrair o nome do monstro da mensagem
            local creature = text:match("você atualmente está na task ([%w%s'-]+)")
            if creature then
                -- Ajusta o nome do monstro
                creature = adjustCreatureName(creature)
                -- Registrar o nome do monstro no log e salvar no arquivo
                logTaskMessage("Task " .. creature) -- Modificação aqui
                -- Imprimir a última criatura adicionada
                local lastCreature = printLastCreature()
                -- Verificar se a última criatura adicionada é igual à criatura identificada no chat
                if lastCreature and lastCreature ~= creature then
                    -- Adicionar ação de av
                end
            end
        end
    end)
    
    -- Função para retornar o último nome de criatura adicionado ao armazenamento
    function getLastCreatureFromStorage()
        local lastCreature = nil
        for creature, _ in pairs(tasks) do
            lastCreature = creature
        end
        return lastCreature
    end
    
    return getLastCreatureFromStorage()
end)
