-- PARCHE para CreateSessionInfo en settings.lua
-- Reemplaza la función CreateSessionInfo existente con esta versión corregida

local function CreateSessionInfo(parent)
    local SAVE_FILE = "serios_saved.json"
    local canRead   = typeof(readfile) == "function" and typeof(isfile) == "function"

    local username, key, expiry = "N/A", "N/A", "N/A"
    local isLifetime = false

    if canRead then
        local ok, result = pcall(function()
            if not isfile(SAVE_FILE) then return nil end
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end)
        if ok and result and result.username and result.key then
            username = result.username
            key      = result.key
            expiry   = result.expiry or "N/A"
        else
            username = "Not Found"
            key      = "Not Found"
        end
    end

    -- expiry guardado es unix epoch como string, o "lifetime"
    local function formatExpiryShort(exp)
        if not exp or exp == "N/A" or exp == "Not Found" then return "N/A" end
        if exp == "lifetime" then isLifetime = true; return "Lifetime" end
        local ts = tonumber(exp)
        if ts then
            local d = os.date("*t", ts)
            return string.format("%02d/%02d/%04d", d.day, d.month, d.year)
        end
        return tostring(exp)
    end

    local function formatExpiryFull(exp)
        if not exp or exp == "N/A" or exp == "Not Found" then return "N/A" end
        if exp == "lifetime" then return "♾️ Lifetime (no expiry)" end
        local ts = tonumber(exp)
        if ts then
            local d = os.date("*t", ts)
            return string.format("%02d/%02d/%04d  %02d:%02d:%02d", d.day, d.month, d.year, d.hour, d.min, d.sec)
        end
        return tostring(exp)
    end

    shortExpiryText = formatExpiryShort(expiry)
    fullExpiryText  = formatExpiryFull(expiry)

    -- Color verde para keys normales, blanco para lifetime/admin
    local expiryColor = (isLifetime or isAdmin)
        and Color3.fromRGB(235, 235, 235)
        or  Color3.fromRGB(60, 210, 90)

    local gridRow = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, LayoutOrder = SO()
    }, parent)
    mk("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0, 8),
        SortOrder     = Enum.SortOrder.LayoutOrder
    }, gridRow)

    local function makeCompactField(parent, label, value, icon, isPassword, lo, overrideColor)
        local container = mk("Frame", {
            Size = UDim2.new(0.333, -6, 1, 0), BackgroundTransparency = 1, LayoutOrder = lo
        }, parent)
        mk("TextLabel", {
            Text = label, Font = Enum.Font.GothamBold, TextSize = 8,
            TextColor3 = C.GRAY, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, container)
        local box = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 14),
            BackgroundColor3 = Color3.fromRGB(16, 16, 16), BorderSizePixel = 0, ZIndex = 5,
        }, container)
        rnd(6, box)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.4 }, box)

        if icon then
            mk("Frame", {
                Size = UDim2.new(0, 1, 0, 14), Position = UDim2.new(0, 28, 0.5, -7),
                BackgroundColor3 = C.LINE, BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 7,
            }, box)
            local img = mk("ImageLabel", {
                Image = icon, Size = UDim2.new(0, 13, 0, 13),
                Position = UDim2.new(0, 8, 0.5, -6),
                BackgroundTransparency = 1, ImageColor3 = C.RED, ZIndex = 6,
            }, box)
            table.insert(accentEls, { el = img, prop = "ImageColor3" })
        end

        local displayText = isPassword and string.rep("•", math.min(#value, 18)) or value
        local textLbl = mk("TextLabel", {
            Text      = displayText, Font = Enum.Font.Code, TextSize = 8,
            TextColor3 = overrideColor or C.WHITE, BackgroundTransparency = 1,
            Size     = UDim2.new(1, icon and -54 or -10, 1, 0),
            Position = UDim2.new(0, icon and 36 or 8, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate   = Enum.TextTruncate.AtEnd, ZIndex = 6,
        }, box)

        if isPassword then
            local showKey = false
            local eyeBtn  = mk("TextButton", {
                Text = "○", Font = Enum.Font.GothamBold, TextSize = 9,
                TextColor3 = C.MUTED, BackgroundTransparency = 1,
                Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -22, 0.5, -10),
                ZIndex = 7, AutoButtonColor = false,
            }, box)
            eyeBtn.MouseButton1Click:Connect(function()
                showKey     = not showKey
                textLbl.Text = showKey and value or displayText
                eyeBtn.Text  = showKey and "●" or "○"
                tw(eyeBtn, 0.1, { TextColor3 = showKey and C.RED or C.MUTED })
            end)
            eyeBtn.MouseEnter:Connect(function() if not showKey then tw(eyeBtn, 0.1, { TextColor3 = C.GRAY }) end end)
            eyeBtn.MouseLeave:Connect(function() if not showKey then tw(eyeBtn, 0.1, { TextColor3 = C.MUTED }) end end)
        end

        return textLbl
    end

    makeCompactField(gridRow, "USERNAME", username, "rbxassetid://75066739039083", false, 1, nil)
    makeCompactField(gridRow, "KEY",      key,      "rbxassetid://126448589402910", true,  2, nil)
    expiryLabelRef = makeCompactField(gridRow, "EXPIRY", shortExpiryText, "rbxassetid://78475382175834", false, 3, expiryColor)
end
