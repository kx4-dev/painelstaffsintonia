
local arquivos = {"Tags menu", "painel"}

local msg = "Key do painel tags : permkey789 letra pequena(n vai copia) : modificado por kx4_dev e sua equipa tiki menu"

-- Função para executar arquivos com proteção
local function safe_dofile(filename)
    local ok, err = pcall(dofile, filename)
    if ok then
        print("[*] Executado:", filename)
    else
        print("[!] Erro ao executar", filename, ":", err)
    end
end

-- Executa cada arquivo
for _, arquivo in ipairs(arquivos) do
    safe_dofile(arquivo)
end

-- Função para tentar copiar a mensagem para o clipboard
local function try_pipe_command(cmd, text)
    local pipe = io.popen(cmd, "w")
    if not pipe then return false end
    local ok = pcall(function() pipe:write(text) end)
    pipe:close()
    return ok
end

local function copy_to_clipboard(text)
    local sep = package.config:sub(1,1)
    if sep ~= "\\" then
        if try_pipe_command("termux-clipboard-set", text) then return true end
        if try_pipe_command("xclip -selection clipboard", text) then return true end
        if try_pipe_command("xsel --clipboard --input", text) then return true end
        if try_pipe_command("pbcopy", text) then return true end
    else
        if try_pipe_command("clip", text) then return true end
    end
    return false
end

-- Copia mensagem
if copy_to_clipboard(msg) then
    print("[*] Mensagem copiada para a área de transferência.")
else
    print("[!] Não foi possível copiar automaticamente. Copie manualmente a mensagem:")
    print(msg)
end

print("[*] run_both.lua finalizado.")
