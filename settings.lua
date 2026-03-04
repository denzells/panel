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
    --  HELPER · Row  (label left · value right)
    -- ──────────────────────────────────────────────────────────
    --  Each row renders as:
    --    ┌──────────────────────────────────────────┐
    --    │  LABEL           ··· value / control     │
    --    └──────────────────────────────────────────┘
    --  with a hairline separator beneath it.

    local function makeInfoRow(parent, label, value, icon, isPassword, layoutOrder, valueColor)

        -- Row wrapper
        local row = mk("Frame", {
            Size                   = UDim2.new(1, 0, 0, 38),
            BackgroundTransparency = 1,
            LayoutOrder            = layoutOrder,
        }, parent)

        -- Left label  ── gray, small caps style
        mk("TextLabel", {
            Text                   = label,
            Font                   = Enum.Font.GothamBold,
            TextSize               = 10,
            TextColor3             = C.GRAY,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(0.45, 0, 1, 0),
            Position               = UDim2.new(0, 0, 0, 0),
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 5,
        }, row)

        -- Right value container
        local valBox = mk("Frame", {
            Size                   = UDim2.new(0.55, 0, 0, 26),
            Position               = UDim2.new(0.45, 0, 0.5, -13),
            BackgroundColor3       = Color3.fromRGB(18, 17, 16),
            BorderSizePixel        = 0,
            ZIndex                 = 5,
        }, row)
        rnd(5, valBox)

        -- Optional icon inside the box
        if icon then
            local img = mk("ImageLabel", {
                Image                  = icon,
                Size                   = UDim2.new(0, 11, 0, 11),
                Position               = UDim2.new(0, 7, 0.5, -5),
                BackgroundTransparency = 1,
                ImageColor3            = C.ACCENT,
                ZIndex                 = 6,
            }, valBox)
            registerAccent(img, "ImageColor3")
        end

        -- Value text
        local displayText = isPassword and string.rep("•", math.min(#value, 16)) or value
        local xOffset     = icon and 24 or 8
        local xSize       = isPassword and -52 or (icon and -28 or -16)

        local textLbl = mk("TextLabel", {
            Text                   = displayText,
            Font                   = Enum.Font.Code,
            TextSize               = 9,
            TextColor3             = valueColor or C.WHITE,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, xSize, 1, 0),
            Position               = UDim2.new(0, xOffset, 0, 0),
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextTruncate           = Enum.TextTruncate.AtEnd,
            ZIndex                 = 6,
        }, valBox)

        -- Show / hide toggle (passwords only)
        if isPassword then
            local visible = false

            local eyeBtn = mk("TextButton", {
                Text                   = "○",
                Font                   = Enum.Font.GothamBold,
                TextSize               = 9,
                TextColor3             = C.MUTED,
                BackgroundTransparency = 1,
                Size                   = UDim2.new(0, 22, 1, 0),
                Position               = UDim2.new(1, -24, 0, 0),
                ZIndex                 = 7,
                AutoButtonColor        = false,
            }, valBox)

            eyeBtn.MouseButton1Click:Connect(function()
                visible        = not visible
                textLbl.Text   = visible and value or displayText
                eyeBtn.Text    = visible and "●" or "○"
                tw(eyeBtn, 0.12, { TextColor3 = visible and C.ACCENT or C.MUTED })
            end)

            eyeBtn.MouseEnter:Connect(function()
                if not visible then tw(eyeBtn, 0.1, { TextColor3 = C.GRAY }) end
            end)
            eyeBtn.MouseLeave:Connect(function()
                if not visible then tw(eyeBtn, 0.1, { TextColor3 = C.MUTED }) end
            end)
        end

        -- Hairline separator beneath the row
        mk("Frame", {
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Color3.fromRGB(34, 33, 31),
            BorderSizePixel  = 0,
            ZIndex           = 4,
            BackgroundTransparency = 0.3,
        }, row)

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
            or  Color3.fromRGB( 88, 210, 110)

        -- Rows
        local lo = 0
        local function lo_next() lo = lo + 1; return lo end

        makeInfoRow(parent, "Username",   username,        "rbxassetid://75066739039083",  false, lo_next(), nil)
        makeInfoRow(parent, "Key",        key,             "rbxassetid://126448589402910", true,  lo_next(), nil)
        expiryLabelRef =
        makeInfoRow(parent, "Expiry",     shortExpiryText, "rbxassetid://78475382175834",  false, lo_next(), expiryColor)
    end

    -- ──────────────────────────────────────────────────────────
    --  PAGE ASSEMBLY  (delayed so parent layout is ready)
    -- ──────────────────────────────────────────────────────────

    task.delay(1, function()

        -- Page layout + padding
        mk("UIListLayout", {
            Padding   = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)

        mk("UIPadding", {
            PaddingTop    = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft   = UDim.new(0, 10),
            PaddingRight  = UDim.new(0, 10),
        }, page)

        -- ┌─────────────────────────────────────────────────┐
        -- │  Session Info Panel  (borderless, soft dark)    │
        -- └─────────────────────────────────────────────────┘

        local panel = mk("Frame", {
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(22, 21, 20),
            BorderSizePixel  = 0,
            LayoutOrder      = nextOrder(),
        }, page)
        rnd(8, panel)
        -- No UIStroke — clean borderless card

        -- ── Header ───────────────────────────────────────

        local header = mk("Frame", {
            Size                   = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            ZIndex                 = 4,
        }, panel)

        -- Title
        mk("TextLabel", {
            Text                   = "Session Info",
            Font                   = Enum.Font.GothamBold,
            TextSize               = 13,
            TextColor3             = C.WHITE,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, -40, 1, 0),
            Position               = UDim2.new(0, 14, 0, 0),
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 6,
        }, header)

        -- Small accent icon (top-right, like reference image)
        local headerIcon = mk("ImageLabel", {
            Image                  = "rbxassetid://78475382175834",
            Size                   = UDim2.new(0, 12, 0, 12),
            Position               = UDim2.new(1, -22, 0.5, -6),
            BackgroundTransparency = 1,
            ImageColor3            = C.ACCENT,
            ZIndex                 = 7,
        }, header)
        registerAccent(headerIcon, "ImageColor3")

        -- Header divider
        mk("Frame", {
            Size                   = UDim2.new(1, -28, 0, 1),
            Position               = UDim2.new(0, 14, 1, -1),
            BackgroundColor3       = Color3.fromRGB(38, 36, 34),
            BorderSizePixel        = 0,
            ZIndex                 = 4,
            BackgroundTransparency = 0,
        }, header)

        -- ── Content ──────────────────────────────────────

        local content = mk("Frame", {
            Size                   = UDim2.new(1, -28, 0, 0),
            Position               = UDim2.new(0, 14, 0, 44),
            AutomaticSize          = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, panel)

        mk("UIListLayout", {
            Padding   = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, content)

        mk("UIPadding", { PaddingBottom = UDim.new(0, 14) }, panel)

        buildSessionInfo(content)
    end)
end

return Settings
