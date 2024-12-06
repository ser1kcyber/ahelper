local inicfg = require 'inicfg'
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local sampev = require('lib.samp.events')

local currentVersion = "1.0.1"
local versionURL = "https://raw.githubusercontent.com/ser1kcyber/ahelper/refs/heads/main/version.ini"
local scriptURL = "https://github.com/ser1kcyber/ahelper/raw/refs/heads/main/Ahelper.luac"
local scriptName = "Ahelper.luac"

local gun_list = {[0] = 'Рука', [1] = 'Brass Knuckles',  [2] = 'Golf Club',	[3] = 'Nightstick',	[4] = 'Knife', [5] = 'Baseball Bat	',	[6] = 'Shovel',	[7] = 'Pool Cue',	[8] = 'Katana',	[9] = 'Chainsaw',	[10] = 'Purple Dildo',	[11] = 'Dildo',	[12] = 'Vibrator',	[13] = 'Silver Vibrator',	[14] = 'Flowers',	[15] = 'Cane',	[16] = 'Grenade',	[17] = 'Tear Gas',	[18] = 'Molotov Cocktail',	[19] = '##',	[20] = '##',	[21] = '##',	[22] = 'Pistol',	[23] = 'Silent Pistol',	[24] = 'Desert Eagle',	[25] = 'Shotgun',	[26] = 'Sawnoff Shotgun',	[27] = 'Combat Shotgun',	[28] = 'Micro SMG/Uzi',	[29] = 'MP5',	[30] = 'AK-47',	[31] = 'M4',	[32] = 'Tec-9',	[33] = 'Contry Riffle',	[34] = 'Sniper Riffle',	[35] = 'RPG',	[36] = 'HS Rocket',	[37] = 'Flame Thrower',	[38] = 'Minigun',	[39] = 'Satchel charge',	[40] = 'Detonator',	[41] = 'Spraycan',	[42] = 'Fire Extiguisher',	[43] = 'Camera',	[44] = 'Nigh Vision Goggles',	[45] = 'Thermal Goggles',	[46] = 'Parachute'}


local iniFileName = 'AH.ini'
local iniFilePath = 'moonloader/config/' .. iniFileName
local config = inicfg.load(inicfg.load({
    main = {
        ignor_nick_clr = false,
        ignor_display = false,
        only_before_15m = false,
        logger_otvod = false,
        otvod_only_plr = false,
        logger_dmcar = false,
        only_with_driver = false,
        logger_iz_teri = false,
        iz_only_in_p = false,
        logger_vne_teri = false,
        vne_only_in_p = false,
        logger_50k = false,
        logger_exit_ft = false,
        window_size = 1,
        logger_chat_check = false,
        logger_spam = false,
    },
    notify = {
        notify_dmcar = false,
        notify_otvod = false,
        notify_chat_check = false,
        notify_spam = false,
    },
}, iniFileName))

if not doesFileExist(iniFilePath) then inicfg.save(config, iniFileName) end

bullet_logs = {}
logs = {}
spam_list = {}

window_main = imgui.ImBool(false)
selected_menu = 1
nast_m = 1 
find_buffer = imgui.ImBuffer(100)
find_type_list = {[0] = u8'Ник/Id', [1] = u8'Нарушение', [2] = u8'Время', [3] = u8'Детали'}
find_type = imgui.ImInt(0)

window_size = tonumber(config.main.window_size)

ignor_nick_clr = imgui.ImBool(config.main.ignor_nick_clr)
ignor_display = imgui.ImBool(config.main.ignor_display)
only_before_15m = imgui.ImBool(config.main.only_before_15m)
logger_otvod = imgui.ImBool(config.main.logger_otvod)
otvod_only_plr = imgui.ImBool(config.main.otvod_only_plr)
logger_dmcar = imgui.ImBool(config.main.logger_dmcar)
only_with_driver = imgui.ImBool(config.main.only_with_driver)
logger_iz_teri = imgui.ImBool(config.main.logger_iz_teri)
iz_only_in_p = imgui.ImBool(config.main.iz_only_in_p)
logger_vne_teri = imgui.ImBool(config.main.logger_vne_teri)
vne_only_in_p = imgui.ImBool(config.main.vne_only_in_p)
logger_50k = imgui.ImBool(config.main.logger_50k)
logger_exit_ft = imgui.ImBool(config.main.logger_exit_ft)
logger_chat_check = imgui.ImBool(config.main.logger_chat_check)
logger_spam = imgui.ImBool(config.main.logger_spam)

notify_dmcar = imgui.ImBool(config.notify.notify_dmcar)
notify_otvod = imgui.ImBool(config.notify.notify_otvod)
notify_chat_check = imgui.ImBool(config.notify.notify_chat_check)
notify_spam = imgui.ImBool(config.notify.notify_spam)


function parseIni(filePath)
    local iniFile = io.open(filePath, "r")
    if not iniFile then
        print("Не удалось открыть INI файл. Путь: " .. filePath)
        return nil
    end

    local iniData = {}
    for line in iniFile:lines() do
        -- Убираем лишние пробелы и игнорируем пустые строки и комментарии
        line = line:match("^%s*(.-)%s*$")
        if line == "" or line:sub(1, 1) == ";" then
            -- Игнорируем пустые строки и комментарии
        else
            -- Ищем строки вида key = value
            local key, value = line:match("([^=]+)=%s*(.*)")
            if key and value then
                iniData[key:match("^%s*(.-)%s*$")] = value:match("^%s*(.-)%s*$")
            end
        end
    end
    iniFile:close()
    return iniData
end

function main()
    -- Ожидаем, пока SAMP не будет доступен
    while not isSampAvailable() do wait(200) end

    -- Начинаем проверку на обновление
    sampAddChatMessage("[{FFA500}A.Helper{ffffff}] Начинаю проверку на обновление!", -1)
    local updateAvailable, newScriptData = checkForUpdate()
    if updateAvailable then
        sampAddChatMessage("[{FFA500}A.Helper{ffffff}] Обновление найдено! Начинаю обновление...", -1)
        if updateScript(newScriptData) then
            sampAddChatMessage("[{FFA500}A.Helper{ffffff}] Скрипт успешно обновлен! Перезагрузка...", -1)
            reloadScript()
            return -- Скрипт перезагрузится
        else
            sampAddChatMessage("[{FFA500}A.Helper{ffffff}] Ошибка при обновлении скрипта!", -1)
        end
    else
        sampAddChatMessage("[{FFA500}A.Helper{ffffff}] Скрипт уже последней версии (" .. currentVersion .. ").", -1)
    end

    -- Основной функционал скрипта
    imgui.Process = false
    sampRegisterChatCommand('ah', function() window_main.v = not window_main.v end)
    wait(808)
    sampAddChatMessage('[{FFA500}A.Helper{ffffff}] Скрипт загружен! Открыть меню - /ah', -1)
    wait(0)
    sampAddChatMessage('[{FFA500}A.Helper{ffffff}] Автор - Ser1k.', -1)
    wait(0)
    sampAddChatMessage('[{FFA500}A.Helper{ffffff}] Скрипт находится в стадии тестирования - 2.', -1)

    -- Главный цикл
    while true do
        wait(0)
        if window_main.v or isnotifyact then
            imgui.Process = true
            if window_main.v then
                imgui.ShowCursor = true
            else
                imgui.ShowCursor = false
            end
        else
            imgui.Process = false
        end
        local p1x, p1y = convert3DCoordsToScreen(x1, y1, z1)
        local p2x, p2y = convert3DCoordsToScreen(x2, y2, z2)
        renderDrawLine(p1x, p1y, p2x, p2y, 2, -1)
    end
end

function checkForUpdate()
    local tempFilePath = getWorkingDirectory() .. "\\version.ini"

    -- Логирование пути
    print("Путь к файлу версии: " .. tempFilePath)

    local success, status = downloadUrlToFile(versionURL, tempFilePath)

    if success then
        print("Загрузка файла версии успешна. Статус: " .. (status or "неизвестно"))
    else
        print("Ошибка загрузки файла версии. Код: " .. (status or "неизвестно"))
        return false, nil
    end

    -- Проверка существования файла
    local file = io.open(tempFilePath, "r")
    if not file then
        print("Не удалось открыть файл версии для чтения. Путь: " .. tempFilePath)
        return false, nil
    end
    file:close()

    -- Парсим INI файл
    local iniData = parseIni(tempFilePath)
    if not iniData then
        print("Не удалось прочитать INI файл.")
        return false, nil
    end

    -- Получаем версию из INI
    local serverVersion = iniData["version"]
    if not serverVersion then
        print("Не удалось найти версию в INI файле.")
        return false, nil
    end

    print("Локальная версия: " .. currentVersion)
    print("Серверная версия: " .. serverVersion)

    -- Сравнение версий
    if serverVersion ~= currentVersion then
        -- Загружаем новый скрипт
        local newScriptData, status = downloadUrlToFile(scriptURL)
        if status == 200 then
            return true, newScriptData
        else
            print("Ошибка загрузки нового скрипта. Код: " .. status)
        end
    else
        print("Версия не изменилась.")
    end

    return false, nil
end

function updateScript(newScriptData)
    local file = io.open(getWorkingDirectory() .. "\\" .. scriptName, "wb")
    if file then
        file:write(newScriptData)
        file:close()
        return true
    end
    return false
end

function reloadScript()
    thisScript():unload()
    thisScript():load()
end

function imgui.OnDrawFrame()
    if window_main.v then
        theme()
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 500, 355 
        if selected_menu == 1 then
            if resY > (sizeY*window_size+1) then
                sizeY = sizeY * window_size
            else
                sizeY = resY
            end
        end
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sizeX / 2, resY / 2 - sizeY / 2))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
        imgui.Begin(u8'Детект нарушений', window_main, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
        local text = u8'Детект нарушений'
        imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
        --colors = imgui.ImVec4(1.00, 0.65, 0.00, 0.78)
        imgui.Text(text)
        imgui.SameLine()
        imgui.SetCursorPosX(imgui.GetWindowSize().x - 30)
        if imgui.Button('X##closemenu', imgui.ImVec2(20, 20)) then
            window_main.v = false
        end
        imgui.Separator()
        if imgui.Button(u8'Логи', imgui.ImVec2(237.5, 20)) then
            selected_menu = 1
        end
        imgui.SameLine()
        if imgui.Button(u8'Настройки', imgui.ImVec2(237.5, 20)) then
            selected_menu = 2 
        end
        imgui.Separator()
        if selected_menu == 1 then
            imgui.PushItemWidth(90)
            imgui.Combo('##findcombo', find_type, find_type_list)
            imgui.Hint(u8'Выбор столбца по которому будет вестись поиск')
            imgui.SameLine()
            if imgui.Button('Clear', imgui.ImVec2(50, 20)) then
                find_buffer.v = ''
            end
            imgui.Hint(u8'Очистить строку поиска')
            imgui.SameLine() imgui.PushItemWidth(285)
            imgui.InputText(u8'Поиск', find_buffer) 
            imgui.PopItemWidth()
            imgui.Separator()
            imgui.SetCursorPosX(10) imgui.Text(u8'Nick_Name[ID]') imgui.Hint(u8'Никнейм нарушителя и его ID в момент нарушения') imgui.SameLine()
            imgui.SetCursorPosX(150) imgui.Text(u8'Нарушение '..#logs) imgui.Hint(u8'Информация о нарушении и общее кол-во нарушений') imgui.SameLine()
            imgui.SetCursorPosX(290) imgui.Text(u8'Время') imgui.Hint(u8'Время нарушения\nУказывается время относительно времени на ПК') imgui.SameLine()
            imgui.SetCursorPosX(350) imgui.Text(u8'Пинг') imgui.Hint(u8'Пинг в момент нарушения') imgui.SameLine()
            imgui.SetCursorPosX(400) imgui.Text(u8'Подробнее') imgui.Hint(u8'Более детальная информация о нарушении')
            imgui.Separator()
            if logs ~= nil and #logs ~= 0 then
                local style = imgui.GetStyle()
                local colors = style.Colors
                local clr = imgui.Col
                local ImVec4 = imgui.ImVec4
                colors[clr.Separator] = imgui.ImVec4(1.00, 0.65, 0.00, 0.78)
                imgui.SetCursorPosX(0)
                imgui.BeginChild('logschild', imgui.ImVec2(imgui.GetWindowWidth(), imgui.GetWindowHeight()-170), false)
                if find_buffer.v == '' then
                    for i = 1, #logs do
                        if logs[i] then
                            imgui.SetCursorPosX(10) imgui.Text(logs[i].nick..'['..logs[i].id..']') imgui.SameLine()
                            imgui.SetCursorPosX(150) imgui.Text(u8:encode(logs[i].detect)) imgui.SameLine()
                            imgui.SetCursorPosX(290) imgui.Text(logs[i].time) imgui.SameLine()
                            imgui.SetCursorPosX(350) imgui.Text(tostring(logs[i].ping)) imgui.SameLine()
                            imgui.SetCursorPosX(400) imgui.Text(u8'Детали') imgui.Hint(u8:encode(logs[i].hint), 0) imgui.SameLine()
                            imgui.SetCursorPosX(460) if imgui.Button('*##'..i, imgui.ImVec2(19, 15)) then table.remove(logs, i) end imgui.Hint(u8'Удалить')
                            imgui.Separator()
                        end
                    end
                else
                    if find_type.v == 0 then
                        for i = 1, #logs do
                            if logs[i] and string.find(toLower(logs[i].nick):lower(),toLower(find_buffer.v):lower()) then
                                imgui.SetCursorPosX(10) imgui.Text(logs[i].nick..'['..logs[i].id..']') imgui.SameLine()
                                imgui.SetCursorPosX(150) imgui.Text(u8:encode(logs[i].detect)) imgui.SameLine()
                                imgui.SetCursorPosX(290) imgui.Text(logs[i].time) imgui.SameLine()
                                imgui.SetCursorPosX(350) imgui.Text(tostring(logs[i].ping)) imgui.SameLine()
                                imgui.SetCursorPosX(400) imgui.Text(u8'Детали') imgui.Hint(u8:encode(logs[i].hint), 0) imgui.SameLine()
                                imgui.SetCursorPosX(460) if imgui.Button('*##'..i, imgui.ImVec2(19, 15)) then table.remove(logs, i) end imgui.Hint(u8'Удалить')
                                imgui.Separator()
                            end
                        end
                    elseif find_type.v == 1 then
                        for i = 1, #logs do
                            if logs[i] and string.find(toLower(logs[i].detect):lower(),toLower(u8:decode(find_buffer.v)):lower()) then
                                imgui.SetCursorPosX(10) imgui.Text(logs[i].nick..'['..logs[i].id..']') imgui.SameLine()
                                imgui.SetCursorPosX(150) imgui.Text(u8:encode(logs[i].detect)) imgui.SameLine()
                                imgui.SetCursorPosX(290) imgui.Text(logs[i].time) imgui.SameLine()
                                imgui.SetCursorPosX(350) imgui.Text(tostring(logs[i].ping)) imgui.SameLine()
                                imgui.SetCursorPosX(400) imgui.Text(u8'Детали') imgui.Hint(u8:encode(logs[i].hint), 0) imgui.SameLine()
                                imgui.SetCursorPosX(460) if imgui.Button('*##'..i, imgui.ImVec2(19, 15)) then table.remove(logs, i) end imgui.Hint(u8'Удалить')
                                imgui.Separator()
                            end
                        end
                    elseif find_type.v == 2 then
                        for i = 1, #logs do
                            if logs[i] and string.find(toLower(logs[i].time):lower(),toLower(find_buffer.v):lower()) then
                                imgui.SetCursorPosX(10) imgui.Text(logs[i].nick..'['..logs[i].id..']') imgui.SameLine()
                                imgui.SetCursorPosX(150) imgui.Text(u8:encode(logs[i].detect)) imgui.SameLine()
                                imgui.SetCursorPosX(290) imgui.Text(logs[i].time) imgui.SameLine()
                                imgui.SetCursorPosX(350) imgui.Text(tostring(logs[i].ping)) imgui.SameLine()
                                imgui.SetCursorPosX(400) imgui.Text(u8'Детали') imgui.Hint(u8:encode(logs[i].hint), 0) imgui.SameLine()
                                imgui.SetCursorPosX(460) if imgui.Button('*##'..i, imgui.ImVec2(19, 15)) then table.remove(logs, i) end imgui.Hint(u8'Удалить')
                                imgui.Separator()
                            end
                        end
                    elseif find_type.v == 3 then
                        for i = 1, #logs do
                            if logs[i] and string.find(toLower(logs[i].hint):lower(),toLower(find_buffer.v):lower()) then
                                imgui.SetCursorPosX(10) imgui.Text(logs[i].nick..'['..logs[i].id..']') imgui.SameLine()
                                imgui.SetCursorPosX(150) imgui.Text(u8:encode(logs[i].detect)) imgui.SameLine()
                                imgui.SetCursorPosX(290) imgui.Text(logs[i].time) imgui.SameLine()
                                imgui.SetCursorPosX(350) imgui.Text(tostring(logs[i].ping)) imgui.SameLine()
                                imgui.SetCursorPosX(400) imgui.Text(u8'Детали') imgui.Hint(u8:encode(logs[i].hint), 0) imgui.SameLine()
                                imgui.SetCursorPosX(460) if imgui.Button('*##'..i, imgui.ImVec2(19, 15)) then table.remove(logs, i) end imgui.Hint(u8'Удалить')
                                imgui.Separator()
                            end
                        end
                    end
                end
                imgui.EndChild()
                colors[clr.Separator] = imgui.ImVec4(1.00, 0.65, 0.00, 0.50)
            else
                imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(u8'Лог пуст :)').x / 2)
                imgui.SetCursorPosY(imgui.GetWindowSize().y / 2 - imgui.CalcTextSize(u8'Лог пуст :)').y / 2)
                imgui.Text(u8'Лог пуст :)')
            end
            imgui.SetCursorPosY(imgui.GetWindowSize().y - 50)
            if imgui.Button(u8'Очистить лог', imgui.ImVec2(237.5, 20)) then
                logs = {}
            end
            imgui.SameLine()
            if imgui.Button(u8'Очистить кеш', imgui.ImVec2(237.5, 20)) then
                bullet_logs = {}
            end
        elseif selected_menu == 2 then
            local style = imgui.GetStyle()
            local colors = style.Colors
            local clr = imgui.Col
            local ImVec4 = imgui.ImVec4
            colors[clr.Separator] = imgui.ImVec4(1.00, 0.65, 0.00, 0.78)
            imgui.BeginChild('childmenu2', imgui.ImVec2(imgui.GetWindowWidth(), imgui.GetWindowHeight()-120), false)
            if nast_m == 1 then
                imgui.SeparatorWithText(u8'Настройка записи в лог', 10, imgui.ImVec4(1.00, 0.65, 0.00, 0.78))
                imgui.WCheckbox(u8'Игнорировать игроков с вашим цветом ника', ignor_nick_clr)
                imgui.WCheckbox(u8'Игнорировать игроков вне экрана', ignor_display)
                imgui.WCheckbox(u8'Логировать до 15 минут', only_before_15m)
            end
            if nast_m == 2 then
                imgui.SeparatorWithText(u8'Выбор логируемых нарушений', 10, imgui.ImVec4(1.00, 0.65, 0.00, 0.78))

                imgui.WCheckbox(u8'Сбив темпа стрельбы', logger_otvod)
                imgui.SameLine() imgui.SetCursorPosX(250)
                imgui.WCheckbox(u8'Только в человека ', otvod_only_plr)
                imgui.Hint(u8'Будет записывать только выстрелы в людей')
                imgui.SameLine() imgui.SetCursorPosX(400)
                imgui.WCheckbox(u8'Увед##otvod', notify_otvod)
                imgui.Hint(u8'Отдельное уведомление справа снизу.')

                imgui.WCheckbox(u8'Выстрелы в машину', logger_dmcar)
                imgui.SameLine() imgui.SetCursorPosX(250)
                imgui.WCheckbox(u8'Только с водителем', only_with_driver)
                imgui.Hint(u8'Будет записывать только выстрелы по машинам с водителем')
                imgui.SameLine() imgui.SetCursorPosX(400)
                imgui.WCheckbox(u8'Увед##dmcar', notify_dmcar)
                imgui.Hint(u8'Отдельное уведомление справа снизу.')

                imgui.WCheckbox(u8'Стрельба из теры по людям вне теры', logger_iz_teri)
                imgui.Hint(u8'Только стройка', 0, true)
                imgui.SameLine() imgui.SetCursorPosX(330)
                imgui.WCheckbox(u8'Только в человека##iz', iz_only_in_p)
                imgui.Hint(u8'Будет записывать только выстрелы в людей')

                imgui.WCheckbox(u8'Стрельба вне теры по людем в тере', logger_vne_teri)
                imgui.Hint(u8'Только стройка', 0, true)
                imgui.SameLine() imgui.SetCursorPosX(330)
                imgui.WCheckbox(u8'Только в человека##vne', vne_only_in_p)
                imgui.Hint(u8'Будет записывать только выстрелы в людей')

                imgui.WCheckbox(u8'Выход с теры', logger_exit_ft)
                imgui.SeparatorWithText(u8'Выбор логируемых нарушений ЧАТА', 10, imgui.ImVec4(1.00, 0.65, 0.00, 0.78))
                imgui.WCheckbox(u8'Проверка чата (оск, упом)', logger_chat_check)
                imgui.Hint(u8'Проверяет НРП и РП чаты на оскорбления, упоминания родни.')
                imgui.SameLine() imgui.SetCursorPosX(400)
                imgui.WCheckbox(u8'Увед##chatc', notify_chat_check)
                imgui.Hint(u8'Уведомление ниже под сообщением в чат.')

                imgui.WCheckbox(u8'Проверка чата (спам)', logger_spam)
                imgui.Hint(u8'Проверяет НРП и РП чаты на спам.')
                imgui.SameLine() imgui.SetCursorPosX(400)
                imgui.WCheckbox(u8'Увед##chatsp', notify_spam)
                imgui.Hint(u8'Отдельное уведомление справа снизу.')
            end

            if nast_m == 3 then
                imgui.SeparatorWithText(u8'Выбор логируемых читов', 10, imgui.ImVec4(1.00, 0.65, 0.00, 0.78))
                imgui.WCheckbox(u8'50k HP Car', logger_50k)
            end
            imgui.EndChild()
            if nast_m == 1 then
                imgui.SetCursorPosX(440)
                imgui.SetCursorPosY(imgui.GetWindowSize().y - 50)
                if imgui.Button(u8'>>>', imgui.ImVec2(50, 20)) then
                    nast_m = 2
                end
            end
            if nast_m == 2 then
                imgui.SetCursorPosY(imgui.GetWindowSize().y - 50)
                if imgui.Button(u8'<<<', imgui.ImVec2(50, 20)) then
                    nast_m = 1
                end
                --[[imgui.SetCursorPosX(440)
                imgui.SetCursorPosY(imgui.GetWindowSize().y - 50)
                if imgui.Button(u8'>>>', imgui.ImVec2(50, 20)) then
                    nast_m = 3
                end]]
            end
            if nast_m == 3 then
                imgui.SetCursorPosY(imgui.GetWindowSize().y - 50)
                if imgui.Button(u8'<<<', imgui.ImVec2(50, 20)) then
                    nast_m = 2
                end
            end
        end

        imgui.SetCursorPosY(imgui.GetWindowSize().y - 25)
        imgui.Separator()
        imgui.Text(u8'Некоторые функции могут работать не корректно')
        if selected_menu == 1 then
            imgui.SameLine()
            imgui.SetCursorPosX(415)
            if imgui.Button(u8'1', imgui.ImVec2(20, 18)) then
                window_size = 1
                savecfg()
            end
            imgui.SameLine()
            if imgui.Button(u8'2', imgui.ImVec2(20, 18)) then
                window_size = 2
                savecfg()
            end
            imgui.SameLine()
            if imgui.Button(u8'3', imgui.ImVec2(20, 18)) then
                window_size = 3
                savecfg()
            end
        end
        imgui.End()
    end
    onRenderNotification()
end

function sampev.onVehicleStreamIn(vehId, data)
    if logger_50k.v and data.health > 1000 then
        local res, cr_hand = sampGetCarHandleBySampVehicleId(data.targetId)
        if res then
            local driver = getDriverOfCar(cr_hand)
            local result, plid = sampGetPlayerIdByCharHandle(driver)
            if result and check_igr_nick(plid) and check_igr_disp(plid) and checktime() then
                local nick = sampGetPlayerNickname(plid)
                local stime = os.date("*t")
                local driv = sampGetPlayerNickname(plid)
                table.insert(logs, {nick = nick, id = plid, detect = '50k HP Car', hint = driv..' находился в машине ID '..vehId..' у которой '..data.health..' хп', time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
            end
        end
    end
end

function sampev.onBulletSync(playerId, data)
    if checktime() and check_igr_nick(playerId) and check_igr_disp(playerId) and check_only_in_plr(data.targetType) then
        local nick = sampGetPlayerNickname(playerId):lower()
        local intable = false
        if data.weaponId == 24 then
            if logger_otvod.v then
                for i = 1, #bullet_logs do
                    if bullet_logs[i] then
                        if nick == bullet_logs[i].nick then
                            local time = os.clock()
                            local stime = os.date("*t")
                            local cel = 'воздух'
                            if data.targetType == 2 then cel = 'машину с ID '..data.targetId end
                            if data.targetType == 1 then cel = sampGetPlayerNickname(data.targetId) end
                            if time - bullet_logs[i].lasttime < 0.6 and time - bullet_logs[i].lasttime > 0.01 then
                                table.insert(logs, {nick = nick, id = playerId, detect = 'Сбив темпа стрельбы', hint = 'Совершил выстрел с промежутком '..round(time - bullet_logs[i].lasttime, -3)..'c. от прошлого выстрела. Попал в '..cel, time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
                                if notify_otvod.v then
                                    local finded = false
                                    for i=1, #message do
                                        if message[i].nick == nick and message[i].ntype == 1 then
                                            finded = true
                                            message[i].otvod_x = message[i].otvod_x + 1
                                        end
                                    end
                                    if not finded then imgui.ShowNotify('['..playerId..'] \nсбил темп стрельбы x', nick, 1, 1) end
                                end
                            end
                            bullet_logs[i].lasttime = time
                        end
                    end
                end
                if not intable then
                    table.insert(bullet_logs, {nick = nick, lasttime = os.clock()})
                end
            end
        end
        if logger_dmcar.v and data.targetType == 2 then
            local stime = os.date("*t")
            local gun = gun_list[data.weaponId]
            local res, cr_hand = sampGetCarHandleBySampVehicleId(data.targetId)
            if res then
                local driver = getDriverOfCar(cr_hand)
                local result, plid = sampGetPlayerIdByCharHandle(driver)
                local driv = 'без водителя'
                local notifyMsg
                if result then
                    driv = 'с водителем: '..sampGetPlayerNickname(plid)
                    notifyMsg = '['..playerId..'] \nвыстрелил в машину\n'..driv..' x'
                elseif not only_with_driver.v then
                    notifyMsg = '['..playerId..'] \nвыстрелил в машину\n'..driv..' x'
                end
                if notifyMsg then
                    table.insert(logs, {nick = nick, id = playerId, detect = 'Возможный DM Car', hint = 'Выстрелил из '..gun..' в машину с ID '..data.targetId..' '..driv, time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
                    if notify_dmcar.v then
                        local finded = false
                        for i=1, #message do
                            local msg = message[i]
                            if msg.nick == nick and msg.ntype == 2 then
                                finded = true
                                msg.otvod_x = (msg.otvod_x or 0) + 1
                                break 
                            end
                        end
                        if not finded then imgui.ShowNotify(notifyMsg, nick, 2, 1) end
                    end
                end
            end
        end
        if logger_iz_teri.v then
            if isPointInZone(data.origin.x, data.origin.y, 715.345, -1732.483, 571.904, -1642.706) then
                if not isPointInZone(data.target.x, data.target.y, 715.345, -1732.483, 571.904, -1642.706) then
                    local stime = os.date("*t")
                    local gun = gun_list[data.weaponId]
                    local popad = ' в воздух'
                    if data.targetType == 1 then
                        local popad = ' в человека: '..sampGetPlayerNickname(data.targetId)
                        table.insert(logs, {nick = nick, id = playerId, detect = 'Стрельба из теры', hint = 'Выстрелил из '..gun..popad, time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
                        imgui.ShowNotify('['..playerId..'] стрельба из БВ теры в человека', nick, 3, nil)
                    else
                        if not iz_only_in_p.v then
                            table.insert(logs, {nick = nick, id = playerId, detect = 'Стрельба из теры', hint = 'Выстрелил из '..gun..popad, time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
                            imgui.ShowNotify('['..playerId..'] стрельба из БВ теры в воздух', nick, 3, nil)
                        end
                    end
                end
            end
        end
        if logger_vne_teri.v then
            if not isPointInZone(data.origin.x, data.origin.y, 715.345, -1732.483, 571.904, -1642.706) then
                if isPointInZone(data.target.x, data.target.y, 715.345, -1732.483, 571.904, -1642.706) then
                    local stime = os.date("*t")
                    local gun = gun_list[data.weaponId]
                    local popad = ' в воздух'
                    if data.targetType == 1 then
                        local popad = ' в человека: '..sampGetPlayerNickname(data.targetId)
                        table.insert(logs, {nick = nick, id = playerId, detect = 'Стрельба вне теры', hint = 'Выстрелил из '..gun..popad, time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
                        imgui.ShowNotify('['..playerId..'] стрельба за БВ терой в человека', nick, 4, nil)
                    else
                        if not iz_only_in_p.v then
                            table.insert(logs, {nick = nick, id = playerId, detect = 'Стрельба вне теры', hint = 'Выстрелил из '..gun..popad, time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
                            imgui.ShowNotify('['..playerId..'] стрельба за БВ терой в воздух', nick, 4, nil)
                        end
                    end
                end
            end
        end
    end
end

function sampev.onPlayerSync(playerId, data)
    if logger_exit_ft.v then
        if checktime() and check_igr_nick(playerId) and check_igr_disp(playerId) then
            local res, ped = sampGetCharHandleBySampPlayerId(playerId)
            if res then
                local x, y, z = getCharCoordinates(ped)
                if isPointInZone(x, y, 715.345, -1732.483, 571.904, -1642.706) and not isPointInZone(data.position.x, data.position.y, 715.345, -1732.483, 571.904, -1642.706) then
                    local nick = sampGetPlayerNickname(playerId)
                    local stime = os.date("*t")
                    table.insert(logs, {nick = nick, id = playerId, detect = 'Выход с теры', hint = 'Переместился в '..data.position.x..' '..data.position.y..' '..data.position.z, time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
                end
            end
        end
    end
end

local insults = {
    "идиот", "дурак", "кретин", "придурок", "тупица", "болван", "безмозглый", "дебил", "имбецил", "недоумок",
    "урод", "выродок", "мразь", "сволочь", "гад", "подлец", "ничтожество", "отброс",
    "мерзавец", "неудачник", "лузер", "лох", "чмо", "терпила", "даун", "олух", "придурок",
    "тупица", "идиотка", "дура", "кретинка", "мразь", "сволочь", "гадина", "подлюка", "дрянь",
    "шлюха", "проститутка", "блядь", "ублюдок", "выблядок", "гнида", "скотина", "тварь",
    "дегенерат", "импотент", "фригидная", "бездарь", "трус", "слабак", "быдло", "убожество", "недочеловек",
    "узколобый", "ускоглазый", "глупый", "уебан", "пидор", "пидорас", "жиробас", "шалава"
}



function containsInsult(text)
    local textLower =  toLower(text)
    for _, insult in ipairs(insults) do
        if string.find(textLower, insult) then
            return true, insult
        end
    end
    return false, nil
end

local mentions = {
    "мам", "мать", "mom", "пап", "батя"
}

function containsMention(text)
    local textLower =  toLower(text)
    for _, mention in ipairs(mentions) do
        if string.find(textLower, mention) then
            return true, mention
        end
    end
    return false, nil
end

function sampev.onServerMessage(color, text)
    if logger_chat_check.v then
        if color == -169694806 then
            local res, insult = containsInsult(text)
            if res then 
                sampAddChatMessage(text, color)
                if notify_chat_check.v then
                    sampAddChatMessage('[A.Helper] Внимание! В сообщении выше содержится слово: '..insult, 16711729)
                end
                local stime = os.date("*t")
                local id = string.match(text, "%[(%d+)%]")
                if id then 
                    local nick = sampGetPlayerNickname(id)
                    table.insert(logs, {nick = nick, id = id, detect = 'Возможный оск в Б-Чат', hint = 'Сообщение: '..text, time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
                end
                return false
            end
        end
        local res, insult = containsMention(text)
        if res then 
            sampAddChatMessage(text, color)
            if notify_chat_check.v then
                sampAddChatMessage('[A.Helper] Внимание! В сообщении выше содержится слово: '..insult, 16711729)
            end
            local stime = os.date("*t")
            local id = string.match(text, "%[(%d+)%]")
            if id then 
                local nick = sampGetPlayerNickname(id)
                table.insert(logs, {nick = nick, id = id, detect = 'Возможный упом.', hint = 'Сообщение: '..text, time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
            end
            return false
        end
    end
    if logger_spam.v then
        local id = string.match(text, "%[(%d+)%]")
        if id then
            local stime = os.date("*t")
            local nick = sampGetPlayerNickname(id)
            local t1 = string.gsub(text, "[%s.,?!]", "")
            local yes = false
            for i=1, #spam_list do
                if spam_list[i] then
                    if spam_list[i].time + 60 < os.clock() then
                        table.remove(spam_list, i)
                    elseif spam_list[i].nick == nick and spam_list[i].text == t1 then
                        yes = true
                        spam_list[i].x = spam_list[i].x + 1
                        table.insert(logs, {nick = nick, id = id, detect = 'Спам', hint = 'Сообщение: '..text..'\n'..spam_list[i].x..'-й раз', time = string.format("%02d:%02d:%02d", stime.hour, stime.min, stime.sec), ping = sampGetPlayerPing(playerId)})
                        if notify_spam.v then
                            local finded = false
                            for k=1, #message do
                                local msg = message[k]
                                if msg.nick == nick and msg.ntype == 5 then
                                    finded = true
                                    msg.otvod_x = spam_list[i].x
                                    break 
                                end
                            end
                            if not finded then imgui.ShowNotify('\nСпам x ', nick, 5, spam_list[i].x) end
                        end
                    end
                end
            end
            if not yes then 
                table.insert(spam_list, {nick = nick, text = t1, time = os.clock(), x = 1})
            end
        end
    end
end

function onWindowMessage(msg, wparam, lparam)
    if msg == 0x100 or msg == 0x101 then
        if (wparam == 27 and window_main.v) then
            consumeWindowMessage(true, false)
            if msg == 0x101 then
                window_main.v = false
            end  
        end
    end
end

function check_only_in_plr(tar)
    if not otvod_only_plr.v then return true end
    if tar ~= 1 then return false end
    return true
end

function check_igr_nick(id)
    if not ignor_nick_clr.v then return true end
    if sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == sampGetPlayerColor(id) then return false end
    return true
end

function check_igr_disp(id)
    if not ignor_nick_clr.v then return true end
    local result, ped = sampGetCharHandleBySampPlayerId(id)
    if result then
        local x, y, z = getCharCoordinates(ped)
        if not isPointOnScreen(x, y, z, 0.2) then return false end
    else
        return false
    end
    return true
end

function checktime()
    if not only_before_15m.v then return true end
    local stime = os.date("*t")
    if stime.min > 2 then return false end
    return true
end

function savecfg()
    config.main.ignor_nick_clr = ignor_nick_clr.v
    config.main.ignor_display = ignor_display.v
    config.main.only_before_15m = only_before_15m.v
    config.main.logger_otvod = logger_otvod.v
    config.main.otvod_only_plr = otvod_only_plr.v
    config.main.logger_dmcar = logger_dmcar.v
    config.main.only_with_driver = only_with_driver.v
    config.main.logger_iz_teri = logger_iz_teri.v
    config.main.iz_only_in_p = iz_only_in_p.v
    config.main.logger_vne_teri = logger_vne_teri.v
    config.main.vne_only_in_p = vne_only_in_p.v
    config.main.logger_50k = logger_50k.v
    config.main.logger_exit_ft = logger_exit_ft.v
    config.main.window_size = window_size
    config.main.logger_chat_check = logger_chat_check.v
    config.main.logger_spam = logger_spam.v

    config.notify.notify_dmcar = notify_dmcar.v
    config.notify.notify_otvod = notify_otvod.v
    config.notify.notify_chat_check = notify_chat_check.v
    config.notify.notify_spam = notify_spam.v
    inicfg.save(config, iniFileName)
end

function imgui.Hint(text, delay, notitle, action)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5
        if os.clock() >= go_hint then
            imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.11, 0.11, 0.11, 1.00))
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(450)
                    if not notitle then imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonHovered], u8'Подсказка:') end
                    imgui.TextUnformatted(text)
                    if action ~= nil then
                        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.TextDisabled], '\n '..action)
                    end
                    if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                imgui.PopStyleColor()
            imgui.PopStyleVar(2)
        end
    end
end

function imgui.WCheckbox(t1, bool)
    local text = t1:match("^(.+)##") or t1
    local color = imgui.GetColorU32(imgui.ImVec4(1.00, 0.65, 0.00, 1.00))
    if imgui.Checkbox(t1, bool) then savecfg() end
    local drawList = imgui.GetWindowDrawList()
    local min = imgui.GetItemRectMin()
    local max = imgui.GetItemRectMax()
    max.x = max.x - imgui.CalcTextSize(' '..text).x
    drawList:AddRect(min, max, color, 3.0)
end

function round(number, digit_position) 
    local precision = math.pow(10, digit_position)
    number = number + (precision / 2)
    return math.floor(number / precision) * precision
end

function toLower(text)
    local result = ""
    for i = 1, #text do
        local char = string.sub(text, i, i)
        if char >= "А" and char <= "Я" then
            result = result .. string.char(string.byte(char) + 32)
        elseif char >= "a" and char <= "я" then
            result = result .. char
        else
            result = result .. char
        end
    end
    return result
end

function imgui.SeparatorWithText(text, spacing, color)
    local drawList = imgui.GetWindowDrawList()
    local window_pos = imgui.GetWindowPos()
    local cursor_pos = imgui.GetCursorScreenPos()
    cursor_pos.y = cursor_pos.y + 5
    local text_size = imgui.CalcTextSize(text)
    local width = imgui.GetWindowWidth()
    local color = imgui.GetColorU32(color)
    local p1x = cursor_pos.x+((width-text_size.x-spacing*2)/2)
    local p2x = p1x+text_size.x+spacing*2
    drawList:AddLine(imgui.ImVec2(cursor_pos.x, cursor_pos.y), imgui.ImVec2(p1x, cursor_pos.y), color, 1)
    drawList:AddLine(imgui.ImVec2(p2x, cursor_pos.y), imgui.ImVec2(window_pos.x+width, cursor_pos.y), color, 1)
    imgui.SetCursorPos(imgui.ImVec2(p1x-window_pos.x+spacing, cursor_pos.y-window_pos.y-text_size.y/2))
    imgui.Text(text)
end

function isPointInZone(pointX, pointY, zoneX1, zoneY1, zoneX2, zoneY2)
    local minX = math.min(zoneX1, zoneX2)
    local maxX = math.max(zoneX1, zoneX2)
    local minY = math.min(zoneY1, zoneY2)
    local maxY = math.max(zoneY1, zoneY2)
  
    return pointX >= minX and pointX <= maxX and pointY >= minY and pointY <= maxY
end

ToScreen = convertGameScreenCoordsToWindowScreenCoords
sX, sY = ToScreen(630, 438)
message = {}
msxMsg = 6
notfList = {
    pos = {
        x = sX - 200,
        y = sY
    },
    npos = {
        x = sX - 200,
        y = sY 
    },
    size = {
        x = 200,
        y = 0
    }
}

function onRenderNotification()
    notify_theme()
    local count = 0
    for k, v in ipairs(message) do
        local push = false
        if v.active and v.time < os.clock() then
            v.active = false
            isnotifyact = false
            table.remove(message, k)
        end
        if count < msxMsg then
            if not v.active then
                if v.showtime > 0 then
                    v.active = true
                    isnotifyact = true
                    v.time = os.clock() + v.showtime
                    v.showtime = 0
                end
            end
            if v.active then
                count = count + 1
                if v.time + 3.000 >= os.clock() then
                    imgui.PushStyleVar(imgui.StyleVar.Alpha, (v.time - os.clock()) / 1.0)
                    push = true
                end
                local nText = ''
                if v.nick ~= nil then nText = nText .. v.nick end
                nText = nText .. tostring(v.text)
                if v.otvod_x ~= nil then nText = nText .. tostring(v.otvod_x) end
                notfList.size = imgui.GetFont():CalcTextSizeA(imgui.GetFont().FontSize, 200.0, 200.0, nText:gsub('{.-}', ''))
                notfList.pos = imgui.ImVec2(notfList.pos.x, notfList.pos.y - (notfList.size.y + (count == 1 and 70 or 65 + ((notfList.size.y / 14)*5) )))
                imgui.SetNextWindowPos(notfList.pos, _, imgui.ImVec2(0.0, 0.25))
                imgui.SetNextWindowSize(imgui.ImVec2(250, 50 + 4 + notfList.size.y + ((notfList.size.y / 14) * 4)))
                imgui.Begin('##msg'..k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
                local calc = imgui.CalcTextSize(v.caption)
                imgui.SetCursorPosX((imgui.GetWindowWidth() - calc.x) / 2)
                imgui.Text(v.caption)
                imgui.Separator()
                imgui.Text(nText)
                imgui.End()
                if push then
                    imgui.PopStyleVar()
                end
            end
        end
    end
    sX, sY = ToScreen(605, 438)
    notfList = {
        pos = {
            x = sX - 200,
            y = sY
        },
        npos = {
            x = sX - 200,
            y = sY
        },
        size = {
            x = 200,
            y = 0
        }
    }
end

function addNotify(caption, text, captionPos, textPos, time, nick, ntype, otvod_x)
    message[#message+1] = {active = false, time = 0, showtime = time, text = text, caption = caption, textPos = textPos, captionPos = captionPos, nick = nick, ntype = ntype, otvod_x = otvod_x}
end


function imgui.ShowNotify(text, nick, ntype, otvod_x)
    isnotifyact = true
    addNotify('A.Helper', u8(text), 2, 2, 5, nick, ntype, otvod_x)
end

function theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 5.0
    style.FrameRounding = 4.0

    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00);
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94);
    colors[clr.PopupBg]                = ImVec4(0.10, 0.10, 0.10, 0.94);
    colors[clr.Border]                 = ImVec4(0.80, 0.40, 0.00, 0.50);
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[clr.FrameBg]                = ImVec4(0.80, 0.40, 0.00, 0.54);
    colors[clr.FrameBgHovered]         = ImVec4(1.00, 0.65, 0.00, 0.40);
    colors[clr.FrameBgActive]          = ImVec4(1.00, 0.65, 0.00, 0.67);
    colors[clr.TitleBg]                = ImVec4(0.06, 0.06, 0.06, 1.00);
    colors[clr.TitleBgActive]          = ImVec4(1.00, 0.65, 0.00, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[clr.MenuBarBg]              = ImVec4(0.06, 0.06, 0.06, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[clr.ScrollbarGrab]          = ImVec4(0.75, 0.35, 0.00, 1.00);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.90, 0.50, 0.00, 1.00);
    colors[clr.ScrollbarGrabActive]    = ImVec4(1.00, 0.65, 0.00, 1.00);
    colors[clr.CheckMark]              = ImVec4(1.00, 0.65, 0.00, 1.00);
    colors[clr.SliderGrab]             = ImVec4(1.00, 0.65, 0.00, 0.80);
    colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.65, 0.00, 1.00);
    colors[clr.Button]                 = ImVec4(1.00, 0.65, 0.00, 0.40);
    colors[clr.ButtonHovered]          = ImVec4(1.00, 0.65, 0.00, 1.00);
    colors[clr.ButtonActive]           = ImVec4(0.90, 0.50, 0.00, 1.00);
    colors[clr.Header]                 = ImVec4(1.00, 0.65, 0.00, 0.31);
    colors[clr.HeaderHovered]          = ImVec4(1.00, 0.65, 0.00, 0.80);
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.65, 0.00, 1.00);
    colors[clr.Separator]              = ImVec4(0.80, 0.40, 0.00, 0.50);
    colors[clr.SeparatorHovered]       = ImVec4(1.00, 0.65, 0.00, 0.78);
    colors[clr.SeparatorActive]        = ImVec4(1.00, 0.65, 0.00, 1.00);
    colors[clr.ResizeGrip]             = ImVec4(1.00, 0.65, 0.00, 0.20);
    colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.65, 0.00, 0.67);
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.65, 0.00, 0.95);
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram]          = ImVec4(1.00, 0.65, 0.00, 0.60);
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.65, 0.00, 1.00);
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.65, 0.00, 0.35);
end

function notify_theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 5.0
    style.FrameRounding = 3.0
    style.GrabRounding = 3.0
    style.FramePadding = imgui.ImVec2(4, 3)
    style.ItemSpacing = imgui.ImVec2(6, 6)
    style.WindowPadding = imgui.ImVec2(8, 8)

    colors[clr.WindowBg]                = ImVec4(0.08, 0.10, 0.12, 0.3)
    colors[clr.PopupBg]                 = ImVec4(0.12, 0.14, 0.16, 0.7)
    colors[clr.Text]                    = ImVec4(0.95, 0.95, 0.95, 1.00)
    colors[clr.TextDisabled]            = ImVec4(0.60, 0.60, 0.60, 1.00)
    colors[clr.Border]                  = ImVec4(0.15, 0.17, 0.19, 0.50)
    colors[clr.BorderShadow]            = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.Separator]               = colors[clr.Border]
    colors[clr.SeparatorHovered]        = ImVec4(1.00, 0.65, 0.00, 0.78)
    colors[clr.SeparatorActive]         = ImVec4(1.00, 0.65, 0.00, 1.00)
    colors[clr.ResizeGrip]              = ImVec4(1.00, 0.65, 0.00, 0.25)
    colors[clr.ResizeGripHovered]       = ImVec4(1.00, 0.65, 0.00, 0.67)
    colors[clr.ResizeGripActive]        = ImVec4(1.00, 0.65, 0.00, 0.95)
    colors[clr.PlotLines]               = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]        = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]           = ImVec4(1.00, 0.65, 0.00, 0.60)
    colors[clr.PlotHistogramHovered]    = ImVec4(1.00, 0.65, 0.00, 1.00)
    colors[clr.TextSelectedBg]          = ImVec4(1.00, 0.65, 0.00, 0.35)
end