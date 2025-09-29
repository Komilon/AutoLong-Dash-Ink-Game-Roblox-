#SingleInstance Force
#MaxThreadsPerHotkey 2

; Настройки
CoordMode "Mouse", "Screen"
SetKeyDelay -1, -1
SetMouseDelay -1

; Константы
global SpaceBusy := false
global THRESHOLD := 50  ; Увеличил порог для "близко к центру"
global DELAY_SHORT := 5
global DELAY_LONG := 600
global DELAY_MOUSE := 25  ; Новая задержка после Q

; Флаг блокировки скрипта
global ScriptBlocked := true
global MainGui := ""  ; Теперь это будет объект GUI

; ВСТАВЛЯЕМ ИЗОБРАЖЕНИЕ И ЗВУК В EXE ПРИ КОМПИЛЯЦИИ
FileInstall "DahsingLevelScreen.png", "DahsingLevelScreen.png", 1
FileInstall "Retro2.wav", "Retro2.wav", 1

; Всегда показываем окно соглашения, но проверяем сохранение
ShowStartupNotification()
BlockHotkeys(true)

ShowStartupNotification() {
    global MainGui
    ; Создаем GUI для уведомления
    MainGui := Gui() ; Убрали +AlwaysOnTop
    MainGui.OnEvent("Close", GuiClose)
    MainGui.OnEvent("Escape", GuiClose)
    MainGui.SetFont("s9", "Arial")
    MainGui.MarginY := -2.8  ; Уменьшаем вертикальные отступы
    
    ; Отступ в начале
    MainGui.Add("Text", "w430", " ")
    
    ; Заголовок - жирный и больше
    MainGui.SetFont("s12 Bold", "Arial")
    MainGui.Add("Text", "w430 cRed", "⚡ ВАЖНО! Прочтите перед использованием:")
    MainGui.SetFont("s9 Norm", "Arial")
    MainGui.Add("Text", "w430 cRed", "• Скрипт работает ТОЛЬКО когда включен CapsLock")
    MainGui.Add("Text", "w430 cRed", "• Phantom Step НЕ РАБОТАЕТ (точнее я не проверял)")
    MainGui.Add("Text", "w430 cRed", "• Roblox обязательно должен быть в полноэкранном режиме")
    MainGui.Add("Text", "w430 cRed", "• Пожалуйста не ставте мышь в середину экрана,")
    MainGui.Add("Text", "w430 cRed", "  если не включён Shift Lock, это нарушит выполнение")
    MainGui.Add("Text", "w430 cRed", "• Скрипт работает только если у вас есть Dash в игре")
    MainGui.Add("Text", "w430 cRed", "  (5 уровень скорости)")
    
    
; МАЛЕНЬКИЙ ОТСТУП ПЕРЕД ИЗОБРАЖЕНИЕМ
MainGui.SetFont("s1 Bold", "Arial")
MainGui.Add("Text", "w430", " ")

; ДОБАВЛЯЕМ СКРИНШОТ ЗДЕСЬ
try {
    if (FileExist("DahsingLevelScreen.png")) {
        MainGui.Add("Picture", "w400 h57", "DahsingLevelScreen.png")
    } else {
        MainGui.Add("Text", "w430 cGray", "[Скриншот Dash уровня]")
    }
} catch {
    MainGui.Add("Text", "w430 cGray", "[Скриншот Dash уровня]")
}

; МАЛЕНЬКИЙ ОТСТУП ПОСЛЕ ИЗОБРАЖЕНИЯ
MainGui.Add("Text", "w430", " ")
    
    MainGui.SetFont("s9 Norm", "Arial")
    MainGui.Add("Text", "w430 cRed", "• Скрипт иногда может не срабатывать из-за неправильных")
    MainGui.Add("Text", "w430 cRed", "  таймингов в коде (НО это очень редко)")
    MainGui.Add("Text", "w430 cBlue", "• Скрипт актуален на 29.09.2025")
    
    ; Отступ между разделами
    MainGui.Add("Text", "w430", " ")
    
    ; Как использовать - жирный и больше
    MainGui.SetFont("s11 Bold", "Arial")
    MainGui.Add("Text", "w480 cGreen", "Как использовать:")
    MainGui.SetFont("s9 Norm", "Arial")
    MainGui.Add("Text", "w480", "1) Запустите Ink game (CapsLock + Dahs 5 ур.)")
    MainGui.Add("Text", "w480", "2) Стоя или в движении нажмите Space для выполения скрипта")
    
    ; Отступ между разделами
    MainGui.Add("Text", "w430", " ")
    
    ; Предупреждение - жирный и больше
    MainGui.SetFont("s11 Bold", "Arial")
    MainGui.Add("Text", "w430 cPurple", "⚠ ВНИМАНИЕ:")
    MainGui.SetFont("s9 Norm", "Arial")
    MainGui.Add("Text", "w430 cPurple", "• Данный скрипт создан в РАЗВЛЕКАТЕЛЬНЫХ целях")
    MainGui.Add("Text", "w430 cPurple", "• Разработчик НЕ несёт ответственности за любые")
    MainGui.Add("Text", "w430 cPurple", "  последствия использования данного скрипта")

    MainGui.SetFont("s3.5 Bold", "Arial")
    MainGui.Add("Text", "w430", " ")
    MainGui.SetFont("s9 Norm", "Arial")
    MainGui.Add("Text", "w430 cBlack", "Примечание: если у вас неправильно работает скрипт, мой тг: @Lokkkkf")
    MainGui.Add("Text", "w430 cBlack", "Ctrl+Esc для выхода")
    
    ; Отступ перед кнопкой
    MainGui.SetFont("s15 Bold", "Arial")
    MainGui.Add("Text", "w430", " ")
    MainGui.SetFont("s9 Norm", "Arial")
    
    ; Кнопка Принять
    ContinueBtn := MainGui.Add("Button", "w120 h31 vContinueBtn", "Принять")
    ContinueBtn.OnEvent("Click", ContinueScript)
    
    ; Отступ после кнопки
    MainGui.Add("Text", "w430", " ")
    
    ; Проверяем, есть ли сохранение
    if (FileExist("spaceaction_agreed.ini")) {
        ; Если сохранение есть, сразу активируем кнопку
        ContinueBtn.Text := "Принять ✓"
        TrayTip "SpaceAction", "Скрипт готов к работе!", 1
    } else {
        ; Если сохранения нет, включаем таймер
        ContinueBtn.Enabled := false
        ContinueBtn.Text := "Принять (10)"
        
        ; Таймер для обратного отсчета
        global Countdown := 10
        SetTimer(() => UpdateButton(ContinueBtn), 1000)
    }
    
    MainGui.Show("Center")
}

UpdateButton(ContinueBtn) {
    global Countdown
    Countdown--
    
    if (Countdown > 0) {
        ContinueBtn.Text := "Принять (" . Countdown . ")"
    } else {
        ContinueBtn.Enabled := true
        ContinueBtn.Text := "Принять ✓"
        SetTimer(, 0) ; Останавливаем таймер
    }
}

ContinueScript(*) {
    global ScriptBlocked, MainGui
    ScriptBlocked := false
    
    ; ПРОИГРЫВАЕМ ЗВУК
    try {
        SoundPlay "Retro2.wav"
    } catch {
        ; Если звук не проигрался, ничего не делаем
    }
    
    ; Создаем файл-маркер, что пользователь согласился
    FileAppend "agreed", "spaceaction_agreed.ini"
    BlockHotkeys(false)
    MainGui.Destroy() ; Скрываем окно
    TrayTip "SpaceAction", "Скрипт активирован. Можно начинать работу!", 1
}

GuiClose(*) {
    ; Просто завершаем скрипт с предупреждением
    MsgBox "Скрипт завершает работу!", "SpaceAction", 0x40
    ExitApp
}

BlockHotkeys(block) {
    if (block) {
        Hotkey "~$Space", (*) => "", "Off"
        Hotkey "~$+Space", (*) => "", "Off"
        Hotkey "~$^Space", (*) => "", "Off"
        Hotkey "~$!Space", (*) => "", "Off"
        Hotkey "~$#Space", (*) => "", "Off"
    } else {
        Hotkey "~$Space", HandleSpace, "On"
        Hotkey "~$+Space", HandleSpace, "On"
        Hotkey "~$^Space", HandleSpace, "On"
        Hotkey "~$!Space", HandleSpace, "On"
        Hotkey "~$#Space", HandleSpace, "On"
    }
}

; Группа хоткеев для Space
Hotkey "~$Space", HandleSpace
Hotkey "~$+Space", HandleSpace
Hotkey "~$^Space", HandleSpace
Hotkey "~$!Space", HandleSpace
Hotkey "~$#Space", HandleSpace

Hotkey "~$Space up", HandleSpaceUp
Hotkey "~$+Space up", HandleSpaceUp
Hotkey "~$^Space up", HandleSpaceUp
Hotkey "~$!Space up", HandleSpaceUp
Hotkey "~$#Space up", HandleSpaceUp

HandleSpace(*) {
    global SpaceBusy, ScriptBlocked
    if (ScriptBlocked || SpaceBusy || !GetKeyState("CapsLock", "T"))
        return
    
    SpaceBusy := true
    PerformActions()
}

HandleSpaceUp(*) {
    global SpaceBusy
    SpaceBusy := false
}

PerformActions() {
    ; Локальная переменная для отслеживания состояния Ctrl
    local RestoreCtrl := false
    
    try {
        ; УБРАЛ: TrayTip "SpaceAction", "Space нажат - выполняю действия", 1
        
        ; Получаем координаты центра экрана
        MonitorGet 1, &Left, &Top, &Right, &Bottom
        CenterX := Right // 2
        CenterY := Bottom // 2
        
        ; Обработка Shift Lock
        RestoreCtrl := CheckAndHandleShiftLock(CenterX, CenterY)
        ; УБРАЛ: if (RestoreCtrl) { TrayTip... }
        
        ; Выполняем основную последовательность действий
        ExecuteActionSequence(CenterX, CenterY, RestoreCtrl)
        
        ; УБРАЛ: TrayTip "SpaceAction", "Действия выполнены", 1
    }
    catch as Error {
        ; Гарантированная очистка
        Cleanup(RestoreCtrl)
        TrayTip "SpaceAction", "Ошибка: " . Error.Message, 3
    }
}

CheckAndHandleShiftLock(CenterX, CenterY) {
    global THRESHOLD
    
    ; ОДНА проверка вместо цикла
    MouseGetPos &MX, &MY
    if (Abs(MX - CenterX) <= THRESHOLD && Abs(MY - CenterY) <= THRESHOLD) {
        SendInput "{Ctrl down}"
        Sleep DELAY_SHORT
        SendInput "{Ctrl up}"
        return true
    }
    return false
}

ExecuteActionSequence(CenterX, CenterY, RestoreCtrl) {
    global DELAY_SHORT, DELAY_LONG, DELAY_MOUSE
    
    ; Начальное нажатие F11
    SendInput "{F11}"
    Sleep DELAY_SHORT
    
    ; Блокируем мышь
    BlockInput "MouseMove"
    
    ; Основная последовательность действий
    SendInput "{q}"
    
    ; ЗАДЕРЖКА перед движением мыши
    Sleep DELAY_MOUSE
    
    ; Клик в верхней части экрана
    DllCall("SetCursorPos", "int", CenterX, "int", 0)
    Click "Left Down"
    Sleep DELAY_LONG
    Click "Left Up"
    
    ; Возвращаем курсор
    DllCall("SetCursorPos", "int", CenterX + 50, "int", CenterY)
     
    ; Разблокируем мышь
    BlockInput "MouseMoveOff"
    
    ; Восстанавливаем Shift Lock только если нажимали в начале
    if (RestoreCtrl) {
        SendInput "{Ctrl down}"
        Sleep DELAY_SHORT
        SendInput "{Ctrl up}"
        ; УБРАЛ: TrayTip "SpaceAction", "Shift Lock восстановлен", 1
    }
    
    ; Завершающее нажатие F11
    SendInput "{F11}"
    Sleep DELAY_SHORT
}

Cleanup(RestoreCtrl) {
    BlockInput "MouseMoveOff"
    if (RestoreCtrl) {
        SendInput "{Ctrl up}"
    }
}

; Глобальные хоткеи
^Esc::ExitApp