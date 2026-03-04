-- ╔══════════════════════════════════════════════════════════════╗
-- ║                      settings.lua                           ║
-- ║              PanelBase · Session Info Module                ║
-- ╚══════════════════════════════════════════════════════════════╝

local HttpService = game:GetService("HttpService")

-- ──────────────────────────────────────────────────────────────
--  MODULE
-- ──────────────────────────────────────────────────────────────

local Settings = {}

-- ──────────────────────────────────────────────────────────────
--  COLOR PALETTE
-- ──────────────────────────────────────────────────────────────

Settings.C = {
    WIN    = Color3.fromRGB( 20,  19,  18),
    TBAR   = Color3.fromRGB( 15,  14,  13),
    LINE   = Color3.fromRGB( 45,  43,  40),
    ACCENT = Color3.fromRGB(255, 255, 255),
    NAV    = Color3.fromRGB( 13,  12,  11),
    NAVPIL = Color3.fromRGB( 28,  26,  24),
    WHITE  = Color3.fromRGB(228, 226, 222),
    GRAY   = Color3.fromRGB(108, 104,  98),
    MUTED  = Color3.fromRGB( 58,  55,  50),
    PANEL  = Color3.fromRGB( 28,  27,  25),
}

-- ──────────────────────────────────────────────────────────────
--  LAYOUT CONSTANTS
-- ──────────────────────────────────────────────────────────────

Settings.Layout = {
    WW   = 540,
    WH   = 440,
    TH   =  42,
    NW   = 246,
    NH   =  46,
    NGAP =  14,
    BH   = 440 - 42,
}

-- ──────────────────────────────────────────────────────────────
--  BUILD
-- ──────────────────────────────────────────────────────────────

function Settings.build(page, r)

    -- Shortcuts
    local C       = Settings.C
    local mk      = r.mk
    local rnd     = r.rnd
    local tw      = r.tw
    local isAdmin = r.isAdmin or false

    -- Accent elements registry
    local accentEls = {}

    -- Layout order counter
    local order = 0
    local function nextOrder()
        order = order + 1
        return order
    end

    -- Expiry display references
    local expiryLabelRef  = nil
    local fullExpiryText  = ""
    local shortExpiryText = ""

    -- ──────────────────────────────────────────────────────────
    --  HELPER · Register accent element
    -- ──────────────────────────────────────────────────────────

    local function registerAccent(element, property)
        table.insert(accentEls, { el = element, prop = property })
    end

    -- ──────────────────────────────────────────────────────────
    --  HELPER · Compact field  (label + value box)
    -- ──────────────────────────────────────────────────────────

    local function makeCompactField(parent, label, value, icon, isPassword, layoutOrder, overrideColor)

        -- Container
        local container = mk("Frame", {
            Size                   = UDim2.new(0.333, -5, 1, 0),
            BackgroundTransparency = 1,
            LayoutOrder            = layoutOrder,
        }, parent)

        -- Label
        mk("TextLabel", {
            Text                   = label,
            Font                   = Enum.Font.GothamBold,
            TextSize               = 8,
            TextColor3             = C.GRAY,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 12),
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 5,
        }, container)

        -- Value box
        local box = mk("Frame", {
            Size             = UDim2.new(1, 0, 0, 28),
            Position         = UDim2.new(0, 0, 0, 14),
            BackgroundColor3 = Color3.fromRGB(24, 23, 21),
            BorderSizePixel  = 0,
            ZIndex           = 5,
        }, container)
        rnd(4, box)
        mk("UIStroke", {
            Color        = Color3.fromRGB(50, 47, 43),
            Thickness    = 1,
            Transparency = 0,
        }, box)

        -- Optional icon + divider
        if icon then
            mk("Frame", {
                Size             = UDim2.new(0, 1, 0, 13),
                Position         = UDim2.new(0, 28, 0.5, -6),
                BackgroundColor3 = Color3.fromRGB(50, 47, 43),
                BorderSizePixel  = 0,
                ZIndex           = 7,
            }, box)

            local img = mk("ImageLabel", {
                Image                  = icon,
                Size                   = UDim2.new(0, 12, 0, 12),
                Position               = UDim2.new(0, 8, 0.5, -6),
                BackgroundTransparency = 1,
                ImageColor3            = C.ACCENT,
                ZIndex                 = 6,
            }, box)
            registerAccent(img, "ImageColor3")
        end

        -- Value text
        local displayText = isPassword and string.rep("•", math.min(#value, 18)) or value
        local textLbl = mk("TextLabel", {
            Text                   = displayText,
            Font                   = Enum.Font.Code,
            TextSize               = 8,
            TextColor3             = overrideColor or C.WHITE,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, icon and -54 or -10, 1, 0),
            Position               = UDim2.new(0, icon and 36 or 6, 0, 0),
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextTruncate           = Enum.TextTruncate.AtEnd,
            ZIndex                 = 6,
        }, box)

        -- Show / hide toggle (passwords only)
        if isPassword then
            local visible = false

            local eyeBtn = mk("TextButton", {
                Text                   = "○",
                Font                   = Enum.Font.GothamBold,
                TextSize               = 9,
                TextColor3             = C.MUTED,
                BackgroundTransparency = 1,
                Size                   = UDim2.new(0, 20, 0, 20),
                Position               = UDim2.new(1, -22, 0.5, -10),
                ZIndex                 = 7,
                AutoButtonColor        = false,
            }, box)

            eyeBtn.MouseButton1Click:Connect(function()
                visible        = not visible
                textLbl.Text   = visible and value or displayText
                eyeBtn.Text    = visible and "●" or "○"
                tw(eyeBtn, 0.1, { TextColor3 = visible and C.ACCENT or C.MUTED })
            end)

            eyeBtn.MouseEnter:Connect(function()
                if not visible then tw(eyeBtn, 0.1, { TextColor3 = C.GRAY }) end
            end)
            eyeBtn.MouseLeave:Connect(function()
                if not visible then tw(eyeBtn, 0.1, { TextColor3 = C.MUTED }) end
            end)
        end

        return textLbl
    end

    -- ──────────────────────────────────────────────────────────
    --  SESSION INFO
    -- ──────────────────────────────────────────────────────────

    local function buildSessionInfo(parent)

        local SAVE_FILE = "serios_saved.json"
        local canRead   = typeof(readfile) == "function" and typeof(isfile) == "function"

        local username, key, expiry = "N/A", "N/A", "N/A"
        local isLifetime = false

        -- Read saved credentials
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

        -- Expiry formatters
        local function formatShort(exp)
            if not exp or exp == "N/A" or exp == "Not Found" then return "N/A" end
            if exp == "lifetime" then isLifetime = true; return "Lifetime" end
            local ts = tonumber(exp)
            if ts then
                local d = os.date("*t", ts)
                return string.format("%02d/%02d/%04d", d.day, d.month, d.year)
            end
            return tostring(exp)
        end

        local function formatFull(exp)
            if not exp or exp == "N/A" or exp == "Not Found" then return "N/A" end
            if exp == "lifetime" then return "Lifetime (no expiry)" end
            local ts = tonumber(exp)
            if ts then
                local d = os.date("*t", ts)
                return string.format(
                    "%02d/%02d/%04d  %02d:%02d:%02d",
                    d.day, d.month, d.year,
                    d.hour, d.min, d.sec
                )
            end
            return tostring(exp)
        end

        shortExpiryText = formatShort(expiry)
        fullExpiryText  = formatFull(expiry)

        local expiryColor = (isLifetime or isAdmin)
            and Color3.fromRGB(228, 226, 222)
            or  Color3.fromRGB( 72, 200,  88)

        -- Fields row
        local gridRow = mk("Frame", {
            Size                   = UDim2.new(1, 0, 0, 46),
            BackgroundTransparency = 1,
            LayoutOrder            = nextOrder(),
        }, parent)

        mk("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding       = UDim.new(0, 6),
            SortOrder     = Enum.SortOrder.LayoutOrder,
        }, gridRow)

        makeCompactField(gridRow, "USERNAME", username,         "rbxassetid://75066739039083",  false, 1, nil)
        makeCompactField(gridRow, "KEY",      key,              "rbxassetid://126448589402910", true,  2, nil)
        expiryLabelRef =
        makeCompactField(gridRow, "EXPIRY",   shortExpiryText,  "rbxassetid://78475382175834",  false, 3, expiryColor)
    end

    -- ──────────────────────────────────────────────────────────
    --  PAGE ASSEMBLY  (delayed so parent layout is ready)
    -- ──────────────────────────────────────────────────────────

    task.delay(1, function()

        -- Page layout + padding
        mk("UIListLayout", {
            Padding   = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)

        mk("UIPadding", {
            PaddingTop    = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft   = UDim.new(0, 8),
            PaddingRight  = UDim.new(0, 8),
        }, page)

        -- ┌─────────────────────────────────────────────────┐
        -- │  Session Info Panel                             │
        -- └─────────────────────────────────────────────────┘

        local panel = mk("Frame", {
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(28, 27, 25),
            BorderSizePixel  = 0,
            LayoutOrder      = nextOrder(),
        }, page)
        rnd(5, panel)
        mk("UIStroke", {
            Color        = Color3.fromRGB(48, 46, 42),
            Thickness    = 1,
            Transparency = 0.35,
        }, panel)

        -- Header background
        local header = mk("Frame", {
            Size             = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Color3.fromRGB(22, 21, 19),
            BorderSizePixel  = 0,
            ZIndex           = 4,
            ClipsDescendants = true,
        }, panel)
        rnd(5, header)

        -- Fill bottom half to remove rounded bottom corners on header
        mk("Frame", {
            Size             = UDim2.new(1, 0, 0.5, 0),
            Position         = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(22, 21, 19),
            BorderSizePixel  = 0,
            ZIndex           = 3,
        }, header)

        -- Left accent bar
        local accentBar = mk("Frame", {
            Size             = UDim2.new(0, 2, 0, 16),
            Position         = UDim2.new(0, 8, 0.5, -8),
            BackgroundColor3 = C.ACCENT,
            BorderSizePixel  = 0,
            ZIndex           = 6,
        }, header)
        rnd(1, accentBar)
        registerAccent(accentBar, "BackgroundColor3")

        -- Title
        mk("TextLabel", {
            Text                   = "Session Info",
            Font                   = Enum.Font.GothamBold,
            TextSize               = 12,
            TextColor3             = C.WHITE,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, -44, 1, 0),
            Position               = UDim2.new(0, 16, 0, 0),
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 6,
        }, header)

        -- Header icon
        local headerIcon = mk("ImageLabel", {
            Image                  = "rbxassetid://78475382175834",
            Size                   = UDim2.new(0, 13, 0, 13),
            Position               = UDim2.new(1, -22, 0.5, -6),
            BackgroundTransparency = 1,
            ImageColor3            = C.ACCENT,
            ZIndex                 = 7,
        }, header)
        registerAccent(headerIcon, "ImageColor3")

        -- Header / content divider
        mk("Frame", {
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, 0, 34),
            BackgroundColor3 = Color3.fromRGB(42, 40, 37),
            BorderSizePixel  = 0,
            ZIndex           = 4,
        }, panel)

        -- Content area
        local content = mk("Frame", {
            Size                   = UDim2.new(1, -18, 0, 0),
            Position               = UDim2.new(0, 9, 0, 42),
            AutomaticSize          = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, panel)

        mk("UIPadding", { PaddingBottom = UDim.new(0, 10) }, panel)

        buildSessionInfo(content)
    end)
end

return Settings
