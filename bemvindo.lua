-- run_remote_panels.lua
-- Executa os dois scripts remotos e copia uma mensagem para o clipboard (se o executor suportar)

local urls = {
    "https://raw.githubusercontent.com/lobinho147/painelstaffsintonia/refs/heads/main/Tags%20menu.lua",
    "https://raw.githubusercontent.com/lobinho147/painelstaffsintonia/refs/heads/main/painel.lua"
}

local msg = "Key do painel tags : permkey789

local function try_notify(title, text)
    -- tenta SendNotification via StarterGui se disponível (roblox)
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        if StarterGui and StarterGui.SetCore then
            StarterGui:SetCore("SendNotification", {
                Title = title or "Script",
                Text = text or "",
                Duration = 5
            })
        end
    end)
end

local function try_set_clipboard(text)
    -- tenta várias formas conhecidas de definir clipboard em executores
    local ok = false
    local handlers = {
        function(t) if setclipboard then setclipboard(t); return true end end,
        function(t) if set_clipboard then set_clipboard(t); return true end end,
        function(t) if syn and syn.set_clipboard then syn.set_clipboard(t); return true end end,
        function(t) if PROT and PROT.SetClipboard then PROT.SetClipboard(t); return true end end,
    }
    for _, h in ipairs(handlers) do
        local s, err = pcall(h, text)
        if s and err ~= false then
            ok = true
            break
        end
    end
    return ok
end

-- Executa cada URL com proteção
for i, url in ipairs(urls) do
    print(string.format("[*] Baixando/executando %d/ %s", i, url))
    local ok, err = pcall(function()
        local body = game:HttpGet(url)
        -- alguns ambientes já retornam função; normalizamos:
        local f
        if type(body) == "function" then
            f = body
        else
            f = loadstring(body)
        end
        if type(f) == "function" then
            f()
        else
            error("loadstring não retornou função")
        end
    end)
    if ok then
        print(string.format("[*] Executado com sucesso: %s", url))
        try_notify("Executado", "OK: " .. url)
    else
        warn(string.format("[!] Falha ao executar %s : %s", url, tostring(err)))
        try_notify("Falha", "Erro: "..tostring(err))
    end
end

-- tenta copiar a mensagem pro clipboard
local copied = try_set_clipboard(msg)
if copied then
    print("[*] Mensagem copiada para o clipboard.")
    try_notify("Clipboard", "Mensagem copiada.")
else
    print("[!] Não foi possível copiar automaticamente. Mensagem abaixo:")
    print("--------------------------------------------------")
    print(msg)
    print("--------------------------------------------------")
    try_notify("Clipboard", "Não foi possível copiar automaticamente. Veja console.")
end

print("[*] run_remote_panels finalizado.")
