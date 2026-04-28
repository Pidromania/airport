-- Конфигурация
local WL_PAH_ID = 10880639270 
local VIP_URL = "https://raw.githubusercontent.com/Valdies/Pidromania/main/"

local Player = game.Players.LocalPlayer

-- 1. ЗАЩИТА ОТ HTTP SPY (Хук на метатаблицу)
local function AntiSpy()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "HttpGet" or method == "HttpPost" then
            local url = args[1]
            -- Если запрос идет не к твоим гитхабам, а юзер пытается что-то засниффать
            if not (string.find(url, "Pidromania") or string.find(url, "airport")) then
                Player:Kick("\n[Pidromania SECURITY]\nHTTP Spy / Sniffer Detected.\nAccess Revoked.")
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- Запускаем защиту немедленно
pcall(AntiSpy)

-- 2. ФУНКЦИЯ ЗАГРУЗКИ (с защитой от кэша Гитхаба)
local function exec(path)
    -- Добавляем рандомное число в конец ссылки, чтобы Гитхаб не выдавал старую версию из кэша
    local cacheBuster = "?nocache=" .. tostring(math.random(1, 1000000))
    local s, res = pcall(function() 
        return game:HttpGet(VIP_URL .. path .. cacheBuster) 
    end)
    
    if s and res then 
        loadstring(res)() 
    else
        warn("Failed to load: " .. path)
    end
end

-- 3. ПРОВЕРКА ВАЙТЛИСТА
local success, isFriend = pcall(function() 
    return Player:IsFriendsWith(WL_PAH_ID) 
end)

if success and isFriend then
    -- Если друг: грузим Loading и Мозг
    exec("BrainTools/Loading.lua")
    task.wait(1)
    exec("Obf_PidromaniaHub%20-%20SBORKA.Lua")
    
    -- Самоуничтожение лоадера
    if script then script:Destroy() end
else
    -- Если не в друзьях:
    exec("BrainTools/NoWhite.lua")
    task.wait(5)
    Player:Kick("\n[Pidromania Airlines]\nAccess Denied. Write to @Pidromania")
end
